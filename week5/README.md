# Week 5: AWS Fundamentals - Part 1

## Overview

Week 5 introduces the core AWS services that form the foundation for
almost everything else in cloud infrastructure: EC2 (compute), S3
(storage), and VPC (networking). This week focuses on hands-on use of
the AWS CLI alongside the console, building the habits needed for
infrastructure automation in later weeks.

## Status

Status: IN PROGRESS
Start Date: July 08, 2026

## Prerequisites

- AWS account created (Free Tier)
- AWS CLI installed and configured
- IAM user created with programmatic access

## Learning Objectives

By the end of this week, you will:
- Understand AWS global infrastructure (regions, availability zones)
- Launch and manage EC2 instances
- Create and manage S3 buckets and objects
- Understand VPC networking fundamentals
- Use the AWS CLI to manage resources instead of relying solely on
  the console
- Understand AWS Free Tier limits and how to avoid unexpected charges

## Curriculum Structure

Day 1: AWS Fundamentals - EC2, S3, VPC Basics
Day 2: EC2 Deep Dive - Launching and Managing Instances
Day 3: S3 Deep Dive - Storage, Versioning, and Access Control
Day 4: VPC Deep Dive - Subnets, Routing, and Security Groups
Day 5: AWS CLI Automation Scripts
Weekend Capstone: AWS Infrastructure Project

## Deliverables

Daily Documentation:
- notes/day1-aws-fundamentals.md
- notes/day2-ec2-deep-dive.md
- notes/day3-s3-deep-dive.md
- notes/day4-vpc-deep-dive.md
- notes/day5-cli-automation.md

Scripts:
- scripts/ (AWS automation scripts, added throughout the week)

Capstone:
- Weekend AWS infrastructure project (details to follow)

## Folder Structure

week5/
  README.md
  notes/
  scripts/
  configs/
  logs/

## Notes

- Keep all resources in a single region (us-east-1 recommended) to
  simplify tracking and avoid unexpected cross-region charges.
- Always terminate or stop EC2 instances when not actively in use.
- Review the AWS Free Tier usage dashboard periodically this week.
