#!/usr/bin/env python3
"""
capstone-app.py

Stateless web tier for the Week 6 capstone. Every request is served by
whichever instance the load balancer chooses; all shared state lives in
RDS MySQL. Database credentials are fetched from Secrets Manager at
runtime and cached. If the database rejects them, the cached copy is
discarded and the AWSCURRENT version is fetched again and tried. If that
is rejected too, a single-user rotation is in progress: the database
already holds the new password but AWSCURRENT has not been promoted yet,
so the AWSPENDING version is tried. At most three connection attempts
are made per request, and a rotated password is absorbed with no restart
and no failed requests.

Endpoints:
  /        record a visit and show totals per instance
  /health  liveness only; never touches the database (used by the ALB)
  /ready   database reachability (used for diagnosis, not replacement)
"""

import json
import logging
import os
import time
import urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

import boto3
import pymysql

PORT = int(os.environ.get("APP_PORT", "8080"))
DB_HOST = os.environ["DB_HOST"]
DB_NAME = os.environ.get("DB_NAME", "capstone")
SECRET_ARN = os.environ["SECRET_ARN"]
REGION = os.environ.get("AWS_REGION", "us-east-1")
CREDENTIAL_CACHE_SECONDS = 300
ACCESS_DENIED = 1045

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger("capstone")

secrets_client = boto3.client("secretsmanager", region_name=REGION)
credential_cache = {"value": None, "fetched_at": 0.0}
schema_ready = False


def metadata(path):
    """Read one instance metadata value using an IMDSv2 session token."""
    token_request = urllib.request.Request(
        "http://169.254.169.254/latest/api/token",
        method="PUT",
        headers={"X-aws-ec2-metadata-token-ttl-seconds": "300"},
    )
    token = urllib.request.urlopen(token_request, timeout=2).read().decode()
    value_request = urllib.request.Request(
        f"http://169.254.169.254/latest/meta-data/{path}",
        headers={"X-aws-ec2-metadata-token": token},
    )
    return urllib.request.urlopen(value_request, timeout=2).read().decode()


INSTANCE_ID = metadata("instance-id")
ZONE = metadata("placement/availability-zone")


def fetch_secret(stage):
    """Fetch one version of the database secret by its staging label."""
    secret = secrets_client.get_secret_value(SecretId=SECRET_ARN, VersionStage=stage)
    log.info("database credentials fetched from Secrets Manager (%s)", stage)
    return json.loads(secret["SecretString"])


def cache_credentials(credentials):
    credential_cache["value"] = credentials
    credential_cache["fetched_at"] = time.time()


def get_credentials(force_refresh=False):
    """Return cached database credentials, fetching AWSCURRENT when stale or forced."""
    age = time.time() - credential_cache["fetched_at"]
    if force_refresh or credential_cache["value"] is None or age > CREDENTIAL_CACHE_SECONDS:
        cache_credentials(fetch_secret("AWSCURRENT"))
    return credential_cache["value"]


def open_connection(credentials):
    return pymysql.connect(
        host=DB_HOST,
        user=credentials["username"],
        password=credentials["password"],
        database=DB_NAME,
        connect_timeout=3,
        autocommit=True,
    )


def access_denied(error):
    return bool(error.args) and error.args[0] == ACCESS_DENIED


def database():
    """Connect with cached, then fresh AWSCURRENT, then AWSPENDING credentials.

    Only an access-denied error moves on to the next attempt. Any other
    error (database unreachable, timeout) is raised at once, because a
    different password cannot fix it.
    """
    try:
        return open_connection(get_credentials())
    except pymysql.err.OperationalError as error:
        if not access_denied(error):
            raise
    log.warning("database rejected cached credentials; refetching AWSCURRENT")

    try:
        return open_connection(get_credentials(force_refresh=True))
    except pymysql.err.OperationalError as error:
        if not access_denied(error):
            raise
        current_rejected = error
    log.warning("database rejected AWSCURRENT; rotation may be in progress, trying AWSPENDING")

    try:
        pending = fetch_secret("AWSPENDING")
    except Exception as error:
        log.error("no usable AWSPENDING version: %s", error.__class__.__name__)
        raise current_rejected
    connection = open_connection(pending)
    cache_credentials(pending)
    log.info("connected with AWSPENDING credentials; cached until the next refresh")
    return connection


def ensure_schema(cursor):
    global schema_ready
    if not schema_ready:
        cursor.execute(
            "CREATE TABLE IF NOT EXISTS visits ("
            " id BIGINT AUTO_INCREMENT PRIMARY KEY,"
            " instance_id VARCHAR(32) NOT NULL,"
            " zone VARCHAR(32) NOT NULL,"
            " visited_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)"
        )
        schema_ready = True


def record_visit():
    connection = database()
    try:
        with connection.cursor() as cursor:
            ensure_schema(cursor)
            cursor.execute(
                "INSERT INTO visits (instance_id, zone) VALUES (%s, %s)",
                (INSTANCE_ID, ZONE),
            )
            cursor.execute("SELECT COUNT(*) FROM visits")
            total = cursor.fetchone()[0]
            cursor.execute(
                "SELECT instance_id, zone, COUNT(*) FROM visits"
                " GROUP BY instance_id, zone ORDER BY COUNT(*) DESC"
            )
            breakdown = cursor.fetchall()
    finally:
        connection.close()
    return total, breakdown


def database_reachable():
    connection = database()
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
            cursor.fetchone()
    finally:
        connection.close()


class Handler(BaseHTTPRequestHandler):
    def send_text(self, status, body, content_type="text/plain"):
        data = body.encode()
        self.send_response(status)
        self.send_header("Content-Type", f"{content_type}; charset=utf-8")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def do_GET(self):
        if self.path == "/health":
            self.send_text(200, "ok\n")
        elif self.path == "/ready":
            try:
                database_reachable()
                self.send_text(200, "ready\n")
            except Exception as error:
                log.error("readiness check failed: %s", error)
                self.send_text(503, "database unreachable\n")
        elif self.path == "/":
            try:
                total, breakdown = record_visit()
            except Exception as error:
                log.error("request failed: %s", error)
                self.send_text(500, "database unavailable\n")
                return
            rows = "\n".join(
                f"<tr><td>{instance}</td><td>{zone}</td><td>{count}</td></tr>"
                for instance, zone, count in breakdown
            )
            page = (
                "<html><body>"
                "<h1>Week 6 capstone</h1>"
                f"<p>Served by {INSTANCE_ID} in {ZONE}</p>"
                f"<p>Total visits recorded in the database: {total}</p>"
                "<table><tr><th>Instance</th><th>Zone</th><th>Visits</th></tr>"
                f"{rows}</table>"
                "</body></html>\n"
            )
            self.send_text(200, page, "text/html")
        else:
            self.send_text(404, "not found\n")

    def log_message(self, fmt, *args):
        headers = getattr(self, "headers", None)
        client = headers.get("X-Forwarded-For") if headers else None
        log.info("%s %s", client or self.client_address[0], fmt % args)


if __name__ == "__main__":
    log.info("starting on port %d as %s in %s", PORT, INSTANCE_ID, ZONE)
    ThreadingHTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
