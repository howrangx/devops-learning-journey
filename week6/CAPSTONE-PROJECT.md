# Week 6 Capstone: Highly Available Two-Tier Web Application

## Overview

A two-tier web application deployed across two availability zones in a
purpose-built VPC, combining every topic from Week 6: IAM roles, a managed
database, an Application Load Balancer, an Auto Scaling group, monitoring
and alerting, and verified teardown.

The application tier holds no state. Every request is served by whichever
instance the load balancer chooses, and all shared state lives in the
database. Each page shows the instance and zone that served it and a visit
counter stored in MySQL, so two instances incrementing one counter is the
visible proof.

The build is done by hand first, section by section, and then captured as
scripts that rebuild the whole environment from nothing and remove it
again.

## Architecture

```
internet
   |
   Application Load Balancer ---- public subnets, us-east-1a and us-east-1b
   |   HTTP 80                    one NAT gateway in each public subnet
   |
   Auto Scaling group ----------- private app subnets, us-east-1a and us-east-1b
   |   application on 8080        no public IP addresses
   |                              outbound only, through the same zone's NAT
   |
   RDS MySQL -------------------- private database subnets, both zones
       3306                       no route to or from the internet
```

### Network

- VPC `10.0.0.0/16`, DNS hostnames and DNS resolution enabled
- Six subnets, three tiers across two zones:

| Tier | us-east-1a | us-east-1b | Route to internet |
|---|---|---|---|
| Public | 10.0.1.0/24 | 10.0.2.0/24 | Internet gateway |
| App | 10.0.11.0/24 | 10.0.12.0/24 | NAT gateway in the same zone |
| Database | 10.0.21.0/24 | 10.0.22.0/24 | None |

- One public route table shared by both public subnets
- Two app route tables, one per zone, each pointing at that zone's NAT
  gateway
- One database route table with only the local VPC route

### Security groups

| Group | Allows inbound | From |
|---|---|---|
| ALB | TCP 80 | 0.0.0.0/0 |
| App | TCP 8080 | ALB security group |
| Database | TCP 3306 | App security group |

No group allows SSH. Nothing is reachable directly from the internet
except the load balancer.

### Compute

- Launch template: Amazon Linux 2023 resolved through SSM, t3.micro,
  IMDSv2 required, detailed monitoring enabled, no key pair, no public IP
- Auto Scaling group: minimum 2, maximum 4, desired 2, across both app
  subnets, ELB health checks, attached to the target group
- Application: a small Python web service running under systemd on port
  8080, installed at boot by user data

### Database

- RDS MySQL on db.t3.micro, encrypted storage, not publicly accessible
- DB subnet group spanning both database subnets
- Multi-AZ if the free plan permits it; the outcome is recorded either way
- Master password generated and managed by RDS in Secrets Manager

### Identity

One IAM role on the application instances, with two policies:

- `AmazonSSMManagedInstanceCore`, the AWS managed policy for Session
  Manager access
- A customer managed policy allowing `secretsmanager:GetSecretValue` on
  the one database secret, and nothing else

No access keys exist on any instance, and the user data contains only the
database endpoint and the secret's ARN, never the secret itself.

### Monitoring

- SNS topic with a confirmed email subscription
- Alarm on target 5XX responses from the load balancer
- Alarm on unhealthy host count in the target group

## Design Decisions

### Application servers in private subnets

Public subnets would work, as they did on Days 3 and 4, with the security
group allowing only the load balancer. But in a public subnet the security
group is the only control between an instance and the internet, and a
single wrong rule exposes it. In a private subnet there is no inbound
route at all, so a security group mistake cannot expose the instance.
Two independent controls instead of one.

The cost is outbound access. Instances install packages at boot and call
the Secrets Manager and Systems Manager APIs, all of which need a route
out. That route is a NAT gateway.

### One NAT gateway per availability zone

A NAT gateway lives in a single zone. With one NAT gateway in us-east-1a,
losing that zone also removes internet access from the app servers in
us-east-1b, and replacement instances there can no longer install their
software. That is the hidden boot-time dependency identified in the Day 5
failure analysis, reintroduced by the network.

Each zone's app subnet therefore routes through its own zone's NAT
gateway, so the zones share no dependency.

NAT gateways have no stopped state. Two of them cost about 9 cents per hour
while they exist, and they exist only for the duration of a session.

### No SSH

