#!/bin/bash
# capstone-teardown.sh
# Remove the Week 6 capstone environment in dependency order.
#
# Usage:  ./week6/scripts/capstone-teardown.sh [state-file]
#         The state file defaults to ~/capstone.env and holds every
#         resource ID recorded during the build.
#
# Dependencies run the other way from creation, and several deletions
# are asynchronous, so each step waits until AWS reports the resource
# gone before the next step starts. A resource that is already gone
# counts as deleted, so the script can be re-run after a partial
# failure. Any other error stops the script, because every later step
# depends on the earlier ones.
#
# Exit 0 only when every step succeeded and teardown-check.sh reports
# CLEAN. On success the state file is renamed so it cannot be reused.

set -uo pipefail

STATE_FILE="${1:-$HOME/capstone.env}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LAUNCH_TEMPLATE="capstone-app-lt"
DB_SUBNET_GROUP="capstone-db-subnets"
ALARMS="capstone-target-5xx capstone-unhealthy-hosts"
SSM_POLICY_ARN="arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
POLL_SECONDS=15

# Error text that means the resource no longer exists.
GONE='NotFound|NoSuchEntity|not found|does not exist|Gateway.NotAttached|already being deleted'
# Error text that means another resource still holds a reference to it,
# usually a network interface that AWS has not finished releasing.
BUSY='DependencyViolation|InUse|in use|ResourceInUse|dependent object'

[ -r "$STATE_FILE" ] || { echo "State file not found: $STATE_FILE" >&2; exit 1; }
# shellcheck source=/dev/null
source "$STATE_FILE"

missing=""
for name in VPC_ID PUB_A PUB_B APP_A APP_B DB_A DB_B IGW_ID RT_PUB RT_APP_A \
    RT_APP_B RT_DB ALB_SG APP_SG DB_SG DB_ID SECRET_ARN POLICY_ARN ROLE PROFILE \
    EIP_A EIP_B NAT_A NAT_B TG_ARN ALB_ARN LISTENER_ARN ASG_NAME TOPIC_ARN; do
  [ -n "${!name:-}" ] || missing="$missing $name"
done
if [ -n "$missing" ]; then
  echo "Missing from $STATE_FILE:$missing" >&2
  echo "Nothing was deleted. An empty ID would make a delete call skip silently." >&2
  exit 1
fi

step() { printf '\n=== %s\n' "$*"; }

# remove LABEL command...
# Run one delete call. Success and "already gone" both count as done.
# A "still in use" error is retried for up to five minutes.
remove() {
  local label="$1" output attempt
  shift
  for attempt in $(seq 1 20); do
    if output=$("$@" 2>&1); then
      echo "  deleted: $label"
      return 0
    fi
    if grep -qE "$GONE" <<<"$output"; then
      echo "  already gone: $label"
      return 0
    fi
    if grep -qE "$BUSY" <<<"$output"; then
      echo "  $label still in use, retrying ($attempt/20)"
      sleep "$POLL_SECONDS"
      continue
    fi
    echo "  FAILED: $label" >&2
    echo "$output" >&2
    exit 1
  done
  echo "  FAILED: $label still in use after $((20 * POLL_SECONDS))s" >&2
  exit 1
}

# wait_for_zero LABEL TRIES command...
# Repeat a count query until it prints 0. A failed query never counts
# as zero, and the wait is bounded so a stuck deletion stops the script.
wait_for_zero() {
  local label="$1" tries="$2" count attempt
  shift 2
  for attempt in $(seq 1 "$tries"); do
    count=$("$@" --output text 2>/dev/null) || count="unknown"
    if [ "$count" = "0" ]; then
      echo "  confirmed gone: $label"
      return 0
    fi
    echo "  waiting for $label: $count remaining ($attempt/$tries)"
    sleep "$POLL_SECONDS"
  done
  echo "  FAILED: $label still present after $((tries * POLL_SECONDS))s" >&2
  exit 1
}

echo "Tearing down the capstone environment recorded in $STATE_FILE"

step "1. Auto Scaling group and its instances"
remove "Auto Scaling group $ASG_NAME" aws autoscaling delete-auto-scaling-group \
  --auto-scaling-group-name "$ASG_NAME" --force-delete
wait_for_zero "Auto Scaling group" 40 aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names "$ASG_NAME" --query "length(AutoScalingGroups)"
wait_for_zero "group instances" 40 aws ec2 describe-instances \
  --filters "Name=tag:aws:autoscaling:groupName,Values=$ASG_NAME" \
            "Name=instance-state-name,Values=pending,running,shutting-down,stopping,stopped" \
  --query "length(Reservations[].Instances[])"

step "2. Launch template"
remove "launch template $LAUNCH_TEMPLATE" aws ec2 delete-launch-template \
  --launch-template-name "$LAUNCH_TEMPLATE"

step "3. Listener, load balancer, target group"
remove "listener" aws elbv2 delete-listener --listener-arn "$LISTENER_ARN"
remove "load balancer" aws elbv2 delete-load-balancer --load-balancer-arn "$ALB_ARN"
wait_for_zero "load balancer" 40 aws elbv2 describe-load-balancers \
  --query "length(LoadBalancers[?LoadBalancerArn=='$ALB_ARN'])"
