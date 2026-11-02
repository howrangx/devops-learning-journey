DAY 4: AUTO SCALING AND LAUNCH TEMPLATES
Command Reference and Learning Notes

LEARNING DATE: November 2, 2026
COMPLETED BY: Iman

========================================
1. WHAT AUTO SCALING ACTUALLY SOLVES
========================================

Day 3 made instances disposable: a load balancer in front of a target
group means any single instance can fail without an outage. But the
replacing was still manual. An instance that died stayed dead until
someone noticed.

An Auto Scaling group closes that loop. It owns a set of instances and
continuously works to make reality match a declared desired state. If an
instance fails a health check, the group terminates it and launches a
replacement. If load rises, the group adds instances. If load falls, it
removes them.

Three distinct capabilities, often conflated:

Self-healing. Maintaining the desired count regardless of failures. This
works with no scaling policy at all and is the most valuable part for most
workloads.

Elasticity. Changing the desired count in response to demand, via scaling
policies.

Zone balance. Distributing instances evenly across availability zones, and
rebalancing automatically when a zone recovers.

The mental shift: instances stop being things that are created and start
being things that are described. Nothing names an instance any more. The
launch template says what one should look like, the group says how many
should exist, and AWS reconciles the difference.

========================================
2. LAUNCH TEMPLATES
========================================

A launch template is the specification for an instance: AMI, instance
type, key pair, security groups, IAM instance profile, user data, block
devices, tags, and metadata options.

Launch configurations were the predecessor. They are immutable, cannot be
versioned, and AWS stopped allowing new ones to be created. Any current
work uses launch templates.

Creating one:

aws ec2 create-launch-template \
  --launch-template-name week6-web-lt \
  --version-description "initial" \
  --launch-template-data '{
    "ImageId": "AMI_ID",
    "InstanceType": "t3.micro",
    "KeyName": "week5-key",
    "SecurityGroupIds": ["WEB_SECURITY_GROUP_ID"],
    "UserData": "BASE64_ENCODED_USER_DATA",
    "TagSpecifications": [{
      "ResourceType": "instance",
      "Tags": [{"Key": "Name", "Value": "week6-asg-web"}]
    }]
  }'

User data in a launch template must be base64 encoded. The run-instances
command accepts a file path and encodes it automatically; create-launch-
template does not. This is the most common launch template error:

base64 -w 0 week6/scripts/day3-user-data.sh

The -w 0 disables line wrapping. Without it, base64 inserts newlines every
76 characters and the resulting value is rejected.

Versions

Templates are versioned, and versions are immutable. Changing anything
creates a new version:

aws ec2 create-launch-template-version \
  --launch-template-name week6-web-lt \
  --source-version 1 \
  --version-description "larger instance" \
  --launch-template-data '{"InstanceType": "t3.small"}'

--source-version inherits everything from an existing version, so only the
changed fields need to be supplied.

An Auto Scaling group references a template and a version, and the version
reference can be a number, $Latest, or $Default.

Using $Latest means every new instance picks up the newest version
automatically, which sounds convenient and is usually wrong in production:
a template edit silently changes what the next launched instance looks
like, with no deployment and no review. Pinning an explicit version, or
using $Default and moving the default deliberately, makes the change an
action rather than a side effect.

========================================
3. AUTO SCALING GROUP FUNDAMENTALS
========================================

Three numbers define the group:

Minimum - the floor. The group never goes below this, even under a
scale-in policy.

Maximum - the ceiling. The group never exceeds this, even under heavy
load. This is the cost control.

Desired capacity - the count the group currently aims for. Scaling
policies change this number; the group then launches or terminates to
match it.

aws autoscaling create-auto-scaling-group \
  --auto-scaling-group-name week6-web-asg \
  --launch-template LaunchTemplateName=week6-web-lt,Version='$Latest' \
  --min-size 2 --max-size 4 --desired-capacity 2 \
  --vpc-zone-identifier "SUBNET_A,SUBNET_B" \
  --target-group-arns TARGET_GROUP_ARN \
  --health-check-type ELB \
  --health-check-grace-period 120

