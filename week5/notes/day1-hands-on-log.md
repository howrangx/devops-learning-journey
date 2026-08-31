# Day 1: Hands-On Log

## Session Summary

Completed the full AWS Fundamentals loop: explored the default VPC,
created an S3 bucket, and launched, connected to, and terminated an
EC2 instance via the AWS CLI.

## Resources Created

### Default VPC (pre-existing, explored only)
- VPC ID: VPC_ID
- CIDR Block: 172.31.0.0/16
- Region: us-east-1

### S3 Bucket
- Name: iman-devops-week5-2026
- Region: us-east-1
- Contents: test-file.txt (38 bytes)
- Status: still exists (not cleaned up, negligible cost)

### Key Pair
- Name: week5-key
- Private key stored locally at week5/week5-key.pem
- Permissions set to 400
- Added to .gitignore
- Status: still exists, will be reused in later sessions

### Security Group
- Name: week5-sg
- Group ID: SECURITY_GROUP_ID
- VPC: VPC_ID
- Inbound rule: TCP port 22 (SSH), restricted to own public IP /32
- Status: still exists, will be reused in later sessions

### EC2 Instance (terminated)
- Instance ID: INSTANCE_ID
- AMI: ami-0ac742fa26982e153 (Amazon Linux 2023, minimal, x86_64)
- Instance Type: t3.micro (free-tier eligible; t2.micro was not
  eligible on this account)
- Public IP (while running): PUBLIC_IP
- Status: terminated at end of session

## Commands Used

Explore default VPC:
aws ec2 describe-vpcs

List and create S3 resources:
aws s3 ls
aws s3 mb s3://iman-devops-week5-2026 --region us-east-1
aws s3 cp test-file.txt s3://iman-devops-week5-2026/test-file.txt
aws s3 ls s3://iman-devops-week5-2026

Find a free-tier eligible AMI:
aws ec2 describe-images --owners amazon \
  --filters "Name=name,Values=al2023-ami-*-x86_64" "Name=state,Values=available" \
  --query "sort_by(Images, &CreationDate)[-1].[ImageId,Name]" \
  --output table

Create key pair:
aws ec2 create-key-pair --key-name week5-key \
  --query "KeyMaterial" --output text > week5-key.pem
chmod 400 week5-key.pem

Create and configure security group:
aws ec2 create-security-group --group-name week5-sg \
  --description "Week 5 learning security group" \
  --vpc-id VPC_ID
aws ec2 authorize-security-group-ingress \
  --group-id SECURITY_GROUP_ID \
  --protocol tcp --port 22 \
  --cidr <own-public-ip>/32

Find correct free-tier instance type:
aws ec2 describe-instance-types \
  --filters "Name=free-tier-eligible,Values=true" \
  --query "InstanceTypes[].InstanceType" --output table

Launch instance:
aws ec2 run-instances \
  --image-id ami-0ac742fa26982e153 \
  --instance-type t3.micro \
  --key-name week5-key \
  --security-group-ids SECURITY_GROUP_ID \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=week5-learning-instance}]'

Check instance status:
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=week5-learning-instance" \
  --query "Reservations[].Instances[].[InstanceId,State.Name,PublicIpAddress]" \
  --output table

Connect via SSH:
ssh -i week5-key.pem ec2-user@<public-ip>

Terminate instance:
aws ec2 terminate-instances --instance-ids INSTANCE_ID

## Issues Encountered

1. t2.micro was rejected as not free-tier eligible on this account
   (InvalidParameterCombination error). Resolved by querying
   describe-instance-types with the free-tier-eligible filter, which
   returned t3.micro as the correct match instead.

2. CLI output was being piped through a pager by default, requiring
   'q' to exit. Resolved by running:
   aws configure set cli_pager ""

## Key Takeaways

- Free-tier eligible instance types can vary by account; always check
  with describe-instance-types rather than assuming t2.micro.
- Security groups should be scoped as narrowly as possible; SSH access
  was restricted to a single IP address (/32) rather than left open.
- EC2 instances should be stopped or terminated promptly after use to
  avoid unnecessary cost and to stay within free-tier hour limits.
- S3 bucket names are globally unique across all AWS accounts, not
  just within a single account.
