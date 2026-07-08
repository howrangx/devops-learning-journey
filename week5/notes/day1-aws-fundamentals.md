# Day 1: AWS Fundamentals - EC2, S3, VPC Basics

## AWS Global Infrastructure

AWS organizes its infrastructure into:
- Regions: geographic areas (e.g. us-east-1 = N. Virginia)
- Availability Zones (AZs): isolated data centers within a region, each
  region has 2 or more AZs for redundancy
- Edge Locations: used for content delivery (CloudFront)

Choosing a region affects: latency, pricing, and which services are
available. Free tier resources should stay in one region to avoid
unexpected charges.

## EC2 (Elastic Compute Cloud)

EC2 provides virtual servers (instances) in the cloud.

Key concepts:
- AMI (Amazon Machine Image): template used to launch an instance
  (OS plus preinstalled software)
- Instance Type: defines CPU, memory, and network capacity
  (e.g. t2.micro is free tier eligible)
- Key Pair: SSH key used to securely connect to an instance
- Security Group: virtual firewall controlling inbound/outbound traffic
- Elastic IP: static public IP address that can be attached to an instance

Instance lifecycle states: pending, running, stopping, stopped,
shutting-down, terminated. Stopped instances still incur EBS storage
charges; terminated instances are permanently deleted.

## S3 (Simple Storage Service)

S3 is object storage, not a file system. Data is stored as objects
inside buckets.

Key concepts:
- Bucket: a container for objects, must have a globally unique name
- Object: a file plus metadata, identified by a key (its path/name)
- Storage Classes: Standard, Intelligent-Tiering, Standard-IA, Glacier,
  and others, trading cost against retrieval speed
- Versioning: keeps multiple versions of an object when enabled
- Bucket Policy vs ACL: bucket policy is JSON-based and preferred for
  access control over legacy ACLs

S3 is region-specific but the bucket namespace is global across all
of AWS, so bucket names must be unique across every AWS account.

## VPC (Virtual Private Cloud)

A VPC is an isolated virtual network within AWS where resources like
EC2 instances are launched.

Key concepts:
- CIDR Block: defines the IP address range of the VPC
  (e.g. 10.0.0.0/16)
- Subnet: a subdivision of the VPC's CIDR range, tied to a single AZ
- Public Subnet: has a route to an Internet Gateway
- Private Subnet: has no direct route to the internet
- Internet Gateway (IGW): allows communication between the VPC and
  the internet
- Route Table: controls where network traffic is directed

Every AWS account has a Default VPC per region, already configured
with public subnets, ready to use without extra setup.

## AWS CLI Command Patterns

General structure: aws <service> <action> [options]

Examples covered today:
- aws ec2 describe-instances
- aws ec2 describe-vpcs
- aws s3 ls
- aws s3 mb s3://bucket-name
- aws ec2 run-instances (with AMI ID, instance type, key pair)

## Key Takeaways

- EC2 = compute (virtual servers)
- S3 = storage (objects in buckets)
- VPC = networking (isolated virtual network)
- These three are the foundation almost every other AWS service builds on
