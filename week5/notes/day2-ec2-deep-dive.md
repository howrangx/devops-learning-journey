# Day 2: EC2 Deep Dive

## Instance Lifecycle in Detail

pending -> running -> (stopping -> stopped) -> shutting-down -> terminated

- Stopped: instance is off, but the root EBS volume persists. You can
  restart it later and it keeps its data, but note the public IP
  address usually changes on restart (unless using an Elastic IP).
- Terminated: instance and its root volume (by default) are deleted
  permanently. Cannot be undone or restarted.

## User Data Scripts

User data lets you pass a script that runs automatically the first
time an instance boots, before you ever log in. This is the
foundation of automated server configuration.

Example: installing a package and starting a service without ever
manually SSHing in for setup.

Passed via --user-data at launch time, either as a raw string or a
file reference (--user-data file://script.sh).

## EBS (Elastic Block Store) Volumes

EBS is the persistent disk storage attached to EC2 instances.

Key concepts:
- Root Volume: created automatically with the instance, holds the OS
- Additional Volumes: can be attached/detached independently of the
  instance lifecycle
- Volume Types: gp3 (general purpose SSD, most common default),
  io2 (high performance), st1/sc1 (throughput-optimized, cold HDD)
- Snapshots: point-in-time backups of a volume, stored in S3 behind
  the scenes, used for backup/restore and creating new volumes

Volumes are tied to a specific Availability Zone and cannot be
attached to an instance in a different AZ without first creating a
snapshot and a new volume from it.

## Instance Metadata

Every running EC2 instance can query information about itself via a
special internal-only address: http://169.254.169.254/latest/meta-data/

This lets scripts running on the instance discover things like their
own instance ID, public IP, or IAM role, without needing separate
credentials passed in.

AWS now defaults to IMDSv2, a more secure token-based version of this
service, requiring a PUT request first to get a session token before
metadata can be read (visible earlier as HttpTokens: required in our
describe-instances output).

## Elastic IPs

A static public IP address you can allocate and attach to an
instance. Unlike the default public IP (which changes if you stop and
start the instance), an Elastic IP stays the same until you release
it.

Important cost note: an Elastic IP is free while attached to a
running instance, but AWS charges for it if it's allocated and NOT
attached to a running instance, to discourage hoarding scarce IPv4
addresses.

## Key Takeaways

- Stopping preserves data and hours saved, terminating deletes
  everything permanently
- User data scripts automate first-boot configuration
- EBS volumes are the persistent disk layer, independent of the
  instance's compute lifecycle
- Instance metadata lets scripts on the instance learn about
  themselves, secured via IMDSv2 tokens
- Elastic IPs give a stable address, but unattached ones cost money
