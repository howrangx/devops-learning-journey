# Day 2: Hands-On Log

## Session Summary

Launched an EC2 instance with a user data script that automatically
installed and started an Apache web server at boot, with no manual
SSH configuration required. Verified the webpage via curl, then
explored the IMDSv2 instance metadata service before terminating.

## Resources Created

### User Data Script
- File: week5/user-data-webserver.sh
- Installs httpd, starts and enables the service, and writes a
  custom index.html embedding the instance hostname

### EC2 Instance (terminated)
- Instance ID: INSTANCE_ID
- AMI: ami-0ac742fa26982e153 (Amazon Linux 2023, minimal, x86_64)
- Instance Type: t3.micro
- Public IP (while running): PUBLIC_IP
- Key Pair: week5-key (reused from Day 1)
- Security Group: SECURITY_GROUP_ID (reused from Day 1)
- Status: terminated at end of session

### Security Group Update
- Added inbound rule for TCP port 80 (HTTP), restricted to own
  public IP /32, alongside the existing port 22 rule from Day 1

## Commands Used

Open HTTP port on existing security group:
aws ec2 authorize-security-group-ingress \
  --group-id SECURITY_GROUP_ID \
  --protocol tcp --port 80 \
  --cidr <own-public-ip>/32

Launch instance with user data:
aws ec2 run-instances \
  --image-id ami-0ac742fa26982e153 \
  --instance-type t3.micro \
  --key-name week5-key \
  --security-group-ids SECURITY_GROUP_ID \
  --user-data file://user-data-webserver.sh \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=week5-day2-webserver}]'

Check instance status:
aws ec2 describe-instances \
  --instance-ids INSTANCE_ID \
  --query "Reservations[].Instances[].[InstanceId,State.Name,PublicIpAddress]" \
  --output table

Verify webpage:
curl http://<public-ip>

Query instance metadata (from inside the instance, via SSH):
curl -s http://169.254.169.254/latest/api/token -X PUT \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" > /tmp/token
curl -s http://169.254.169.254/latest/meta-data/instance-id \
  -H "X-aws-ec2-metadata-token: $(cat /tmp/token)"

Terminate instance:
aws ec2 terminate-instances --instance-ids INSTANCE_ID

## Key Takeaways

- User data scripts allow full first-boot automation, no manual SSH
  configuration needed
- Security groups can be updated after creation to open additional
  ports as new use cases require them
- IMDSv2 requires a token obtained via PUT before metadata can be
  read via GET, a security improvement over the older IMDSv1
- Reusing the key pair and security group from Day 1 confirmed these
  resources persist independently of any individual instance
