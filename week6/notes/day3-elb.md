DAY 3: ELASTIC LOAD BALANCING
Command Reference and Learning Notes

LEARNING DATE: September 6, 2026
COMPLETED BY: Iman

========================================
1. WHY LOAD BALANCING EXISTS
========================================

A single EC2 instance serving an application has three problems, and load
balancing addresses all three.

Availability. If the instance fails, the application is down. There is no
mechanism to route around it because there is nothing to route to.

Capacity. A single instance has a ceiling. Growing past it means a larger
instance, which requires a restart and eventually runs out of sizes.

Deployment risk. Updating the application means updating the only copy of
it, while it is serving traffic.

A load balancer sits in front of a group of instances and distributes
requests across them. That single change makes instances disposable, which
is the property everything else in this week depends on. An instance that
can be removed from rotation can be patched, replaced, or terminated
without an outage, and that is what makes Day 4's Auto Scaling possible.

The important shift in thinking: the load balancer becomes the stable
address. Instances become interchangeable and temporary. Nothing outside
the VPC ever knows an instance's address again.

========================================
2. THE LOAD BALANCER TYPES
========================================

Application Load Balancer (ALB)
Operates at layer 7, meaning it understands HTTP. It can read paths,
hostnames, headers, methods and query strings, and route on any of them.
It terminates TLS, supports WebSockets and HTTP/2, and can target
instances, IP addresses, Lambda functions, or another ALB.

This is the default choice for web applications, and the one used this
week.

Network Load Balancer (NLB)
Operates at layer 4, meaning TCP and UDP only. It does not read the
request. In exchange it handles millions of requests per second at very
low latency, preserves the client source IP without extra configuration,
and can be given a static IP address per availability zone.

Used for non-HTTP protocols, extreme throughput, or when a fixed IP is
required because a third party has firewalled it.

Gateway Load Balancer (GWLB)
Operates at layer 3 and exists for one purpose: inserting virtual
appliances such as firewalls or intrusion detection systems into the
traffic path transparently. Rarely encountered outside security
architecture work.

Classic Load Balancer
The previous generation, superseded by the above. Not used for new work.

Choosing between them:
- HTTP or HTTPS, and routing decisions based on the request: ALB
- TCP, UDP, or a static IP requirement: NLB
- Inline security appliances: GWLB

========================================
3. ANATOMY OF AN ALB
========================================

Four objects, and requests pass through them in order.

Load balancer
The thing with a DNS name. It exists in at least two availability zones
and has a scheme of either internet-facing or internal.

Listener
A port and protocol the load balancer accepts connections on. Port 80
HTTP, port 443 HTTPS. A load balancer with no listener accepts nothing.

Rules
Attached to a listener. Each has a priority, a condition, and an action.
Requests are tested against rules in priority order, lowest number first,
and the first match wins. Every listener has a default rule that runs when
nothing else matches.

Target group
A named set of targets plus the health check configuration that decides
which of them are eligible to receive traffic. Rules forward to target
groups; they never forward to instances directly.

The indirection matters. Because a rule points at a target group rather
than at instances, the set of instances can change continuously without
the listener or its rules being touched. That is the seam Auto Scaling
plugs into on Day 4.

Request path:

client -> DNS -> load balancer node in an AZ -> listener -> rule ->
target group -> healthy target

========================================
4. TARGET GROUPS
========================================

A target group has a protocol, a port, a target type, and a health check.

Target types:

instance - targets are EC2 instance IDs, and traffic goes to the primary
private address of the instance. The most common choice.

ip - targets are IP addresses, which may be in the VPC, in a peered VPC,
or on-premises over Direct Connect or VPN. Required when targeting
containers with awsvpc networking.

lambda - the target is a Lambda function, letting an ALB invoke serverless
code directly.

alb - the target is another Application Load Balancer, used when an NLB
needs to front an ALB to obtain a static IP.

Creating a target group:

aws elbv2 create-target-group \
  --name week6-web-tg \
  --protocol HTTP --port 80 \
  --vpc-id VPC_ID \
  --target-type instance \
  --health-check-path /

Registering targets:

aws elbv2 register-targets \
  --target-group-arn TARGET_GROUP_ARN \
  --targets Id=INSTANCE_ID_ONE Id=INSTANCE_ID_TWO

The port in the target group is the port on the target, which need not
match the listener port. A listener on 443 forwarding to a target group on
port 8080 is normal.

