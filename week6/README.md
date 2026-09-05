WEEK 6: AWS FUNDAMENTALS PART 2

Overview
This week builds on the Week 5 AWS foundation. Where Week 5 covered the
raw building blocks (EC2, S3, VPC), Week 6 covers the services that turn
those blocks into a real, secure, highly available application: identity
and access management, managed databases, load balancing, and automatic
scaling.

The week ends with a capstone that deploys a two-tier web application
across multiple availability zones.

Learning Objectives

By the end of this week, you will:
- Write and reason about IAM policies rather than attaching managed ones
- Understand how AWS evaluates a permission request end to end
- Use IAM roles for service-to-service access instead of access keys
- Launch, secure, and connect to a managed RDS database
- Place a database in private subnets and reach it only from application servers
- Put an Application Load Balancer in front of multiple instances
- Build launch templates and Auto Scaling groups that self-heal
- Understand what each of these services costs and how to shut them down

Phase 2 Content Structure

Week 6 (AWS Fundamentals Part 2)
- Day 1: IAM Deep Dive
- Day 2: RDS and Managed Databases
- Day 3: Elastic Load Balancing
- Day 4: Auto Scaling and Launch Templates
- Day 5: High Availability, Monitoring, and Cost Control
- Weekend: Capstone - Highly Available Two-Tier Web Application

Day Detail

Day 1: IAM Deep Dive
- Users, groups, roles, and the difference between them
- Identity-based vs resource-based policies
- Policy document anatomy: Version, Statement, Effect, Action, Resource,
  Condition, Principal
- The policy evaluation logic: explicit deny, organization policies,
  resource policy, identity policy, permission boundary
- Least privilege in practice
- IAM roles for EC2 and instance profiles
- Access key hygiene, rotation, and why roles beat keys
- Auditing with IAM Access Analyzer, credential reports, and last-accessed data

Day 2: RDS and Managed Databases
- Managed vs self-managed databases and what RDS actually takes over
- Engines, instance classes, and storage types
- DB subnet groups and why a database needs at least two subnets
- Parameter groups and option groups
- Multi-AZ standby vs read replicas: different problems, different tools
- Automated backups, snapshots, and point-in-time recovery
- Securing a database with security groups instead of network exposure
- Connecting from an EC2 instance

Day 3: Elastic Load Balancing
- Why load balancing exists: availability, scale, and deployment safety
- Application, Network, and Gateway Load Balancers compared
- Listeners, rules, and target groups
- Health checks and how a failing target is removed from rotation
- Cross-zone load balancing
- Sticky sessions and when they are a mistake
- Terminating HTTPS at the load balancer

Day 4: Auto Scaling and Launch Templates
- Launch templates and versioning
- Auto Scaling group fundamentals: min, max, desired capacity
- Attaching an Auto Scaling group to a target group
- Health check types: EC2 vs ELB
- Scaling policies: target tracking, step, and scheduled
- Cooldowns, warm-up, and instance refresh
- Self-healing: terminating an instance and watching it come back

Day 5: High Availability, Monitoring, and Cost Control
- Availability zones, failure domains, and what "highly available" means
- CloudWatch metrics, alarms, and log groups
- Tagging strategy and cost allocation
- AWS Budgets and billing alarms
- Reading the Cost Explorer
- A repeatable teardown checklist so nothing is left running

Weekend Capstone: Highly Available Two-Tier Web Application
- VPC with public and private subnets across two availability zones
- Application Load Balancer in the public subnets
- Auto Scaling group of web servers behind the load balancer
- RDS instance in the private subnets, reachable only from the web tier
- IAM role granting the web tier read access to an S3 bucket
- Everything provisioned by scripted AWS CLI commands, not console clicks
- Full documentation and a verified teardown

Technologies Covered
AWS IAM, Amazon RDS, Elastic Load Balancing, EC2 Auto Scaling,
CloudWatch, AWS Budgets, AWS CLI, JSON policy documents

Cost Warning

This week creates resources that are not always free. Before starting each
day, confirm your own free tier status in the Billing console, because free
tier terms differ depending on when an account was opened.

Resources to watch:
- Application Load Balancer: billed per hour while it exists, whether or
  not traffic flows through it
- RDS: billed per hour, and Multi-AZ roughly doubles the cost
- NAT Gateway: billed per hour plus data processing, and is the most common
  source of surprise charges
- Elastic IPs: billed when allocated but not attached to a running instance
- EBS volumes and snapshots: persist after an instance is terminated if not
  deleted

Every day in this week ends with a teardown step. Do not skip it.

Time Commitment
- Study: 10-12 hours
- Hands-on: 10-12 hours
- Capstone: 4-6 hours
- Total: 24-30 hours

Prerequisites
- Week 5 complete: AWS CLI configured, IAM user iman-devops working,
  comfortable launching and terminating EC2 instances
- Understanding of VPC subnets, route tables, and security groups
- Basic SQL for the Day 2 database exercises

Directory Structure
week6/
  README.md
  notes/
  scripts/
  configs/
  logs/

Status: In Progress
Started: August 31, 2026
Previous: Week 5 - AWS Fundamentals Part 1
Next: Week 7 - AWS Advanced Services (Lambda, CloudWatch, SNS/SQS)