--vpc-zone-identifier takes a comma-separated list in a single string, not
space-separated arguments. Listing subnets in two availability zones is
what lets the group balance across them.

Note what is absent: no instance IDs anywhere. The group creates and
destroys instances itself, and anything that refers to a specific instance
ID is working against the model.

========================================
4. ATTACHING TO A TARGET GROUP
========================================

--target-group-arns is the seam between Day 3 and Day 4. With it set, the
group registers every instance it launches into the target group and
deregisters every instance it terminates, including waiting out the
deregistration delay before termination.

That is the whole integration. The listener and its rules are never
touched; they point at a target group whose membership changes
underneath them.

Without it, an Auto Scaling group still maintains instances but nothing
routes traffic to them.

========================================
5. HEALTH CHECK TYPES
========================================

The group decides which instances count as healthy, and the type
determines what it looks at.

EC2 - the default. Only the EC2 instance status checks: is the hypervisor
reporting the instance as running and reachable. An instance whose web
server has crashed passes this check indefinitely.

ELB - also considers the target group's health check. An instance failing
the load balancer's HTTP check is replaced.

ELB is almost always what is wanted. The Day 3 failure injection, stopping
httpd, would not have triggered any replacement under EC2 health checks,
because the instance itself was perfectly healthy. It was the application
that was broken.

aws autoscaling update-auto-scaling-group \
  --auto-scaling-group-name week6-web-asg \
  --health-check-type ELB \
  --health-check-grace-period 300

The grace period is how long after launch the group ignores health checks,
giving user data time to install and start the application. Set it too
short and the group kills instances while they are still booting, then
launches replacements that die the same way. That loop is a classic
self-inflicted outage and it is expensive, because every iteration is a
fresh instance launch.

The grace period should be comfortably longer than the slowest realistic
boot, measured rather than guessed.

========================================
6. SCALING POLICIES
========================================

Target tracking - the default choice

Name a metric and a target value. AWS computes the scaling actions and
manages the CloudWatch alarms.

aws autoscaling put-scaling-policy \
  --auto-scaling-group-name week6-web-asg \
  --policy-name cpu-target-50 \
  --policy-type TargetTrackingScaling \
  --target-tracking-configuration '{
    "PredefinedMetricSpecification": {
      "PredefinedMetricType": "ASGAverageCPUUtilization"
    },
    "TargetValue": 50.0
  }'

Other predefined metrics include ALBRequestCountPerTarget, which scales on
requests per instance rather than CPU and is often a better signal for web
tiers, because a request-bound workload may saturate long before CPU does.

Target tracking scales out aggressively and in conservatively, by design.
Adding capacity too slowly causes an outage; removing it too slowly costs
money. The asymmetry is deliberate.

Step scaling

Different responses at different alarm breach sizes: add one instance at
60 percent CPU, three at 80. More control, more configuration, and it
requires managing CloudWatch alarms directly.

Simple scaling

The original mechanism: one alarm, one action, then a cooldown during
which nothing else happens. Superseded by step scaling and rarely the
right choice now.

Scheduled scaling

Capacity changes by clock, independent of metrics.

aws autoscaling put-scheduled-update-group-action \
  --auto-scaling-group-name week6-web-asg \
  --scheduled-action-name weekday-morning \
  --recurrence "0 8 * * MON-FRI" \
  --min-size 4 --desired-capacity 4

Useful for known patterns such as office hours or a batch window.
Metric-based scaling is reactive and always lags the load; scheduled
scaling anticipates it. The two combine well.

Predictive scaling

Uses machine learning on historical CloudWatch data to forecast load and
pre-provision. Needs weeks of history to be useful.

========================================
7. COOLDOWNS, WARM-UP AND INSTANCE REFRESH
========================================