The instances have no public address and no key pair, and no security
group allows port 22. Shell access, when needed, goes through SSM Session
Manager: the instance's agent connects outwards to the Systems Manager
service, and a session is opened through the AWS API using IAM
credentials. Nothing listens for inbound connections, access is controlled
and logged by IAM, and there is no key file to lose.

### Shallow health check for the load balancer

The application exposes two endpoints:

- `/health` reports whether the process is running. It does not touch the
  database. The target group uses it.
- `/ready` reports whether the database is reachable. It is used for
  diagnosis and monitoring, never for replacement.

If the load balancer health check queried the database, a database that
was merely slow for a minute would fail every instance at once, and the
Auto Scaling group would replace the entire fleet. The health check would
cause the outage it exists to prevent. Liveness decides replacement;
dependency health is observed and alerted on separately.

### Credentials fetched at runtime, not at boot

RDS rotates a managed master password automatically, every seven days by
default. An instance that read the password once at boot would keep the old
value after rotation, so long-running instances would fail every database
query while freshly launched ones worked, and a shallow health check would
keep the broken ones in service indefinitely.

The application instead fetches the secret from Secrets Manager at
runtime, caches it for a few minutes, and on an authentication failure
discards the cached value, fetches it again, and retries once. Rotation is
absorbed by the application with no restart and no replacement.

### Python for the application tier

A small Python service using the standard library plus `pymysql` and
`boto3`, consistent with Week 3. Running on port 8080 rather than 80 means
it runs without root privileges, and the target group port differing from
the listener port is the normal arrangement described on Day 3.

## Deliberate Simplifications

Each of these is a known gap from a production deployment, documented
rather than hidden:

- **Master database credentials are used by the application.** Production
  would create a dedicated application user with grants limited to one
  schema, or use IAM database authentication with short-lived tokens.
- **Software is installed at boot.** Production would bake the application
  into a custom AMI so a new instance has nothing to download. Per-zone NAT
  gateways make the boot-time install zone-resilient, but it remains
  dependent on the package repository.
- **HTTP only.** HTTPS would need a domain name and an ACM certificate on
  the load balancer.
- **Single region.** Nothing here survives a regional failure.
- **No VPC endpoints.** S3 and Secrets Manager traffic leaves through the
  NAT gateways. Endpoints would keep it inside AWS and reduce NAT data
  charges.

## Failure Behaviour

| Failure | Expected behaviour |
|---|---|
| One app instance crashes | Load balancer stops routing to it after two failed checks; Auto Scaling replaces it |
| One availability zone fails | Load balancer serves from the other zone; replacements launch there through that zone's own NAT gateway |
| Database is slow or unreachable | `/health` keeps passing so no instances are replaced; pages return errors; the 5XX alarm notifies |
| Database password rotates | Application fetches the new secret on its next authentication failure; no restart |
| A bad application version that still answers `/health` | Rolled onto every instance by a refresh; not survived, because the failure is correlated |
| Region failure | Not survived |

## Cost

Approximate hourly cost while everything exists:

| Component | Per hour |
|---|---|
| Two NAT gateways | 0.090 USD |
| Application Load Balancer | 0.023 USD |
| RDS db.t3.micro, doubled if Multi-AZ | 0.017 to 0.034 USD |
| Two t3.micro instances | 0.021 USD |
| Public IPv4 addresses, NAT and load balancer | about 0.020 USD |
| Total | about 0.17 to 0.19 USD |

A four-hour session costs well under one dollar. Left running for a month,
the same environment would cost about 130 USD, which is why every session
ends with teardown and `teardown-check.sh`.

## Teardown Order

Dependencies run the other way from creation, and several deletions are
asynchronous, so each step is waited on before the next:

1. Auto Scaling group, force deleted, then wait for its instances
2. Launch template
3. Listener, load balancer, then target group
4. RDS instance, then DB subnet group
5. NAT gateways, waited until deleted
6. Elastic IPs released
7. Internet gateway detached and deleted
8. Subnets, route tables, security groups, then the VPC
9. IAM instance profile, role and customer managed policy
10. Alarms and SNS topic
11. `teardown-check.sh`, which must report CLEAN

## Files

- `CAPSTONE-PROJECT.md` - this design
- `scripts/capstone-app.py` - the application
- `scripts/capstone-user-data.sh` - instance bootstrap
- `scripts/capstone-deploy.sh` - builds the environment from nothing
- `scripts/capstone-teardown.sh` - removes it in dependency order
- `scripts/teardown-check.sh` - extended to report non-default VPCs
- `notes/capstone-hands-on-log.md` - what was run and what happened
