DAY 5: HIGH AVAILABILITY, MONITORING, AND COST CONTROL
Command Reference and Learning Notes

LEARNING DATE: November 4, 2026
COMPLETED BY: Iman

========================================
1. WHAT HIGH AVAILABILITY ACTUALLY MEANS
========================================

High availability is not a feature that is switched on. It is the property
that a system keeps working when some of its parts do not, and it is only
ever defined relative to a specific failure. A system can be highly
available against an instance failure and completely unavailable during a
zone failure.

The useful question is never "is this highly available" but "what is the
largest thing that can fail while this keeps serving".

Failure domains in AWS, smallest to largest:

Process - an application crashes on a healthy machine
Instance - a virtual machine stops, or its host fails
Availability zone - one or more datacentres lose power or connectivity
Region - an entire region degrades, which is rare but has happened
Account or control plane - credentials revoked, a service API degraded

Each layer of the Week 6 architecture addresses one of these:

ELB health checks handle process failure
Auto Scaling handles instance failure
Two subnets in two zones handle zone failure
Nothing built this week handles region failure

Two numbers define the requirement:

Recovery time objective, RTO - how long the system may be down
Recovery point objective, RPO - how much data may be lost

A static website might accept an RTO of an hour and an RPO of a day. A
payments system might need an RTO of seconds and an RPO of zero. The
architecture follows from those numbers, not the other way around.

Availability arithmetic

If one zone is available 99.5 percent of the time and zone failures are
independent, two zones serving the same traffic are both unavailable only
0.5 percent of 0.5 percent of the time:

1 - (0.005 x 0.005) = 0.999975

That is roughly 99.997 percent, from components that are individually much
worse. Redundancy multiplies the probabilities of failure rather than
adding them. The calculation depends entirely on the failures being
independent, which is exactly why the second copy must be in a different
zone: two instances in the same zone share every zone-level failure, and
the multiplication does not apply.

Every additional nine costs more than the last. Moving from 99.9 to 99.99
percent reduces permitted downtime from about 8.8 hours a year to about
53 minutes, and usually requires changing the architecture, not tuning it.

========================================
2. FAILURE DOMAINS IN THE DAY 4 ARCHITECTURE
========================================

Walking the Day 4 design layer by layer, asking what happens when each part
fails:

The Application Load Balancer is a managed service with a node in each
selected zone. It is not a single point of failure within the region.

The Auto Scaling group spans us-east-1a and us-east-1b. Losing one zone
leaves one instance serving while the group launches replacements in the
surviving zone.

Capacity during a zone failure halves until replacements are healthy. A
group sized to exactly the load it must carry is not highly available
against a zone failure; it is merely self-healing afterwards. Surviving a
zone loss without degradation means running enough headroom in each zone
to carry the full load alone.

The single RDS instance from Day 2, if added, would be a single point of
failure: one instance, one zone. Multi-AZ removes that, at roughly double
the cost.

The region is a single point of failure for everything. Addressing it means
a second region, data replication, and DNS failover, which is a different
order of cost and complexity.

Hidden dependencies are the failures architecture diagrams omit: the
package repository the user data script downloads httpd from, the SSM
parameter the AMI is resolved through, and the IAM service-linked role. A
zone failure that also slows the package mirror produces replacement
instances that boot but never become healthy.

========================================
3. CLOUDWATCH METRICS
========================================

A metric is a time-ordered set of data points identified by three things:

Namespace - the service that publishes it, for example AWS/EC2
Metric name - for example CPUUtilization
Dimensions - name and value pairs narrowing it, for example
  InstanceId=... or AutoScalingGroupName=...

The same metric name with different dimensions is a different metric. Day
4 queried CPUUtilization with the AutoScalingGroupName dimension, which
AWS aggregates across all instances in the group.

Listing what exists:

aws cloudwatch list-metrics --namespace AWS/EC2 \
  --query "Metrics[].[MetricName,Dimensions[0].Name]" --output text | sort -u

Resolution and monitoring tier:

Basic monitoring - five-minute data points, free
Detailed monitoring - one-minute data points, billed per instance
High-resolution custom metrics - down to one second

Day 4 measured the effect directly: three high data points took three
minutes to accumulate under detailed monitoring, and would have taken
fifteen under basic monitoring.

Statistics are chosen at query time: Average, Sum, Minimum, Maximum,
SampleCount, and percentiles such as p99. Average hides outliers. Day 4
showed an average sitting exactly on target while two instances were at
100 percent; Maximum would have revealed them.

