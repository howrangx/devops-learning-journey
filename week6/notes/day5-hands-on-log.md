DAY 5: HIGH AVAILABILITY, MONITORING, AND COST CONTROL - HANDS-ON LOG
Session Record

LEARNING DATE: November 5, 2026
COMPLETED BY: Iman
REGION: us-east-1
ENVIRONMENT: WSL2 Ubuntu on Windows

========================================
1. SESSION OBJECTIVES
========================================

- Analyse the Day 4 architecture by failure domain rather than by
  component
- Create a cost budget that works on a credit-funded account
- Compare gross and net spending with Cost Explorer
- Activate a cost allocation tag
- Build a pipeline from log text to an alarm to an email
- Turn the repeated end-of-day verification into a script with a
  meaningful exit code

Nothing expensive was built. Three outputs were kept deliberately: the
budget, the cost allocation tag, and the script.

========================================
2. FAILURE DOMAIN ANALYSIS
========================================

A thinking exercise on the Day 4 design: an ALB, an Auto Scaling group of
two instances across us-east-1a and us-east-1b, each installing httpd from
the package repository at boot.

Failure 1: us-east-1a goes dark.

In the first minute, requests already routed to us-east-1a fail until the
target is marked unhealthy, then all traffic goes to us-east-1b. The load
balancer node in us-east-1a also dies with the zone. AWS removes it from
DNS, but clients holding a cached address keep trying it for up to the DNS
TTL, so some early errors come from the dead load balancer node rather than
the dead instance.

Over the next five minutes, capacity halves and one instance carries all
traffic. The group launches a replacement, and because us-east-1a is dark,
it launches in us-east-1b. Both instances then sit in one zone until
us-east-1a recovers, at which point the group rebalances.

Failure 2: what the design does not survive.

A region failure. Everything is in us-east-1, so both zones fail together.

A bad deployment that passes the health check. A template version serving
a blank page with status 200 is rolled onto every instance by an instance
refresh, because every health check passes. Two zones do not help, because
both zones run the same broken code.

This is the independence condition from the availability arithmetic in the
notes. Redundancy multiplies failure probabilities only when failures are
independent. A zone outage affects one zone. A bad deployment affects every
copy at once, because every copy is identical. Redundancy protects against
independent failures, never against correlated ones.

An account or credential failure, which removes the control plane for
everything.

Failure 3: the hidden dependency.

During the zone outage, the package repository becomes slow. The
replacement instance boots and runs dnf install -y httpd, which takes longer
than the 120-second grace period. When the grace period ends, the ELB
health check is still failing, so the group marks the instance unhealthy,
terminates it, and launches another, which meets the same slow repository.

That is the launch-kill-relaunch loop from Day 4, where the grace period
prevented it. Here the boot simply outlasts the grace period. Capacity stays
at one instance, and every failed attempt is a fresh billed launch.

The dependency is hidden because the surviving instance already has httpd
installed and is unaffected. It only affects new instances, so it is
invisible in normal operation and appears exactly during recovery. The
recovery path is the part that breaks, at the moment it is needed.

The structural fix is to stop installing software at boot: bake httpd into
a custom AMI built in advance, so a new instance has nothing to download.
This is immutable infrastructure, and it returns with infrastructure as code
from Week 9.

========================================
3. A BUDGET THAT WORKS ON A CREDIT ACCOUNT
========================================

The AWS documentation states that a cost budget's IncludeCredit setting
defaults to true. On an account paying for everything with credits, the net
cost after credits is approximately zero whatever is running, so a default
budget would report zero and never alert, including while a forgotten
resource consumed the credit balance.

The budget was created with credits excluded, using JSON files outside the
repository and the alert address held in a shell variable:

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
read -p "Alert email: " EMAIL

cat > ~/week6-budget.json <<EOF
{
  "BudgetName": "week6-monthly",
  "BudgetLimit": {"Amount": "5", "Unit": "USD"},
  "TimeUnit": "MONTHLY",
  "BudgetType": "COST",
  "CostTypes": {"IncludeCredit": false}
}
EOF

Two notifications: a forecasted alert at 100 percent and an actual alert at
50 percent, both by email.

