"""
Week 5 Capstone - Automated Deployment with S3 Config Pull
Launches an EC2 instance into a specific subnet with an IAM role,
pulls web content from S3 at boot, verifies reachability, and logs
all actions locally.
"""

import time
import logging
import requests
import boto3
from botocore.exceptions import ClientError

REGION = "us-east-1"
AMI_ID = "ami-0ac742fa26982e153"
INSTANCE_TYPE = "t3.micro"
KEY_NAME = "week5-key"
SECURITY_GROUP_ID = "sg-0e7def8b9c3b64661"
SUBNET_ID = "subnet-052b99125e9a5177c"
INSTANCE_PROFILE_NAME = "week5-ec2-s3-profile"
USER_DATA_FILE = "week5/capstone-user-data.sh"
LOG_FILE = "week5/logs/capstone-deploy.log"

logging.basicConfig(
    filename=LOG_FILE,
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
)
console = logging.StreamHandler()
console.setLevel(logging.INFO)
logging.getLogger().addHandler(console)

ec2_client = boto3.client("ec2", region_name=REGION)

def read_user_data(filepath):
    """Read a local file and return its contents as a string."""
    with open(filepath, "r") as f:
        return f.read()


def launch_instance():
    """Launch an EC2 instance into a specific subnet with an IAM role attached."""
    try:
        user_data = read_user_data(USER_DATA_FILE)

        response = ec2_client.run_instances(
            ImageId=AMI_ID,
            InstanceType=INSTANCE_TYPE,
            KeyName=KEY_NAME,
            SecurityGroupIds=[SECURITY_GROUP_ID],
            SubnetId=SUBNET_ID,
            UserData=user_data,
            IamInstanceProfile={"Name": INSTANCE_PROFILE_NAME},
            MinCount=1,
            MaxCount=1,
            TagSpecifications=[
                {
                    "ResourceType": "instance",
                    "Tags": [{"Key": "Name", "Value": "week5-capstone"}],
                }
            ],
        )
        instance_id = response["Instances"][0]["InstanceId"]
        logging.info(f"Launched instance: {instance_id} into subnet {SUBNET_ID}")

        waiter = ec2_client.get_waiter("instance_running")
        waiter.wait(InstanceIds=[instance_id])
        logging.info(f"Instance {instance_id} is now running")

        described = ec2_client.describe_instances(InstanceIds=[instance_id])
        public_ip = described["Reservations"][0]["Instances"][0].get(
            "PublicIpAddress", "none"
        )
        logging.info(f"Public IP: {public_ip}")

        return instance_id, public_ip

    except ClientError as e:
        logging.error(f"Error launching instance: {e}")
        return None, None

def verify_site(public_ip, retries=5, delay=10):
    """Check that the web server is responding, retrying if not ready yet."""
    url = f"http://{public_ip}"

    for attempt in range(1, retries + 1):
        try:
            response = requests.get(url, timeout=5)
            if response.status_code == 200:
                logging.info(f"Site reachable on attempt {attempt}: {url}")
                logging.info(f"Response preview: {response.text[:100]}")
                return True
            else:
                logging.warning(
                    f"Attempt {attempt}: got status code {response.status_code}"
                )
        except requests.exceptions.RequestException as e:
            logging.warning(f"Attempt {attempt}: site not reachable yet ({e})")

        if attempt < retries:
            time.sleep(delay)

    logging.error(f"Site did not become reachable after {retries} attempts")
    return False


def terminate_instance(instance_id):
    """Terminate an EC2 instance and wait until it is fully terminated."""
    try:
        ec2_client.terminate_instances(InstanceIds=[instance_id])
        logging.info(f"Terminating instance: {instance_id}")

        waiter = ec2_client.get_waiter("instance_terminated")
        waiter.wait(InstanceIds=[instance_id])
        logging.info(f"Instance {instance_id} fully terminated")

    except ClientError as e:
        logging.error(f"Error terminating instance: {e}")


if __name__ == "__main__":
    logging.info("=== Starting Week 5 Capstone Deployment ===")

    instance_id, public_ip = launch_instance()

    if instance_id and public_ip != "none":
        site_ok = verify_site(public_ip)

        if site_ok:
            logging.info("Deployment verified successfully")
        else:
            logging.warning("Deployment could not be verified")

        terminate_instance(instance_id)
    else:
        logging.error("Skipping verification and cleanup due to launch failure")

    logging.info("=== Capstone Deployment Complete ===")