Retention depends on resolution. One-minute data is kept for 15 days,
five-minute data for 63 days, one-hour data for 455 days. Older data is
not deleted but aggregated to coarser resolution.

========================================
4. CLOUDWATCH ALARMS
========================================

An alarm watches one metric and is in one of three states:

OK - the metric is within the threshold
ALARM - the metric has breached the threshold
INSUFFICIENT_DATA - not enough data points to decide

Day 4 observed all three on the target tracking alarms, in that order
reversed: INSUFFICIENT_DATA on creation, OK once data arrived, ALARM after
three high minutes.

The parameters that control behaviour:

Period - the length of each data point, for example 60 seconds
EvaluationPeriods - how many recent periods are examined
DatapointsToAlarm - how many of those must breach

Three of three means three consecutive breaching periods. Two of three
tolerates one good period in the middle, which suppresses flapping on a
noisy metric without ignoring a sustained problem.

TreatMissingData decides what a gap means:

missing - the default; the alarm moves towards INSUFFICIENT_DATA
notBreaching - gaps count as healthy
breaching - gaps count as failing
ignore - the current state is kept

The right choice depends on what silence means. For an error-count metric,
silence means no errors, so notBreaching is correct. For a heartbeat
metric, silence means the thing that sends the heartbeat has died, so
breaching is correct. Choosing wrongly produces an alarm that stays quiet
through exactly the outage it exists to report.

========================================
5. SNS FOR NOTIFICATIONS
========================================

An alarm changing state does nothing visible on its own. It needs an
action, and the usual action is publishing to an SNS topic.

SNS is publish and subscribe. A topic is a named channel; publishers send
messages to it; subscribers receive copies. One alarm can notify email, an
SMS number, an HTTPS endpoint, an SQS queue and a Lambda function at once,
without the alarm knowing about any of them.

aws sns create-topic --name week6-alerts

aws sns subscribe --topic-arn TOPIC_ARN \
  --protocol email --notification-endpoint EMAIL_ADDRESS

An email subscription starts in PendingConfirmation and receives nothing
until the link in the confirmation email is clicked. This is deliberate:
without it, anyone could subscribe any address to a topic and use SNS to
send unsolicited mail.

aws sns list-subscriptions-by-topic --topic-arn TOPIC_ARN \
  --query "Subscriptions[].[Protocol,SubscriptionArn]" --output text

A subscription still pending confirmation shows PendingConfirmation in
place of an ARN.

SNS returns in Week 7 alongside SQS, where the decoupling it provides
becomes the main subject rather than a notification mechanism.

========================================
6. CLOUDWATCH LOGS
========================================

Structure:

Log group - a container, usually one per application or component
Log stream - one sequence of events, usually one per instance or process
Log event - a timestamp and a message

Retention is set per log group, and the default is never expire. This is a
genuine cost trap. Log storage is cheap per gigabyte but grows without
bound, and a busy application can accumulate gigabytes per day forever
unless retention is set.

aws logs create-log-group --log-group-name /week6/app
aws logs put-retention-policy --log-group-name /week6/app --retention-in-days 1

Allowed retention values are fixed: 1, 3, 5, 7, 14, 30, 60, 90 days and
upwards. Arbitrary numbers are rejected.

Writing events directly, without an agent:

aws logs create-log-stream --log-group-name /week6/app --log-stream-name manual
aws logs put-log-events --log-group-name /week6/app --log-stream-name manual \
  --log-events timestamp=$(date +%s000),message="ERROR database timeout"

Timestamps are in milliseconds since the epoch. date +%s gives seconds, so
the three appended zeros convert it.

Metric filters turn log text into a metric:

aws logs put-metric-filter \
  --log-group-name /week6/app \
  --filter-name error-count \
  --filter-pattern "ERROR" \
  --metric-transformations \
    metricName=AppErrors,metricNamespace=Week6,metricValue=1,defaultValue=0

Every log event matching the pattern adds 1 to the AppErrors metric in the
custom Week6 namespace. defaultValue=0 publishes zero for periods with no
matches, so the metric reports silence as zero rather than as missing.

This is how an alarm can fire on something that only appears in logs, with
no change to the application.

Searching logs:

aws logs filter-log-events --log-group-name /week6/app --filter-pattern "ERROR" \
  --query "events[].message" --output text

