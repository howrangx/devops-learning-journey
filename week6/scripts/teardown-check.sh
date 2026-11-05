#!/bin/bash
# teardown-check.sh
# Report AWS resources that keep billing after a session ends.
# Exit 0 when nothing is found. Exit 1 when anything is found,
# or when any check could not be completed.
#
# Usage:  ./week6/scripts/teardown-check.sh
#         REGIONS="us-east-1 eu-west-1" ./week6/scripts/teardown-check.sh

set -u

REGIONS="${REGIONS:-us-east-1 eu-north-1 eu-central-1 eu-west-1}"
found=0

# check REGION LABEL command...
# Runs one AWS CLI query in one region and reports anything returned.
# A check that errors is treated as a finding, never as "clean".
check() {
  local region="$1" label="$2"
  shift 2
  local out
  if ! out=$("$@" --region "$region" --output text 2>&1); then
    echo "  [$region] $label: CHECK FAILED - $out"
    found=1
    return
  fi
  if [ -n "$out" ] && [ "$out" != "None" ]; then
    echo "  [$region] $label:"
    echo "$out" | sed 's/^/      /'
    found=1
  fi
}

echo "Checking regions: $REGIONS"

for r in $REGIONS; do
  check "$r" "EC2 instances" aws ec2 describe-instances \
    --filters "Name=instance-state-name,Values=pending,running,stopping,stopped" \
    --query "Reservations[].Instances[].[InstanceId,State.Name,InstanceType]"
  check "$r" "Load balancers" aws elbv2 describe-load-balancers \
    --query "LoadBalancers[].[LoadBalancerName,State.Code]"
  check "$r" "Auto Scaling groups" aws autoscaling describe-auto-scaling-groups \
    --query "AutoScalingGroups[].[AutoScalingGroupName,DesiredCapacity]"
  check "$r" "RDS instances" aws rds describe-db-instances \
    --query "DBInstances[].[DBInstanceIdentifier,DBInstanceStatus]"
  check "$r" "RDS manual snapshots" aws rds describe-db-snapshots --snapshot-type manual \
    --query "DBSnapshots[].[DBSnapshotIdentifier,AllocatedStorage]"
  check "$r" "NAT gateways" aws ec2 describe-nat-gateways \
    --query "NatGateways[?State=='available'].[NatGatewayId]"
  check "$r" "Unattached Elastic IPs" aws ec2 describe-addresses \
    --query "Addresses[?AssociationId==null].[PublicIp,AllocationId]"
  check "$r" "Unattached EBS volumes" aws ec2 describe-volumes \
    --filters "Name=status,Values=available" --query "Volumes[].[VolumeId,Size]"
  check "$r" "EBS snapshots" aws ec2 describe-snapshots --owner-ids self \
    --query "Snapshots[].[SnapshotId,VolumeSize]"
done

if [ "$found" -eq 0 ]; then
  echo "CLEAN: nothing billable found"
  exit 0
fi
echo "FOUND: resources or failed checks listed above"
exit 1
