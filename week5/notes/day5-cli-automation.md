# Day 5: AWS CLI Automation with Python (boto3)

## Why boto3 instead of the AWS CLI

The AWS CLI is great for interactive, one-off commands, but Python
scripts using boto3 allow:
- Combining multiple AWS calls into a single automated workflow
- Adding conditional logic (only launch if X doesn't already exist)
- Polling and waiting for state changes programmatically
- Reusable, version-controlled infrastructure automation, rather than
  a sequence of manually typed commands

This is the same underlying API the CLI itself uses; boto3 is simply
a Python interface to it.

## Core boto3 Concepts

- Client: a low-level interface, closely mirroring the AWS CLI's
  command structure (e.g. ec2_client.run_instances(...))
- Resource: a higher-level, more Pythonic interface for some services
  (e.g. treating an EC2 instance as an object with methods like
  .start() and .stop())
- Session: manages credentials and region configuration; by default,
  boto3 automatically uses the same credentials and region already
  configured via 'aws configure'

## Basic Pattern

import boto3

ec2 = boto3.client('ec2', region_name='us-east-1')
response = ec2.describe_instances()

boto3 API calls generally return the same JSON-like structure seen in
the AWS CLI's JSON output, just as native Python dictionaries and
lists instead of raw JSON text.

## Waiters

boto3 provides "waiters" that poll AWS until a resource reaches a
desired state, instead of manually writing a sleep-and-retry loop.

Example: waiting for an instance to be running before continuing:

waiter = ec2.get_waiter('instance_running')
waiter.wait(InstanceIds=[instance_id])

## Error Handling

AWS API errors in boto3 raise a botocore.exceptions.ClientError
exception, which contains structured details about what went wrong
(error code, message), allowing scripts to catch and handle specific
failure cases rather than crashing outright.

## Key Takeaways

- boto3 is the Python SDK equivalent of the AWS CLI, using the same
  underlying API and credentials
- Clients provide a direct, CLI-like interface; Resources provide a
  higher-level, object-oriented interface for some services
- Waiters remove the need to manually poll resource state in a loop
- Error handling should catch botocore.exceptions.ClientError to
  respond to specific AWS-side failures gracefully