aws budgets create-budget --account-id $ACCOUNT_ID \
  --budget file://$HOME/week6-budget.json \
  --notifications-with-subscribers file://$HOME/week6-budget-notify.json

file://$HOME/... rather than file://~/..., because the tilde is not
expanded inside a file:// URL.

Verified rather than assumed:

aws budgets describe-budget --account-id $ACCOUNT_ID --budget-name week6-monthly \
  --query "Budget.[BudgetName,BudgetLimit.Amount,TimeUnit,CostTypes.IncludeCredit]"

week6-monthly   5.0   MONTHLY   False

Why 5 USD when actual spend to date was a few cents: the forecasted alert
does the work. A load balancer forgotten early in a month bills around
17 USD over that month, and the projection crosses 5 USD within about a
day, long before actual spend approaches the limit. A low limit with a
forecast alert catches forgotten resources early.

The AWS credit activity "Set up a cost budget using AWS Budgets" showed as
completed afterwards, earning 20 USD in credits. Credit activities now stand
at 60 of 100 USD earned.

========================================
4. COST EXPLORER, AND A SUCCESSFUL EMPTY ANSWER
========================================

Two queries were planned for the period since August 1, grouped by service:
one net of credits and one gross, with the Credit record type excluded. The
JSON response was piped into a small Python formatter written to a file
outside the repository. An earlier inline version embedded Python inside a
bash single-quoted string and depended on escaped quotes, which is fragile
across Python versions; writing the formatter with a quoted heredoc avoided
the problem.

Both queries printed nothing.

Empty output is ambiguous: it could mean nothing was spent, that the
response was shaped differently from what the formatter expected, or that
the formatter filtered everything out. The raw response was saved to a file
with one further request, and inspected locally at no cost:

2026-08-01 groups: 0 estimated: True
2026-09-01 groups: 0 estimated: True
2026-10-01 groups: 0 estimated: True
2026-11-01 groups: 0 estimated: True

with a total of 0 for every month.

The formatter was correct. Cost Explorer returned no services at all, even
gross, including for September, when an RDS instance and two load balancers
had run. The tell was "Estimated": true on August, September and October:
closed, invoiced months should report final figures.

The cause, from the AWS documentation: Cost Explorer is enabled only by
opening it in the console for the first time, and cannot be enabled
through the API. After enabling, the current month takes about 24 hours to
appear and the history a few days longer, with the current month and
previous 13 months prepared. It had never been opened on this account.

The credit-netting problem from the notes was ruled out: its accepted fix
is excluding the Credit charge type, which the gross query already did.

The API did not refuse the query. It returned a well-formed response full
of zeros. This is the same class of failure as the Day 2 teardown command
that ran against an empty variable: a response that looks successful is not
evidence of anything.

Cost Explorer was then enabled in the console. The gross query is to be
re-run once data has been prepared, saved to a file and formatted with:

python3 ~/ce_fmt.py < ~/ce_gross.json

Saving a paid API response to disk and querying the file is worth making a
habit: re-running the API to try a different format costs a cent each time,
re-reading the file costs nothing.

Wider conclusion: cost data lags at least a day even when working, and here
was absent without any error. A budget is a useful backstop but sees only
what the billing data sees. Only listing the resources shows what is running
now.

========================================
5. COST ALLOCATION TAGS
========================================

aws ce list-cost-allocation-tags --status Inactive

aws:ec2launchtemplate:id            AWSGenerated   Inactive
aws:createdBy                       AWSGenerated   Inactive
Name                                UserDefined    Inactive
aws:secretsmanager:owningService    AWSGenerated   Inactive
aws:rds:primaryDBInstanceArn        AWSGenerated   Inactive
aws:ec2launchtemplate:version       AWSGenerated   Inactive
aws:autoscaling:groupName           AWSGenerated   Inactive
Week                                UserDefined    Inactive

Two kinds. Name and Week are user defined, applied explicitly during Days 2
to 4. The aws: prefixed tags were applied by AWS itself, and each traces to
a day this week:

aws:autoscaling:groupName - the Day 4 group tagged every instance it
launched with its own name
aws:ec2launchtemplate:id and version - the same instances recorded which
template version built them
aws:rds:primaryDBInstanceArn and aws:secretsmanager:owningService - the
Day 2 database and the password RDS stored for it in Secrets Manager
aws:createdBy - the identity that created each resource

