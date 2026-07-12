"""
AWS Automation Script - Week 5 Day 5
Uses boto3 to automate EC2 and S3 operations that were previously
done manually via the AWS CLI.
"""

import boto3
from botocore.exceptions import ClientError

REGION = "us-east-1"

ec2_client = boto3.client("ec2", region_name=REGION)
s3_client = boto3.client("s3", region_name=REGION)


def list_running_instances():
    """Print all currently running EC2 instances."""
    try:
        response = ec2_client.describe_instances(
            Filters=[{"Name": "instance-state-name", "Values": ["running"]}]
        )
        instances = []
        for reservation in response["Reservations"]:
            instances.extend(reservation["Instances"])

        if not instances:
            print("No running instances found.")
            return

        for instance in instances:
            print(f"Instance ID: {instance['InstanceId']}")
            print(f"  State: {instance['State']['Name']}")
            print(f"  Public IP: {instance.get('PublicIpAddress', 'none')}")
    except ClientError as e:
        print(f"Error listing instances: {e}")

def launch_instance(ami_id, instance_type, key_name, security_group_id, subnet_id=None):
    """Launch an EC2 instance and wait until it's running."""
    try:
        params = {
            "ImageId": ami_id,
            "InstanceType": instance_type,
            "KeyName": key_name,
            "SecurityGroupIds": [security_group_id],
            "MinCount": 1,
            "MaxCount": 1,
            "TagSpecifications": [
                {
                    "ResourceType": "instance",
                    "Tags": [{"Key": "Name", "Value": "week5-day5-boto3"}],
                }
            ],
        }
        if subnet_id:
            params["SubnetId"] = subnet_id

        response = ec2_client.run_instances(**params)
        instance_id = response["Instances"][0]["InstanceId"]
        print(f"Launched instance: {instance_id}")
        print("Waiting for instance to reach 'running' state...")

        waiter = ec2_client.get_waiter("instance_running")
        waiter.wait(InstanceIds=[instance_id])

        described = ec2_client.describe_instances(InstanceIds=[instance_id])
        public_ip = described["Reservations"][0]["Instances"][0].get(
            "PublicIpAddress", "none"
        )
        print(f"Instance is running. Public IP: {public_ip}")
        return instance_id

    except ClientError as e:
        print(f"Error launching instance: {e}")
        return None

def upload_to_s3(bucket_name, local_file_path, s3_key):
    """Upload a local file to an S3 bucket."""
    try:
        s3_client.upload_file(local_file_path, bucket_name, s3_key)
        print(f"Uploaded {local_file_path} to s3://{bucket_name}/{s3_key}")
    except ClientError as e:
        print(f"Error uploading to S3: {e}")
    except FileNotFoundError:
        print(f"Local file not found: {local_file_path}")


def terminate_instance(instance_id):
    """Terminate an EC2 instance and wait until it's fully terminated."""
    try:
        ec2_client.terminate_instances(InstanceIds=[instance_id])
        print(f"Terminating instance: {instance_id}")

        waiter = ec2_client.get_waiter("instance_terminated")
        waiter.wait(InstanceIds=[instance_id])

        print(f"Instance {instance_id} fully terminated.")
    except ClientError as e:
        print(f"Error terminating instance: {e}")


if __name__ == "__main__":
    list_running_instances()

    instance_id = launch_instance(
        ami_id="ami-0ac742fa26982e153",
        instance_type="t3.micro",
        key_name="week5-key",
        security_group_id="sg-0e7def8b9c3b64661",
    )

    if instance_id:
        upload_to_s3(
            bucket_name="iman-devops-week5-2026",
            local_file_path="week5/scripts/aws_automation.py",
            s3_key="day5/aws_automation.py",
        )

        terminate_instance(instance_id)