On an instance, the CloudWatch agent ships files such as /var/log/messages
or application logs into log groups automatically. That requires an IAM
role on the instance with permission to write logs, which is the same
instance profile pattern as Day 1.

========================================
7. TAGGING AND COST ALLOCATION
========================================

A tag is a key and value attached to a resource. Day 3 and Day 4 tagged
every instance with Week=6 and a Name. Tags cost nothing and are the only
practical way to answer "what is this for, who owns it, and what does it
cost" across hundreds of resources.

A minimal useful tagging strategy:

Name - human readable identifier
Project or Week - which piece of work it belongs to
Owner - who to ask before deleting it
Environment - development, staging, production

Tags only help if they are applied consistently. A strategy that is
followed on half the resources produces a cost report that is wrong in a
way that is hard to notice.

Cost allocation tags

Tags on resources do not appear in billing data until they are activated as
cost allocation tags. Activation applies from that moment forwards; it does
not tag historical costs retroactively. A newly used tag key can take up to
24 hours to become available for activation.

aws ce list-cost-allocation-tags --status Inactive \
  --query "CostAllocationTags[].[TagKey,Type,Status]" --output text

aws ce update-cost-allocation-tags-status \
  --cost-allocation-tags-status TagKey=Week,Status=Active

The ce commands are the Cost Explorer API, which is billed per request. See
section 9.

========================================
8. AWS BUDGETS
========================================

A budget compares actual or forecast spending against a limit and notifies
when a threshold is crossed. It is the single most important safety net on
a learning account, because it catches exactly the failure every teardown
check in this week exists to prevent: a resource left running.

Budget types:

Cost - dollars spent
Usage - units consumed, for example EC2 hours
Savings Plans and Reservation - utilisation and coverage of commitments

Notification thresholds can be on actual spend, which has already
happened, or forecasted spend, which AWS projects to the end of the period.
A forecasted alert is the useful one for catching a forgotten resource
early: a load balancer left running on the second of the month produces a
forecast well over budget within a day, long before the actual figure
crosses anything.

The trap for a credit-funded account

By default a cost budget includes credits in its calculation. The AWS
documentation states the default value of IncludeCredit is true.

On an account paying for everything with credits, the net cost after
credits is approximately zero no matter what is running. A default budget
therefore reports zero spend and never alerts, including while a NAT
gateway quietly consumes the credit balance.

The fix is to exclude credits, so the budget tracks gross usage, which is
what the credits are being spent on:

"CostTypes": {"IncludeCredit": false}

Verify the setting after creation rather than assuming it:

aws budgets describe-budget --account-id ACCOUNT_ID --budget-name week6-monthly \
  --query "Budget.CostTypes.IncludeCredit"

Budgets update several times a day, not in real time. They are a safety
net for forgotten resources, not a live meter.

========================================
9. COST EXPLORER
========================================

Cost Explorer shows historical and forecast spending, groupable by
service, region, usage type, or activated cost allocation tag.

In the console it is free. Through the API it is billed at 0.01 USD per
request, including each page of a paginated response. Trivial for
occasional queries, and a real cost for a dashboard or script that polls
it every minute: that pattern costs about 14 USD per day.

One query for the previous month grouped by service:

aws ce get-cost-and-usage \
  --time-period Start=$(date -u -d '-30 days' +%Y-%m-%d),End=$(date -u +%Y-%m-%d) \
  --granularity MONTHLY \
  --metrics UnblendedCost \
  --group-by Type=DIMENSION,Key=SERVICE \
  --query "ResultsByTime[].Groups[].[Keys[0],Metrics.UnblendedCost.Amount]" \
  --output text

The same credit consideration applies as for budgets. Filtering out the
Credit record type shows gross usage rather than the net amount after
credits:

--filter '{"Not": {"Dimensions": {"Key": "RECORD_TYPE", "Values": ["Credit"]}}}'

Cost data lags by up to a day. Cost Explorer answers "what did this cost",
never "what is running now"; only the resource listings answer that.

========================================
10. BILLING ALARMS
========================================

The older mechanism, predating Budgets: CloudWatch publishes an
EstimatedCharges metric in the AWS/Billing namespace, and a normal alarm
can watch it.

Two constraints: billing alerts must first be enabled in the Billing
preferences, and the metric exists only in us-east-1 regardless of where
resources run.

