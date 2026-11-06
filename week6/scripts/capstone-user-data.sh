#!/bin/bash
# capstone-user-data.sh
# Bootstrap body for capstone application instances.
#
# Not used on its own. At deploy time it is prepended with:
#   DB_HOST     the RDS endpoint address
#   SECRET_ARN  the ARN of the database secret (a pointer, never the secret)
#   the application source, written to /opt/capstone/app.py
#
# Output is written to /var/log/capstone-bootstrap.log, readable through
# a Session Manager shell when an instance fails to become healthy.

set -euo pipefail
exec > >(tee -a /var/log/capstone-bootstrap.log) 2>&1

echo "bootstrap start $(date -u +%FT%TZ)"

dnf install -y python3-pip

useradd --system --no-create-home --shell /sbin/nologin capstone || true

python3 -m venv /opt/capstone/venv
/opt/capstone/venv/bin/pip install --quiet pymysql boto3

TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 300")
REGION=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/placement/region)

mkdir -p /etc/capstone
cat > /etc/capstone/app.env <<EOF
DB_HOST=$DB_HOST
DB_NAME=capstone
SECRET_ARN=$SECRET_ARN
AWS_REGION=$REGION
APP_PORT=8080
EOF
chown root:capstone /etc/capstone/app.env
chmod 640 /etc/capstone/app.env
chown -R capstone:capstone /opt/capstone

cat > /etc/systemd/system/capstone.service <<'EOF'
[Unit]
Description=Week 6 capstone web application
After=network-online.target
Wants=network-online.target

[Service]
User=capstone
EnvironmentFile=/etc/capstone/app.env
ExecStart=/opt/capstone/venv/bin/python /opt/capstone/app.py
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now capstone.service

echo "bootstrap done $(date -u +%FT%TZ)"