Deregistration delay, also called connection draining, controls how long
the load balancer waits for in-flight requests to finish before it stops
sending traffic to a removed target. The default is 300 seconds. Lowering
it makes deployments faster and risks cutting off long requests; raising
it does the opposite.

aws elbv2 modify-target-group-attributes \
  --target-group-arn TARGET_GROUP_ARN \
  --attributes Key=deregistration_delay.timeout_seconds,Value=30

========================================
5. HEALTH CHECKS
========================================

The health check is what makes a load balancer more than a round-robin
distributor. Without it, requests would continue to be sent to a broken
instance.

Parameters:

HealthCheckPath - the URL requested, for example / or /health
HealthCheckIntervalSeconds - how often, default 30
HealthCheckTimeoutSeconds - how long to wait for a response, default 5
HealthyThresholdCount - consecutive successes before a target is used
UnhealthyThresholdCount - consecutive failures before it is removed
Matcher - which HTTP status codes count as success, default 200

Reading the state of targets:

aws elbv2 describe-target-health \
  --target-group-arn TARGET_GROUP_ARN \
  --query "TargetHealthDescriptions[].[Target.Id,TargetHealth.State,TargetHealth.Reason]" \
  --output table

States and what they mean:

initial - registered, first health check not yet completed
healthy - receiving traffic
unhealthy - failing the check, receiving no traffic
draining - deregistering, finishing in-flight requests
unused - registered but the target group is not attached to a listener,
  or the target is in a stopped state

The unused state is worth recognising. It does not indicate a broken
target; it indicates that nothing is routing to the group yet.

A health check endpoint should test what actually matters. Returning 200
from a static file proves the web server is running, which is not the same
as proving the application can reach its database. A health check that
always passes is a health check that never removes a broken instance from
rotation.

The opposite failure is also real: a check that queries the database on
every request, every thirty seconds, from every target, adds load and can
turn a slow database into a total outage by marking every instance
unhealthy at once.

========================================
6. LISTENER RULES AND ROUTING
========================================

Conditions available to an ALB rule:

path-pattern - /api/*, /images/*
host-header - api.example.com
http-header - any header, including custom ones
http-request-method - GET, POST
query-string - key and value pairs
source-ip - CIDR of the client

Actions:

forward - send to one or more target groups, with optional weights
redirect - return a 301 or 302, commonly HTTP to HTTPS
fixed-response - return a status code and body without a target
authenticate-cognito and authenticate-oidc - authenticate before
  forwarding

Adding a path-based rule:

aws elbv2 create-rule \
  --listener-arn LISTENER_ARN \
  --priority 10 \
  --conditions Field=path-pattern,Values='/api/*' \
  --actions Type=forward,TargetGroupArn=API_TARGET_GROUP_ARN

Weighted forwarding is how blue-green and canary deployments are done
without any external tooling: two target groups behind one rule, with the
weights shifted gradually from old to new.

Rule priority is evaluated lowest first and the first match wins, so
ordering is a design decision. A rule matching /* placed at priority 1
makes every rule after it unreachable.

========================================
7. AVAILABILITY ZONES AND CROSS-ZONE BEHAVIOUR
========================================

An ALB must be attached to subnets in at least two availability zones.
This is a hard requirement, not a recommendation, and it is the same
reasoning as the DB subnet group on Day 2: the load balancer places a node
in each zone, and a single zone would make the load balancer itself a
single point of failure.

The DNS name resolves to the addresses of those nodes. Clients are
distributed across zones by DNS, then each node distributes across
targets.

Cross-zone load balancing controls whether a node can send traffic to
targets in other zones.

On an ALB it is always enabled and cannot be turned off. Every node can
reach every healthy target, so an uneven number of targets per zone still
results in even distribution.

On an NLB it is disabled by default. Each node only serves targets in its
own zone, so two targets in one zone and eight in another produces a
badly skewed load. Enabling it costs money, because cross-zone traffic on
an NLB is billed as inter-AZ data transfer.

========================================
8. STICKY SESSIONS
========================================

Stickiness binds a client to one target for a period, using a cookie.

aws elbv2 modify-target-group-attributes \
  --target-group-arn TARGET_GROUP_ARN \
  --attributes Key=stickiness.enabled,Value=true \
    Key=stickiness.type,Value=lb_cookie \
    Key=stickiness.lb_cookie.duration_seconds,Value=86400

Two types. lb_cookie has the load balancer generate and manage the cookie.
app_cookie follows a cookie the application already sets.

Stickiness is usually a workaround for state stored in an instance's local
memory, and it reintroduces the problem load balancing was meant to solve.
A sticky client whose target is replaced loses its session. Load
distribution becomes uneven because long-lived clients pin themselves.
Scaling out helps less, because existing clients stay where they are.

The better fix is to move session state out of the instance, into a
database, a cache such as ElastiCache, or a signed token held by the
client. Stickiness is appropriate for legacy applications that cannot be
changed, and it should be recognised as a compromise rather than a
feature.

========================================
9. TLS AND SECURITY
========================================

Terminating HTTPS at the load balancer means the certificate lives in one
place, renewal is automatic when using AWS Certificate Manager, and
instances handle plain HTTP internally.

aws elbv2 create-listener \
  --load-balancer-arn LOAD_BALANCER_ARN \
  --protocol HTTPS --port 443 \
  --certificates CertificateArn=CERTIFICATE_ARN \
  --ssl-policy ELBSecurityPolicy-TLS13-1-2-2021-06 \
  --default-actions Type=forward,TargetGroupArn=TARGET_GROUP_ARN

The SSL policy selects which TLS versions and ciphers are accepted.
Choosing a policy that permits TLS 1.0 to support very old clients weakens
every connection, so it is a deliberate trade rather than a default.

Redirecting HTTP to HTTPS is a listener action, requiring no target:

aws elbv2 create-listener \
  --load-balancer-arn LOAD_BALANCER_ARN \
  --protocol HTTP --port 80 \
  --default-actions '[{"Type":"redirect","RedirectConfig":{"Protocol":"HTTPS","Port":"443","StatusCode":"HTTP_301"}}]'

Security group model

Two groups, chained, and this is the pattern the capstone repeats.

The load balancer's group allows 80 and 443 from the internet, or from
whatever range should reach the application.

The instances' group allows the application port from the load balancer's
security group as a source group, and from nothing else.

The result is that instances cannot be reached directly even though they
sit in public subnets. All traffic must pass through the load balancer.
This is the same source-group reasoning as the Day 2 database rule,
applied one tier further out.

NLBs historically did not support security groups, so instance groups had
to allow client CIDRs directly. That changed in 2023 and an NLB can now
have a security group, which makes the two-tier pattern available there
too.

========================================
10. MONITORING AND ACCESS LOGS
========================================

CloudWatch metrics published by an ALB:

RequestCount - total requests
TargetResponseTime - latency from the target
HTTPCode_Target_5XX_Count - errors returned by the application
HTTPCode_ELB_5XX_Count - errors generated by the load balancer itself
HealthyHostCount and UnHealthyHostCount - targets per state
RejectedConnectionCount - connections refused, usually a capacity limit

The distinction between HTTPCode_Target_5XX and HTTPCode_ELB_5XX is the
first thing to check during an incident. Target 5XX means the application
returned an error. ELB 5XX means the load balancer could not get a usable
response at all, commonly because no healthy targets exist. They point at
completely different causes.

Access logs record every request and are delivered to S3. They are
disabled by default:

aws elbv2 modify-load-balancer-attributes \
  --load-balancer-arn LOAD_BALANCER_ARN \
  --attributes Key=access_logs.s3.enabled,Value=true \
    Key=access_logs.s3.bucket,Value=BUCKET_NAME

The bucket needs a policy permitting the log delivery service to write to
it, or the setting silently fails to take effect.

The idle timeout, default 60 seconds, closes connections with no data
flowing. Applications with long-polling or slow uploads need it raised, or
requests will be cut off mid-flight.

========================================
11. COST MODEL
========================================

An ALB bills two ways at once.

An hourly charge for the load balancer existing, whether or not any
request arrives. This is the important one for a learning account: an ALB
created and forgotten costs roughly 16 to 18 USD per month with zero
traffic.

Load Balancer Capacity Units, which meter new connections, active
connections, processed bytes and rule evaluations. Negligible at learning
volumes.

Unlike an EC2 instance, an ALB cannot be stopped. It exists or it is
deleted. There is no paused state.

The practical rule for this week: an ALB is created at the start of a
session and deleted at the end of it, every time.

========================================
12. HANDS-ON EXERCISES
========================================

Prerequisite: the four-region resource sweep and the current credit
balance, before anything is created.

Exercise 1: build the two-tier security group chain

Create a security group for the load balancer allowing port 80 from the
internet. Create a second group for the instances allowing port 80 only
from the first group as a source group.

Build both before any instance or load balancer exists, so nothing is ever
briefly exposed.

Exercise 2: launch two web servers in different availability zones

Two t3.micro instances, one in us-east-1a and one in us-east-1b, each with
a user data script that installs a web server and writes a page
identifying which instance served it. Identifying the instance is what
makes distribution visible later.

Exercise 3: target group and health checks

Create a target group on HTTP port 80 with a health check on /, register
both instances, and watch the state move from initial to healthy. Read the
target health before attaching anything to a listener, and note the state
reported at that point.

Exercise 4: load balancer and listener

Create an internet-facing ALB across both subnets, add a listener on port
80 forwarding to the target group, and wait for the load balancer to
become active.

Then request the DNS name repeatedly and observe which instance answers.

Exercise 5: prove the health check works

Stop the web server on one instance without terminating it. Watch the
target transition to unhealthy, confirm every request is now served by the
remaining instance, then restart the service and watch it return.

This is the exercise that demonstrates the actual value of the health
check, and it is more instructive than the successful path.

Exercise 6: prove the security boundary

Request an instance's public address directly, bypassing the load
balancer. It must fail, because the instance security group accepts port
80 only from the load balancer's group.

========================================
13. TEARDOWN
========================================

Dependency order, innermost last.

aws elbv2 delete-listener --listener-arn LISTENER_ARN
aws elbv2 delete-load-balancer --load-balancer-arn LOAD_BALANCER_ARN

Wait for deletion to complete before removing the target group, because
the target group cannot be deleted while a listener references it:

aws elbv2 wait load-balancers-deleted --load-balancer-arns LOAD_BALANCER_ARN

aws elbv2 delete-target-group --target-group-arn TARGET_GROUP_ARN
aws ec2 terminate-instances --instance-ids INSTANCE_ID_ONE INSTANCE_ID_TWO

Security groups are deleted last, and the instance group must go before
the load balancer group, because the instance rule references it:

aws ec2 delete-security-group --group-id INSTANCE_SECURITY_GROUP_ID
aws ec2 delete-security-group --group-id LOAD_BALANCER_SECURITY_GROUP_ID

Verification, which is the step that actually confirms the teardown:

aws elbv2 describe-load-balancers --query "LoadBalancers[].[LoadBalancerName,State.Code]" --output text
aws elbv2 describe-target-groups --query "TargetGroups[].TargetGroupName" --output text
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running,pending,stopped" --query "Reservations[].Instances[].[InstanceId,State.Name]" --output text
aws ec2 describe-security-groups --filters "Name=group-name,Values=week6-*" --query "SecurityGroups[].[GroupName,GroupId]" --output text
aws ec2 describe-volumes --filters "Name=status,Values=available" --query "Volumes[].[VolumeId,Size]" --output text

Every section should return nothing. A teardown command that returns
without error is not evidence that anything was removed; only the listing
afterwards is.

========================================
HANDS-ON PRACTICE SUMMARY
========================================

Topics Covered:
- Why load balancing makes instances disposable
- Application, Network and Gateway Load Balancers compared
- Listeners, rules, target groups and targets
- Target types and deregistration delay
- Health check parameters, states, and what to check for
- Path and host based routing, and rule priority
- The two-availability-zone requirement and cross-zone behaviour
- Sticky sessions and why they are a compromise
- TLS termination and the chained security group pattern
- CloudWatch metrics, and target 5XX versus load balancer 5XX
- The ALB cost model and the absence of a stopped state

Skills Practiced:
- Building the security layer before the resources that use it
- Chaining security groups so instances are unreachable directly
- Registering targets and reading target health states
- Verifying a health check by deliberately breaking a target
- Verifying a security boundary by confirming direct access fails
- Tearing down in dependency order and verifying the result

Key Learnings:
- Rules forward to target groups, never to instances, and that
  indirection is what Auto Scaling attaches to
- An ALB requires two availability zones for the same reason a DB subnet
  group does
- Cross-zone load balancing is always on for an ALB and off by default
  for an NLB
- The unused target state means nothing is routing to the group, not that
  the target is broken
- A health check that always passes never removes a broken instance
- Stickiness reintroduces the coupling that load balancing removes
- Target 5XX and ELB 5XX point at entirely different causes
- An ALB cannot be stopped, only deleted, and bills hourly with no traffic

========================================
NEXT STEPS: Day 4 - Auto Scaling and Launch Templates
========================================