Cooldown - after a simple scaling action, a period during which further
simple scaling actions are suppressed. It exists to stop the group
reacting to the load spike its own new instances have not yet absorbed.
Target tracking uses instance warm-up instead.

Instance warm-up - how long a newly launched instance is excluded from the
group's aggregated metrics. Without it, an instance that is still booting
reports near-zero CPU, drags the average down, and can trigger an
unnecessary scale-in.

Instance refresh - a rolling replacement of every instance in the group,
which is how a launch template change is deployed.

aws autoscaling start-instance-refresh \
  --auto-scaling-group-name week6-web-asg \
  --preferences '{"MinHealthyPercentage": 50, "InstanceWarmup": 120}'

MinHealthyPercentage controls how much capacity may be unavailable at
once. At 100 the group launches replacements before terminating old
instances, which needs headroom below the maximum size to work at all. A
group with min 2, max 2 and MinHealthyPercentage 100 cannot refresh,
because there is no room to launch anything.

========================================
8. LIFECYCLE HOOKS
========================================

A hook pauses an instance in a transitional state so something can happen
before it proceeds.

aws autoscaling put-lifecycle-hook \
  --auto-scaling-group-name week6-web-asg \
  --lifecycle-hook-name drain-logs \
  --lifecycle-transition autoscaling:EC2_INSTANCE_TERMINATING \
  --heartbeat-timeout 300 \
  --default-result CONTINUE

Launch hooks are used for configuration or registration that must finish
before an instance takes traffic. Terminating hooks are used for draining:
shipping logs, finishing in-flight jobs, deregistering from a service
registry.

The instance stays in Pending:Wait or Terminating:Wait until something
calls complete-lifecycle-action or the heartbeat timeout expires.
--default-result decides what happens on timeout: CONTINUE proceeds,
ABANDON terminates the instance.

A hook with no completion logic simply delays every launch or termination
by the full timeout, which is a common way to make a group mysteriously
slow.

========================================
9. TERMINATION POLICY
========================================

When scaling in, the group chooses which instance to remove. The default
sequence: balance across availability zones first, then the instance using
the oldest launch template version, then the one closest to the next
billing hour.

The AZ-balance-first rule is why scale-in does not undo zone balance.

Alternatives include OldestInstance, NewestInstance, and
ClosestToNextInstanceHour. OldestInstance combined with a launch template
change is a crude rolling deployment, though instance refresh does it
properly.

Instance scale-in protection exempts specific instances from being chosen,
which matters when an instance is doing long-running work that should not
be interrupted.

========================================
10. COST
========================================

The Auto Scaling group itself is free. The cost is entirely the instances
it runs, plus the load balancer in front of them.

Two cost controls matter:

Maximum size is a hard spending ceiling. A runaway scaling policy with
max 4 costs at most four instances. The same policy with max 100 does not.

Scale-in is what makes elasticity save money. A group that scales out and
never scales back in is just a slow way of over-provisioning.

A group with a minimum above zero always runs at least that many
instances, around the clock. For a learning exercise min 2 is correct; it
is also two t3.micro instances billing continuously until the group is
deleted.

Deleting a group with --force-delete terminates its instances. Deleting
without it fails while instances exist, which is a safety feature rather
than an obstacle.

========================================
11. HANDS-ON EXERCISES
========================================

Day 4 rebuilds the Day 3 load balancer, because an Auto Scaling group
without a target group demonstrates only half the behaviour.

Prerequisite: the four-region sweep and the current credit balance.

Exercise 1: rebuild the Day 3 infrastructure

Security group chain, target group, load balancer and listener, exactly as
on Day 3. No instances this time: the Auto Scaling group creates them.

Exercise 2: build the launch template

Encode the Day 3 user data script with base64 -w 0, and create a launch
template referencing the web tier security group and the AMI resolved
through SSM.

Exercise 3: create the Auto Scaling group

Minimum 2, maximum 4, desired 2, across both subnets, attached to the
target group, with ELB health checks and a grace period.