Activating aws:autoscaling:groupName would allow costs to be split per Auto
Scaling group with no tagging effort at all.

aws ce update-cost-allocation-tags-status \
  --cost-allocation-tags-status TagKey=Week,Status=Active

Result: no errors. Activation applies from now onwards; September costs
will never be attributed to Week=6, because the tag was not active when
they were incurred.

The tag API worked even though cost data did not, which narrowed the
Cost Explorer finding: access was not the problem, prepared data was.

========================================
6. LOG TEXT TO METRIC TO ALARM TO EMAIL
========================================

SNS topic and email subscription:

aws sns create-topic --name week6-alerts
aws sns subscribe --topic-arn $TOPIC_ARN --protocol email --notification-endpoint "$EMAIL"

The subscription returned pending confirmation, received nothing until the
link in the confirmation email was clicked, and then showed a subscription
ARN. Confirmation exists so that SNS cannot be used to subscribe arbitrary
addresses and send them unsolicited mail.

Order mattered: a metric filter only counts events that arrive after it
exists, so the log group, filter and alarm were created before any events
were written. Not retroactive, the same as the cost allocation tag.

aws logs create-log-group --log-group-name /week6/app
aws logs put-retention-policy --log-group-name /week6/app --retention-in-days 1
aws logs create-log-stream --log-group-name /week6/app --log-stream-name manual

aws logs put-metric-filter \
  --log-group-name /week6/app \
  --filter-name error-count \
  --filter-pattern "ERROR" \
  --metric-transformations metricName=AppErrors,metricNamespace=Week6,metricValue=1,defaultValue=0

aws cloudwatch put-metric-alarm \
  --alarm-name week6-app-errors \
  --namespace Week6 --metric-name AppErrors \
  --statistic Sum --period 60 \
  --evaluation-periods 1 --datapoints-to-alarm 1 \
  --threshold 3 --comparison-operator GreaterThanOrEqualToThreshold \
  --treat-missing-data notBreaching \
  --alarm-actions $TOPIC_ARN --ok-actions $TOPIC_ARN

In plain words: if three or more ERROR lines appear within one minute, alarm
and send an email; when it clears, send another.

Retention of one day was set explicitly because log groups never expire by
default.

Six events were written from a JSON file, four of them ERROR lines, one
INFO and one WARN:

aws logs put-log-events --log-group-name /week6/app --log-stream-name manual \
  --log-events file://$HOME/week6-events.json

aws logs filter-log-events --log-group-name /week6/app --filter-pattern "ERROR"

Four lines matched; INFO and WARN were correctly excluded. The pattern
match is case-sensitive, so a line beginning "error" would not be counted.

The alarm read INSUFFICIENT_DATA, Unchecked: Initial alarm creation, when
checked within seconds. Rather than waiting, the preceding stage was
checked, the same pipeline method as Day 4:

aws cloudwatch get-metric-statistics \
  --namespace Week6 --metric-name AppErrors \
  --period 60 --statistics Sum ...

14:22:00   4.0

All four errors in one minute. Then the alarm:

ALARM  Threshold Crossed: 1 out of the last 1 datapoints [4.0] was greater
       than or equal to the threshold (3.0)

and a few minutes later, with no further events written:

OK     Threshold Crossed: no datapoints were received for 1 period and
       1 missing datapoint was treated as [NonBreaching]

Both emails arrived, one for ALARM and one for OK.

The state reason states the answer to the prediction: the alarm recovered
by itself because TreatMissingData was notBreaching. Under the default,
missing, it would have moved to INSUFFICIENT_DATA instead of OK and the OK
email would never have been sent. Under breaching, it would have stayed in
ALARM indefinitely. For an error counter silence means no errors, so
notBreaching is correct; for a heartbeat silence means the sender has died,
and breaching would be correct.

defaultValue=0 on the metric filter did not affect this. It publishes zero
only when log events arrive and fail to match. No events arrived at all, so
there was no data point and the alarm's missing-data rule decided.

========================================
7. THE TEARDOWN CHECK SCRIPT
========================================

Every day this week ended with the same verification listing typed by
hand, and twice that listing caught a resource that a successful command
had left behind. It is now week6/scripts/teardown-check.sh.

