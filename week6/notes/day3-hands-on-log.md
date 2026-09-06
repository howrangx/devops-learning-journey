DAY 3: ELASTIC LOAD BALANCING - HANDS-ON LOG
Session Record

LEARNING DATE: September 6, 2026
COMPLETED BY: Iman
REGION: us-east-1
ENVIRONMENT: WSL2 Ubuntu on Windows

========================================
1. SESSION OBJECTIVES
========================================

- Build a three-tier security group chain before any compute exists
- Place two web servers in different availability zones
- Register them in a target group and observe health check states
- Front them with an Application Load Balancer
- Observe request distribution and explain the pattern
- Break a target deliberately and confirm the health check removes it
- Confirm the instances are unreachable except through the load balancer
- Tear down in dependency order and verify

========================================
2. PRE-FLIGHT
========================================

A four-region sweep across us-east-1, eu-north-1, eu-central-1 and
eu-west-1 returned no EC2 instances, no load balancers and no RDS
instances.

This check matters more on Day 3 than on previous days. An EC2 instance
can be stopped and an RDS instance can be deleted in minutes, but an
Application Load Balancer has no stopped state. It exists or it is
deleted, and it bills hourly either way with no traffic at all.

========================================
3. STATE KEPT IN A FILE, NOT IN THE SHELL
========================================

Day 2 ended with two teardown commands that silently did nothing because
their shell variables had gone empty in a new terminal. One failed loudly;
the other ran against an empty argument and left a t3.micro running while
the session appeared to have finished cleanly.

The correction applied from Day 3 onward: resource identifiers are
appended to a file outside the repository as they are created.

