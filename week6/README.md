# Week 6: AWS Fundamentals Part 2

## Overview

Where Week 5 covered the raw building blocks, Week 6 covers the services
that turn those blocks into a real, secure, highly available application:
identity and access management, managed databases, load balancing and
automatic scaling. The week ends with a two-tier application deployed
across multiple availability zones.

## Prerequisites

- Week 5 complete: AWS CLI configured, comfortable launching and
  terminating EC2 instances
- Understanding of VPC subnets, route tables and security groups
- Basic SQL for the Day 2 database exercises

## Learning Objectives

- Write and reason about IAM policies rather than attaching managed ones
- Understand how AWS evaluates a permission request end to end
- Use IAM roles for service access instead of long-lived access keys
- Launch, secure and connect to a managed RDS database
- Place a database in private subnets reachable only from the web tier
- Put an Application Load Balancer in front of multiple instances
- Build launch templates and Auto Scaling groups that self-heal
- Know what each of these services costs and how to shut them down

## Daily Structure

- Day 1: IAM deep dive
- Day 2: RDS and managed databases
- Day 3: Elastic Load Balancing
- Day 4: Auto Scaling and launch templates
- Day 5: High availability, monitoring and cost control
- Weekend capstone: Highly available two-tier web application

## Deliverables

Documentation

- `notes/day1-iam-deep-dive.md` - identity types, policy anatomy,
  evaluation order, roles and instance profiles, conditions, auditing
- `notes/day1-hands-on-log.md` - account audit, key rotation, policy
  authoring, and live verification on EC2
- `notes/day2-rds.md` - managed databases, subnet groups, Multi-AZ versus
  read replicas, backups and recovery, securing and connecting to RDS
- `notes/day2-hands-on-log.md` - engine and class discovery, source-group
  security rules, a free plan restriction, proving the network boundary,
  and two teardown commands that silently did nothing
- `notes/day3-elb.md` - load balancer types, listeners and rules, target
  groups, health checks, cross-zone behaviour, stickiness, TLS
  termination and the ALB cost model
- `notes/day3-hands-on-log.md` - security group chaining, health check
  tuning, observed request distribution, deliberate failure injection,
  and deletion dependency ordering

Scripts

- `scripts/day3-user-data.sh` - web server bootstrap that identifies the
  serving instance and availability zone through IMDSv2

Configuration

- `configs/s3-week6-read.json` - least-privilege S3 read policy
- `configs/ec2-trust-policy.json` - EC2 service trust policy

## Technologies

AWS IAM, Amazon RDS, Elastic Load Balancing, EC2 Auto Scaling, CloudWatch,
AWS Budgets, AWS Secrets Manager, AWS CLI, JSON policy documents

## Cost Warning

This week creates resources that bill by the hour whether or not they are
used. Confirm current free tier status in the Billing console before each
day, since terms differ depending on when an account was opened. Free plan
restrictions are enforced at the API and are a design constraint, not only
a billing detail.

- Application Load Balancer: billed per hour while it exists, with or
  without traffic
- RDS: billed per hour, and Multi-AZ roughly doubles it
- NAT Gateway: billed per hour plus data processing, and the most common
  source of surprise charges
- Elastic IPs: billed while allocated but unattached
- EBS volumes and snapshots: persist after instance termination
- RDS snapshots and RDS-managed secrets: outlive the database instance

Every day in this week ends with a teardown step, followed by a
verification pass. A teardown command that returns without error is not
evidence that anything was torn down.

## Time Commitment

Study 10-12 hours, hands-on 10-12 hours, capstone 4-6 hours.
Total 24-30 hours.

## Status

IN PROGRESS - started August 31, 2026. Days 1-3 complete.

Previous: Week 5 - AWS Fundamentals Part 1
Next: Week 7 - AWS Advanced Services
