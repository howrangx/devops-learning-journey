# Week 5 Capstone: Automated Deployment with S3 Config Pull

## Overview

A Python automation script that provisions a complete, working web
server deployment on AWS, end to end, with no manual console clicks
or SSH steps required. The script launches an EC2 instance into a
specific subnet, uses an IAM role to pull website content from S3 at
boot time, verifies the deployment is actually reachable over HTTP,
logs every action locally, and tears everything down afterward.

## Architecture

- VPC: default VPC (vpc-0b4efe0812f9e7c1b)
- Subnet: explicitly targeted (subnet-052b99125e9a5177c, us-east-1a),
  rather than left to AWS's automatic subnet selection
- Security Group: reused from earlier in the week (sg-0e7def8b9c3b64661),
  allowing inbound SSH (22) and HTTP (80) from a single IP
- IAM Role: week5-ec2-s3-read, attached via an instance profile,
  granting the instance read-only access (s3:GetObject) scoped to a
  single S3 bucket, with no credentials stored on the instance itself
- S3 Bucket: iman-devops-week5-2026, holding the deployable web
  content at capstone/index.html
- EC2 Instance: t3.micro, launched from an Amazon Linux 2023 AMI,
  configured via a user data script

## Deployment Flow

1. Python script launches an EC2 instance into the specified subnet,
   with the IAM instance profile attached
2. At boot, the instance's user data script installs httpd and the
   AWS CLI, then uses the instance's IAM role to pull index.html from
   S3 with no manually configured credentials
3. Apache starts and is enabled for future boots
4. The Python script polls the instance's public IP over HTTP,
   retrying with delays until the page responds successfully or
   retries are exhausted
5. All actions (launch, running state, verification attempts, success
   or failure, termination) are logged with timestamps to a local log
   file, in addition to being printed to the terminal
6. The instance is terminated automatically once verification
   completes (successful or not)

## Why an IAM Role Instead of Access Keys

The instance needs permission to read from S3, but hardcoding AWS
access keys into a user data script or AMI would mean any process or
person with access to the instance could extract those credentials.
An IAM role attached via an instance profile avoids this entirely:
AWS issues temporary, automatically rotated credentials to the
instance behind the scenes, scoped to only the specific permissions
granted (in this case, read-only access to one bucket). This follows
the principle of least privilege and is the AWS-recommended pattern
for granting instances access to other AWS services.

## Files

- scripts/capstone_deploy.py - main automation script
- capstone-user-data.sh - boot-time script run on the instance
- capstone-config.html - source file for the deployed web content
- logs/capstone-deploy.log - execution log, generated on each run

## How to Run

1. Ensure the AWS CLI is configured and the devops-week3-env virtual
   environment has boto3 and requests installed
2. Activate the virtual environment:
   source ~/devops-week3-env/bin/activate
3. Run from the repository root (paths are relative to root):
   python3 week5/scripts/capstone_deploy.py
4. Review output in the terminal and in week5/logs/capstone-deploy.log

## Issues Encountered During Development

1. A function definition (verify_site) failed to save correctly on
   first attempt, causing a NameError when the script tried to call
   it. Diagnosed using grep to list all function definitions and
   their line numbers, then corrected by re-inserting the missing
   function in the correct location before the main execution block.

2. Running the script from inside the week5/ directory caused a
   doubled path error (week5/week5/logs/...), since the script's file
   paths are relative to the repository root. Resolved by always
   running the script from the repository root going forward.

3. An orphaned running instance resulted from the script crashing
   before reaching its cleanup step, requiring manual termination via
   the AWS CLI. This reinforced the importance of always verifying
   actual AWS state after any script failure, rather than assuming
   cleanup occurred.

## Key Takeaways

- IAM roles and instance profiles allow EC2 instances to access other
  AWS services securely, without embedding credentials anywhere
- Retry logic with delays is necessary when verifying a freshly
  booted instance, since user data scripts take time to complete
  after the instance itself reaches the running state
- Logging to both console and file simultaneously provides immediate
  feedback during execution and a permanent record afterward
- Relative file paths in scripts are dependent on the working
  directory the script is run from, which should be documented
  clearly to avoid confusion
- Script failures mid-execution can leave real, cost-incurring AWS
  resources running; error handling and manual verification both
  matter
