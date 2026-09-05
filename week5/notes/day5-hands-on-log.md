DAY 5: CLI AUTOMATION - HANDS-ON LOG
Session Record

LEARNING DATE: July 12, 2026
COMPLETED BY: Iman
REGION: us-east-1
ENVIRONMENT: WSL2 Ubuntu on Windows

========================================
1. SESSION SUMMARY
========================================

Built a Python automation script using boto3 that replicates the
manual EC2 and S3 workflows from earlier in the week: listing running
instances, launching an instance and waiting for it to be running,
uploading a file to S3, and terminating the instance with a wait for
full termination.

========================================
2. ENVIRONMENT SETUP
========================================

- Reused the existing virtual environment from Week 3
  (~/devops-week3-env)
- Installed boto3 via pip inside the activated virtual environment
- Verified with: python3 -c "import boto3; print(boto3.__version__)"

========================================
3. SCRIPT CREATED
========================================

- File: week5/scripts/aws_automation.py
- Functions:
  - list_running_instances(): lists all currently running EC2
    instances with their state and public IP
  - launch_instance(): launches an EC2 instance and uses a waiter to
    block until it reaches the running state
  - upload_to_s3(): uploads a local file to a specified S3 bucket
    and key
  - terminate_instance(): terminates an instance and uses a waiter to
    block until it is fully terminated

========================================
4. RESOURCES USED
========================================

- AMI: ami-0ac742fa26982e153 (reused from Day 1/2)
- Instance Type: t3.micro
- Key Pair: week5-key (reused)
- Security Group: SECURITY_GROUP_ID (reused)
- S3 Bucket: iman-devops-week5-2026 (reused)

========================================
5. ISSUES ENCOUNTERED
========================================

1. An instance launched during script testing (INSTANCE_ID)
   was left running after the script run completed, since each script
   execution only tracks the instance it launches, not instances from
   prior runs. Caught by running list_running_instances() again and
   manually terminating the orphaned instance via the AWS CLI.

========================================
6. KEY TAKEAWAYS
========================================

- boto3 waiters (get_waiter) remove the need to manually poll
  resource state in a loop, unlike the manual describe-instances
  checks used in earlier days
- Automation scripts should not be assumed to track resources across
  separate executions; always verify actual AWS state rather than
  trusting a script's own internal memory of what it did
- .get() with a default value prevents KeyError crashes when a field
  (such as PublicIpAddress) may not exist depending on instance state
- Separating ClientError (AWS-side failures) from FileNotFoundError
  (local file issues) allows more specific, useful error messages
- Reusing resource IDs (AMI, key pair, security group, bucket) across
  days confirms these are stable resources independent of individual
  instance lifecycles

========================================
END OF DAY 5 HANDS-ON LOG
========================================