Budgets supersede it for most purposes, because they support forecasts,
filters by service or tag, and the credit setting above. Billing alarms
remain useful when an alarm needs to drive an action that only CloudWatch
supports.

========================================
11. VERIFICATION AS A TOOL
========================================

Every day this week ended with the same multi-service, multi-region
verification listing, typed or pasted by hand. Days 2 and 4 both showed
why it matters: commands reported success while resources remained.

A check that is run manually is a check that will eventually be skipped. A
script turns it into a single command with an unambiguous result, and an
exit code that other automation can act on: zero when the account is
clean, non-zero when anything billable is found.

That is the shape of most operational tooling. A procedure performed
correctly by hand three times is a candidate for a script, and the script
becomes the procedure.

========================================
12. HANDS-ON EXERCISES
========================================

Nothing in this day requires a load balancer, Auto Scaling group or
database. The resources created are cheap or free, and three are kept
deliberately at the end.

Exercise 1: failure domain analysis

Without running anything, list every component of the Day 4 architecture
and state what happens to the service when each fails, including the hidden
dependencies. Identify which failures the design survives, which it
recovers from after a degradation, and which it does not survive at all.

Exercise 2: a budget that actually works on a credit account

Create a monthly cost budget with credits excluded, a forecasted alert and
an actual alert, delivered by email. Then read the budget back and confirm
IncludeCredit is false.

Exercise 3: what has actually been spent

Two Cost Explorer queries for the last 30 days by service: one net of
credits, one gross. Two requests, two cents. Compare them.

Exercise 4: cost allocation tags

List the inactive cost allocation tags and activate Week.

Exercise 5: logs to metric to alarm to email

Create an SNS topic and confirm an email subscription. Create a log group
with one-day retention, a metric filter counting ERROR lines, and an alarm
on the resulting metric that notifies the topic. Write error events to the
log and watch the alarm fire and the email arrive.

Exercise 6: the teardown check script

Write week6/scripts/teardown-check.sh: scan several regions for running
instances, load balancers, Auto Scaling groups, RDS instances, NAT
gateways, unattached Elastic IPs and available volumes, print what it
finds, and exit non-zero if anything is found.

========================================
13. TEARDOWN
========================================

Removed at the end of the day:

aws cloudwatch delete-alarms --alarm-names week6-app-errors
aws logs delete-metric-filter --log-group-name /week6/app --filter-name error-count
aws logs delete-log-group --log-group-name /week6/app
aws sns delete-topic --topic-arn TOPIC_ARN

Deleting a topic removes its subscriptions with it.

Kept deliberately, at no cost:

The budget, which should exist for the rest of the plan. Removing the
safety net at the end of the day it was built would defeat its purpose.

The Week cost allocation tag activation.

The teardown check script, committed to the repository.

Verification:

./week6/scripts/teardown-check.sh

========================================
HANDS-ON PRACTICE SUMMARY
========================================

Topics Covered:
- High availability as survival of a named failure
- Failure domains from process to region, and RTO and RPO
- Availability arithmetic and why independence is required
- CloudWatch metrics, dimensions, resolution and statistics
- Alarm states, evaluation periods and missing data treatment
- SNS topics and confirmed subscriptions
- CloudWatch Logs groups, streams, retention and metric filters
- Tagging strategy and cost allocation tags
- AWS Budgets and the credit inclusion default
- Cost Explorer and its per-request API pricing
- Billing alarms as the older mechanism
- Turning a repeated manual check into a script

Skills Practiced:
- Analysing an architecture by failure domain rather than by component
- Configuring a budget correctly for a credit-funded account and
  verifying the setting
- Comparing gross and net cost
- Building a pipeline from log text to an email notification
- Writing an operational check script with a meaningful exit code

Key Learnings:
- High availability only means something relative to a specific failure
- Redundancy multiplies failure probabilities only when failures are
  independent; two copies in one zone share every zone failure
- Surviving a zone loss without degradation requires headroom in each
  zone, not just a group that self-heals afterwards
- Average hides outliers; Maximum and percentiles reveal them
- TreatMissingData decides whether silence means healthy or failing
- An email subscription receives nothing until confirmed
- Log groups never expire by default
- Cost allocation tags apply only from activation onwards
- A default budget includes credits and stays silent on a credit-funded
  account
- The Cost Explorer API costs money per request; the console does not
- A check performed by hand three times should become a script

========================================
NEXT STEPS: Weekend Capstone - Highly Available Two-Tier Web Application
========================================
