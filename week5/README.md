# Week 5: AWS Fundamentals Part 1

## Overview

The core AWS services that everything else builds on: EC2 for compute, S3
for storage, and VPC for networking. Provisioning is done through the AWS
CLI rather than the console wherever possible, so that every step is
reproducible and reviewable, which is the habit the Infrastructure as Code
weeks depend on.

## Prerequisites

- AWS account with billing alerts configured
- AWS CLI installed and configured
- IAM user with programmatic access

## Learning Objectives

- Understand AWS global infrastructure: regions and availability zones
- Launch, configure and terminate EC2 instances
- Use user data scripts, EBS volumes and instance metadata
- Create and manage S3 buckets, versioning, lifecycle rules and policies
- Build VPC subnets, route tables and security groups
- Automate AWS operations with boto3
- Track spending and avoid unexpected charges

## Daily Structure

- Day 1: AWS fundamentals - EC2, S3 and VPC basics
- Day 2: EC2 deep dive - user data, EBS, IMDSv2, Elastic IPs
- Day 3: S3 deep dive - versioning, lifecycle rules and access control
- Day 4: VPC deep dive - subnets, routing and security groups
- Day 5: AWS CLI and boto3 automation
- Weekend capstone: AWS infrastructure project

## Deliverables

Documentation

- `notes/day1-aws-fundamentals.md`
- `notes/day2-ec2-deep-dive.md`
- `notes/day3-s3-deep-dive.md`
- `notes/day4-vpc-deep-dive.md`
- `notes/day5-cli-automation.md`
- `notes/day1-hands-on-log.md` through `notes/day5-hands-on-log.md` -
  the commands actually run each day, their output, and what went wrong
- `CAPSTONE-PROJECT.md` - infrastructure design and deployment guide

Scripts and configuration

- `scripts/capstone_deploy.py` - capstone deployment automation
- `scripts/aws_automation.py` - boto3 resource management
- `capstone-user-data.sh`, `user-data-webserver.sh` - instance bootstrap
- `s3-read-policy.json`, `trust-policy.json` - IAM policy documents
- `capstone-config.html` - capstone web content

## Technologies

AWS EC2, S3, VPC, IAM, EBS, Elastic IPs, IMDSv2, AWS CLI v2, boto3

## Time Commitment

Study 10-12 hours, hands-on 10-12 hours, capstone 4-6 hours.
Total 24-30 hours.

## Notes

- Keep resources in a single region to simplify tracking and avoid
  cross-region charges. A resource sweep run without an explicit
  `--region` only reports on one region out of roughly thirty.
- Terminate instances at the end of every session. Elastic IPs are billed
  while allocated but unattached.
- `t2.micro` is not eligible on this account; `t3.micro` is the correct
  instance type.
- SSH private keys must be mode 400 and are excluded by `.gitignore`.

## Status

COMPLETE - finished July 2026

Previous: Week 4 - Docker Fundamentals
Next: Week 6 - AWS Fundamentals Part 2