It scans a list of regions, overridable with REGIONS, for EC2 instances,
load balancers, Auto Scaling groups, RDS instances, RDS manual snapshots,
available NAT gateways, unattached Elastic IPs, unattached EBS volumes and
EBS snapshots. It prints anything found and exits 1, or prints CLEAN and
exits 0.

The design decision that matters is in its check function: a check whose
AWS command fails is reported and counted as a finding, never treated as
clean.

Test 1, a check that cannot run:

REGIONS="xx-fake-1" ./week6/scripts/teardown-check.sh

Every check reported CHECK FAILED with the endpoint connection error, and
the script printed FOUND and exited 1.

Test 2, a real resource:

ALLOC=$(aws ec2 allocate-address --query AllocationId --output text)
./week6/scripts/teardown-check.sh
aws ec2 release-address --allocation-id $ALLOC
./week6/scripts/teardown-check.sh

The first run reported the unattached Elastic IP in us-east-1 and exited 1.
After release, the second run printed CLEAN and exited 0. An unattached
Elastic IP bills about half a cent per hour, so the test cost nothing
meaningful. A safety check that has only ever been seen to pass is
unproven; this one was seen to fire and then clear.

Why a failed check must count as a finding: if errors were skipped, running
the script with expired credentials would make every check fail silently
and the script would print CLEAN and exit 0. That is the most dangerous
output it could produce, appearing exactly when nothing can be seen.

The same failure has now appeared three ways: a Day 2 teardown command that
succeeded against an empty variable, a Cost Explorer response full of zeros
instead of an error, and, potentially, a script that turns "could not
check" into "nothing there". A safety check must never let no answer look
like all clear. It must fail closed.

The exit code matters as much as the printed text. A CI pipeline can run the
script and refuse to mark a job finished when it returns 1, with no human
reading the output.

========================================
8. TEARDOWN
========================================

Removed:

aws cloudwatch delete-alarms --alarm-names week6-app-errors
aws logs delete-metric-filter --log-group-name /week6/app --filter-name error-count
aws logs delete-log-group --log-group-name /week6/app
aws sns delete-topic --topic-arn $TOPIC_ARN

Deleting the topic removed its email subscription with it.

The custom metric Week6/AppErrors cannot be deleted; CloudWatch has no
delete operation for metrics. It expires after 15 months without new data
and costs nothing while nothing publishes to it.

Kept deliberately:
- Budget week6-monthly, credits excluded, for the remainder of the plan
- Cost allocation tag Week, active
- week6/scripts/teardown-check.sh, committed

Verification:

alarm          empty
log groups     empty
sns topics     empty
budget         week6-monthly   False
teardown-check CLEAN: nothing billable found, exit code 0

========================================
HANDS-ON PRACTICE SUMMARY
========================================

Topics Covered:
- Failure domain analysis, correlated versus independent failures, and
  hidden dependencies on the recovery path
- AWS Budgets and the credit inclusion default
- Cost Explorer enablement and the meaning of an empty response
- AWS-generated and user-defined cost allocation tags
- SNS topics and confirmed subscriptions
- CloudWatch Logs retention, metric filters, and alarms on log content
- Missing data treatment in practice
- An operational check script that fails closed

Skills Practiced:
- Reasoning about what an architecture does not survive
- Configuring and then verifying a budget setting rather than assuming it
- Inspecting a raw API response when formatted output is empty
- Saving a paid API response to disk to avoid paying for re-reads
- Ordering a monitoring pipeline so nothing is created after it is needed
- Testing a safety check against both a failure to run and a real finding

Key Learnings:
- Redundancy protects against independent failures, never against
  correlated ones such as a bad deployment that passes health checks
- A dependency used only during boot is invisible until recovery, which
  is exactly when it fails
- A default budget includes credits and stays silent on a credit-funded
  account
- Cost Explorer must be opened once in the console before it has any data,
  and before that the API returns zeros rather than an error
- Metric filters and cost allocation tags both apply only from creation
  onwards
- The pattern match in a metric filter is case-sensitive
- TreatMissingData decides whether an alarm recovers on silence
- A failed check must count as a finding; no answer must never look like
  all clear

========================================
NEXT STEPS: Weekend Capstone - Highly Available Two-Tier Web Application
========================================