VPC_ID=$(aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" \
  --query "Vpcs[0].VpcId" --output text)
SUBNET_A=$(aws ec2 describe-subnets \
  --filters "Name=availability-zone,Values=us-east-1a" "Name=vpc-id,Values=$VPC_ID" \
  --query "Subnets[0].SubnetId" --output text)
SUBNET_B=$(aws ec2 describe-subnets \
  --filters "Name=availability-zone,Values=us-east-1b" "Name=vpc-id,Values=$VPC_ID" \
  --query "Subnets[0].SubnetId" --output text)
MY_IP=$(curl -s https://checkip.amazonaws.com)

cat > ~/week6-day3.env <<EOF
VPC_ID=$VPC_ID
SUBNET_A=$SUBNET_A
SUBNET_B=$SUBNET_B
MY_IP=$MY_IP
EOF

Each new resource appends its identifier:

echo "ALB_SG=$ALB_SG" >> ~/week6-day3.env

Any new terminal restores the full set with source ~/week6-day3.env. The
file lives outside the repository so no resource identifiers are ever
committed.

========================================
4. THE SECURITY GROUP CHAIN
========================================

Built before any instance or load balancer existed, so nothing was ever
briefly exposed while rules were still being added.

Load balancer group, facing the internet:

ALB_SG=$(aws ec2 create-security-group \
  --group-name week6-alb-sg \
  --description "Week 6 ALB public ingress" \
  --vpc-id $VPC_ID --query GroupId --output text)

aws ec2 authorize-security-group-ingress --group-id $ALB_SG \
  --protocol tcp --port 80 --cidr 0.0.0.0/0

Web tier group, two rules with two different source types:

WEB_SG=$(aws ec2 create-security-group \
  --group-name week6-web-sg \
  --description "Week 6 web tier" \
  --vpc-id $VPC_ID --query GroupId --output text)

aws ec2 authorize-security-group-ingress --group-id $WEB_SG \
  --protocol tcp --port 80 --source-group $ALB_SG

aws ec2 authorize-security-group-ingress --group-id $WEB_SG \
  --protocol tcp --port 22 --cidr $MY_IP/32

Why the two rules use different source types:

A source group can only reference something that has a security group,
which means an AWS resource. The load balancer is one, so the port 80 rule
names its group and follows it automatically. A laptop is not an AWS
resource and has no security group, so the port 22 rule has to name an
address range.

The rule that generalises: identity when the source is an AWS resource,
CIDR when it is not.

What would be lost if port 80 were open to 0.0.0.0/0 on the web tier:

Nothing would stop working, which is exactly why the question is worth
answering. What breaks is control, not connectivity.

The load balancer stops being the only way in. Any client that learns an
instance address can reach it directly, including an instance the load
balancer has already marked unhealthy and stopped sending traffic to.

Deregistration becomes meaningless. Auto Scaling removes an instance from
the target group and drains its connections before terminating it. Direct
traffic ignores all of that and keeps arriving at an instance that is
about to disappear.

Everything the load balancer adds becomes optional: TLS termination,
routing rules, access logs, even distribution, and later a web application
firewall. All of it applies only to traffic that passes through it.

The attack surface multiplies. One controlled entry point becomes as many
directly reachable web servers as there are instances, so a web server
vulnerability is exposed on every one of them rather than behind a single
managed front door.

========================================
5. WEB SERVERS IN TWO AVAILABILITY ZONES
========================================

User data script committed as week6/scripts/day3-user-data.sh:

#!/bin/bash
dnf install -y httpd
systemctl enable --now httpd

TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 300" -s)
IID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s \
  http://169.254.169.254/latest/meta-data/instance-id)
AZ=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s \
  http://169.254.169.254/latest/meta-data/placement/availability-zone)

cat > /var/www/html/index.html <<HTML
<h1>Week 6 web tier</h1>
<p>Instance: $IID</p>
<p>Availability zone: $AZ</p>
HTML

The page identifies which instance served it, using the IMDSv2 token flow
from Week 5 Day 2. Without that, every response is identical and request
distribution cannot be observed at all.

Two instances launched, one per availability zone, with --subnet-id set
explicitly rather than letting AWS choose:

aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro \
  --key-name week5-key --security-group-ids $WEB_SG --subnet-id $SUBNET_A \
  --user-data file://week6/scripts/day3-user-data.sh \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=week6-web-a},{Key=Week,Value=6}]'

The AMI was resolved through the SSM public parameter rather than
hardcoded, so the command keeps working as AWS publishes new images.

========================================
6. TARGET GROUP AND HEALTH CHECK TUNING
========================================

aws elbv2 create-target-group \
  --name week6-web-tg \
  --protocol HTTP --port 80 \
  --vpc-id $VPC_ID \
  --target-type instance \
  --health-check-path / \
  --health-check-interval-seconds 15 \
  --healthy-threshold-count 2 \
  --unhealthy-threshold-count 2

The interval was set to 15 seconds instead of the default 30, and both
thresholds to 2 instead of the defaults. That makes a failure observable
in roughly 30 seconds instead of two and a half minutes.

This is a deliberate trade of sensitivity against noise. Faster detection
also means a single slow response is more likely to remove a healthy
target from rotation, so the defaults are usually the better choice in
production.

State observed immediately after registering both targets, before any load
balancer or listener existed:

i-REDACTED   unused   Target.NotInUse
i-REDACTED   unused   Target.NotInUse

Predicted correctly before running the command. The unused state does not
indicate a broken target. It indicates that nothing routes to the target
group yet. Registration and routing are separate things: registering a
target adds it to a group, and only attaching that group to a listener
puts it in the request path.

========================================
7. LOAD BALANCER AND LISTENER
========================================

aws elbv2 create-load-balancer \
  --name week6-alb \
  --type application \
  --scheme internet-facing \
  --subnets $SUBNET_A $SUBNET_B \
  --security-groups $ALB_SG

aws elbv2 wait load-balancer-available --load-balancer-arns $ALB_ARN

aws elbv2 create-listener \
  --load-balancer-arn $ALB_ARN \
  --protocol HTTP --port 80 \
  --default-actions Type=forward,TargetGroupArn=$TG_ARN

Creation took two to three minutes. Once the listener existed, both
targets moved through initial to healthy in about thirty seconds.

Two subnets in different availability zones are a hard requirement for an
ALB, not a recommendation. The load balancer places a node in each zone,
and a single zone would make the load balancer itself the single point of
failure it exists to remove. Same reasoning as the DB subnet group on
Day 2.

========================================
8. REQUEST DISTRIBUTION OBSERVED
========================================

Ten requests through the load balancer DNS name:

for i in $(seq 1 10); do curl -s "http://$ALB_DNS" | grep -E "Instance|zone"; done

Result: five requests served by each instance, but not in an alternating
pattern. The observed order was a, b, b, a, b, a, a, b, b, a.

Explanation: the ALB places one node per availability zone, and each node
runs its own independent round robin. Each curl invocation resolves the
DNS name fresh and may land on either node. The result is two independent
rotations sampled at random.

An exactly even split at ten requests is coincidence. The guarantee is
statistical over many requests, not per request. Any test that assumes
strict alternation is testing an assumption the service never made.

========================================
9. DELIBERATE FAILURE INJECTION
========================================

The web server was stopped on one instance without terminating it:

ssh -i week5/week5-key.pem ec2-user@$WEB_A_IP "sudo systemctl stop httpd"

Health check state before:

i-REDACTED-A   healthy   None
i-REDACTED-B   healthy   None

State after roughly 30 seconds:

i-REDACTED-A   unhealthy   Target.FailedHealthChecks
i-REDACTED-B   healthy     None

Ten requests during the failure: all ten served by the surviving instance.

What did not happen is the important part. No request returned 502 or 503,
and no request was slow. The load balancer removed the target from
rotation before any traffic could reach it, which is the difference
between a health check and a retry. A retry sends a request, fails, and
tries again, so the client experiences the failure. A health check
discovers the failure out of band and the client never encounters it.

Recovery:

ssh -i week5/week5-key.pem ec2-user@$WEB_A_IP "sudo systemctl start httpd"

The target returned to healthy on the next check cycle with no manual
re-registration. Target group membership and target health are separate
concepts: an unhealthy target stays registered and simply stops receiving
traffic.

========================================
10. SECURITY BOUNDARY VERIFIED
========================================

Both instances healthy and serving. The same instance was then requested
two ways.

Directly, by public IP address:

timeout 8 curl -s "http://$WEB_A_IP"
Result: not reachable

Through the load balancer:

timeout 8 curl -s "http://$ALB_DNS" | grep Instance
Result: served normally

Same instance, same running web server, in a public subnet with a public
IP address. The difference is the source of the request. The web tier
security group permits port 80 only from the load balancer's security
group, so a request that cannot present that identity has no path.

This is the same shape as the Day 2 database test, applied one tier
further out: reachable by identity, not by address.

========================================
11. TEARDOWN
========================================

Dependency order matters twice here.

aws elbv2 delete-listener --listener-arn $LISTENER_ARN
aws elbv2 delete-load-balancer --load-balancer-arn $ALB_ARN
aws elbv2 wait load-balancers-deleted --load-balancer-arns $ALB_ARN

aws elbv2 delete-target-group --target-group-arn $TG_ARN
aws ec2 terminate-instances --instance-ids $WEB_A $WEB_B

aws ec2 wait instance-terminated --instance-ids $WEB_A $WEB_B
aws ec2 delete-security-group --group-id $WEB_SG
aws ec2 delete-security-group --group-id $ALB_SG

The target group cannot be deleted while a listener forwards to it, which
is why the load balancer deletion is waited on rather than assumed.

The web tier security group must be deleted before the load balancer
group, because its ingress rule references the load balancer group as a
source. AWS refuses to delete a group that another rule depends on. The
teardown order is the creation order reversed.

Verification, all five sections empty:

aws elbv2 describe-load-balancers
aws elbv2 describe-target-groups
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running,pending,stopped"
aws ec2 describe-security-groups --filters "Name=group-name,Values=week6-*"
aws ec2 describe-volumes --filters "Name=status,Values=available"

Clean on the first attempt, unlike Day 2. The state file is the reason:
every variable the teardown needed was still correct because it had been
written to disk rather than held in a shell.

========================================
HANDS-ON PRACTICE SUMMARY
========================================

Topics Covered:
- Three-tier security group chaining
- Source group versus CIDR, and when each is the only option
- User data scripts and instance self-identification through IMDSv2
- Target groups, target registration, and health check tuning
- Load balancer nodes, listeners and the two-AZ requirement
- Request distribution behaviour across nodes
- Health check driven failover
- Verifying a security boundary from outside
- Deletion dependency ordering

Skills Practiced:
- Persisting resource identifiers to a file instead of shell variables
- Building the security layer before the resources that use it
- Tuning health check timing and stating the trade being made
- Predicting a resource state before reading it
- Injecting a failure deliberately to test a control
- Confirming a security control by proving access fails
- Tearing down in reverse creation order and verifying

Key Learnings:
- Identity for AWS sources, CIDR for anything outside AWS
- Opening the web tier to the internet costs control, not connectivity:
  bypassed health checks, meaningless draining, and skipped TLS, logging
  and routing
- The unused target state means nothing routes to the group, not that the
  target is broken
- Registration and routing are separate; so are membership and health
- Distribution is statistical across independent per-node rotations, not
  a strict rotation
- A health check prevents the client from ever seeing the failure, unlike
  a retry which exposes it
- An ALB requires two availability zones for the same reason a DB subnet
  group does
- A security group cannot be deleted while another group's rule
  references it, so teardown is creation order reversed
- An ALB has no stopped state; it exists and bills, or it is deleted

========================================
NEXT STEPS: Day 4 - Auto Scaling and Launch Templates
========================================