Watch the instances appear without any run-instances call, then watch them
register themselves in the target group and turn healthy.

Exercise 4: self-healing

Terminate one instance manually. Watch the group detect the shortfall,
launch a replacement, and register it. The target group returns to two
healthy targets with no intervention.

This is the exercise that demonstrates the central point: nothing was
repaired, the group simply reconciled reality back to the declared state.

Exercise 5: scaling policy and induced load

Attach a target tracking policy on average CPU. Generate load on the
instances and watch desired capacity rise, then fall when the load stops.

Scale-out typically takes three to five minutes from the alarm, and
scale-in is deliberately slower.

Exercise 6: instance refresh

Create a new launch template version with a changed user data script, then
start an instance refresh and watch instances replaced in a rolling
fashion while the load balancer keeps serving.

========================================
12. TEARDOWN
========================================

Order matters, and the Auto Scaling group goes first, because it will
replace any instance terminated while it still exists.

aws autoscaling delete-auto-scaling-group \
  --auto-scaling-group-name week6-web-asg \
  --force-delete

--force-delete terminates the instances. Terminating instances by hand
while the group is alive does nothing useful: the group launches
replacements immediately.

Wait for the instances to actually disappear before continuing, then
remove the rest in reverse creation order:

aws ec2 delete-launch-template --launch-template-name week6-web-lt
aws elbv2 delete-listener --listener-arn LISTENER_ARN
aws elbv2 delete-load-balancer --load-balancer-arn LOAD_BALANCER_ARN
aws elbv2 wait load-balancers-deleted --load-balancer-arns LOAD_BALANCER_ARN
aws elbv2 delete-target-group --target-group-arn TARGET_GROUP_ARN
aws ec2 delete-security-group --group-id WEB_SECURITY_GROUP_ID
aws ec2 delete-security-group --group-id LOAD_BALANCER_SECURITY_GROUP_ID

Verification:

aws autoscaling describe-auto-scaling-groups --query "AutoScalingGroups[].AutoScalingGroupName" --output text
aws ec2 describe-launch-templates --query "LaunchTemplates[].LaunchTemplateName" --output text
aws elbv2 describe-load-balancers --query "LoadBalancers[].LoadBalancerName" --output text
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
- Self-healing, elasticity and zone balance as separate capabilities
- Launch templates, base64 user data, and immutable versions
- Version references and why $Latest is risky in production
- Minimum, maximum and desired capacity
- Target group attachment as the integration point with Day 3
- EC2 versus ELB health checks, and the grace period
- Target tracking, step, scheduled and predictive scaling
- Cooldowns, instance warm-up and instance refresh
- Lifecycle hooks for launch and termination
- Termination policy and scale-in protection
- Where the cost actually sits

Skills Practiced:
- Encoding user data correctly for a launch template
- Declaring desired state rather than creating instances
- Attaching a group to an existing target group
- Verifying self-healing by terminating an instance deliberately
- Inducing load to observe a scaling policy act
- Performing a rolling replacement with instance refresh
- Tearing down a self-healing resource in the correct order

Key Learnings:
- Launch template user data must be base64 with -w 0; run-instances
  encodes automatically and create-launch-template does not
- --vpc-zone-identifier takes one comma-separated string, not separate
  arguments
- EC2 health checks do not notice a crashed application; ELB health
  checks do
- A grace period shorter than boot time produces a launch-kill-relaunch
  loop
- Instance warm-up prevents a booting instance from dragging the average
  metric down and triggering a false scale-in
- An instance refresh at MinHealthyPercentage 100 needs headroom below
  the maximum size
- A lifecycle hook with no completion logic delays every transition by
  its full timeout
- Maximum size is the real spending ceiling
- Terminating instances by hand while the group exists accomplishes
  nothing; the group replaces them

========================================
NEXT STEPS: Day 5 - High Availability, Monitoring, and Cost Control
========================================