remove "target group" aws elbv2 delete-target-group --target-group-arn "$TG_ARN"

step "4. RDS instance and DB subnet group"
remove "RDS instance $DB_ID" aws rds delete-db-instance --db-instance-identifier "$DB_ID" \
  --skip-final-snapshot --delete-automated-backups
wait_for_zero "RDS instance" 80 aws rds describe-db-instances \
  --filters "Name=db-instance-id,Values=$DB_ID" --query "length(DBInstances)"
remove "DB subnet group $DB_SUBNET_GROUP" aws rds delete-db-subnet-group \
  --db-subnet-group-name "$DB_SUBNET_GROUP"
# RDS owns the managed master secret and removes it with the instance.
# This only reports; it does not delete a secret RDS still manages.
if secret_state=$(aws secretsmanager describe-secret --secret-id "$SECRET_ARN" \
    --query "DeletedDate" --output text 2>&1); then
  if [ "$secret_state" = "None" ]; then
    echo "  WARNING: database secret still exists and is not scheduled for deletion" >&2
  else
    echo "  database secret scheduled for deletion on $secret_state"
  fi
elif grep -qE "$GONE" <<<"$secret_state"; then
  echo "  confirmed gone: database secret"
else
  echo "  WARNING: database secret state could not be checked: $secret_state" >&2
fi

step "5. NAT gateways"
remove "NAT gateway A" aws ec2 delete-nat-gateway --nat-gateway-id "$NAT_A"
remove "NAT gateway B" aws ec2 delete-nat-gateway --nat-gateway-id "$NAT_B"
wait_for_zero "NAT gateways" 40 aws ec2 describe-nat-gateways \
  --filter "Name=nat-gateway-id,Values=$NAT_A,$NAT_B" \
  --query "length(NatGateways[?State!='deleted'])"

step "6. Elastic IPs"
remove "Elastic IP A" aws ec2 release-address --allocation-id "$EIP_A"
remove "Elastic IP B" aws ec2 release-address --allocation-id "$EIP_B"

step "7. Internet gateway"
remove "internet gateway attachment" aws ec2 detach-internet-gateway \
  --internet-gateway-id "$IGW_ID" --vpc-id "$VPC_ID"
remove "internet gateway" aws ec2 delete-internet-gateway --internet-gateway-id "$IGW_ID"

step "8. Network interfaces released, then subnets, route tables, security groups, VPC"
wait_for_zero "network interfaces in the VPC" 40 aws ec2 describe-network-interfaces \
  --filters "Name=vpc-id,Values=$VPC_ID" --query "length(NetworkInterfaces)"
for subnet in "$PUB_A" "$PUB_B" "$APP_A" "$APP_B" "$DB_A" "$DB_B"; do
  remove "subnet $subnet" aws ec2 delete-subnet --subnet-id "$subnet"
done
for table in "$RT_PUB" "$RT_APP_A" "$RT_APP_B" "$RT_DB"; do
  remove "route table $table" aws ec2 delete-route-table --route-table-id "$table"
done
# Each group is referenced by the rules of the one after it in the chain
# ALB -> app -> database, so the chain is removed from the far end.
remove "database security group" aws ec2 delete-security-group --group-id "$DB_SG"
remove "app security group" aws ec2 delete-security-group --group-id "$APP_SG"
remove "load balancer security group" aws ec2 delete-security-group --group-id "$ALB_SG"
remove "VPC" aws ec2 delete-vpc --vpc-id "$VPC_ID"

step "9. IAM instance profile, role, customer managed policy"
remove "role in instance profile" aws iam remove-role-from-instance-profile \
  --instance-profile-name "$PROFILE" --role-name "$ROLE"
remove "instance profile $PROFILE" aws iam delete-instance-profile \
  --instance-profile-name "$PROFILE"
remove "SSM policy attachment" aws iam detach-role-policy \
  --role-name "$ROLE" --policy-arn "$SSM_POLICY_ARN"
remove "secret policy attachment" aws iam detach-role-policy \
  --role-name "$ROLE" --policy-arn "$POLICY_ARN"
remove "role $ROLE" aws iam delete-role --role-name "$ROLE"
remove "secret read policy" aws iam delete-policy --policy-arn "$POLICY_ARN"

step "10. Alarms and SNS topic"
# shellcheck disable=SC2086
remove "alarms" aws cloudwatch delete-alarms --alarm-names $ALARMS
remove "SNS topic and its subscriptions" aws sns delete-topic --topic-arn "$TOPIC_ARN"

step "11. Verification"
if ! "$SCRIPT_DIR/teardown-check.sh"; then
  echo "Teardown steps finished but teardown-check.sh did not report CLEAN." >&2
  echo "State file kept at $STATE_FILE for a re-run." >&2
  exit 1
fi

archived="$STATE_FILE.removed-$(date -u +%Y%m%dT%H%M%SZ)"
mv "$STATE_FILE" "$archived"
echo "State file archived as $archived"
echo "Capstone teardown complete."
