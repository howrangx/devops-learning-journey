DAY 2: EC2 DEEP DIVE
Command Reference and Learning Notes

LEARNING DATE: July 9, 2026
COMPLETED BY: Iman

========================================
1. INSTANCE LIFECYCLE IN DETAIL
========================================

pending -> running -> (stopping -> stopped) -> shutting-down -> terminated

- Stopped: instance is off, but the root EBS volume persists. It can
  be restarted later and keeps its data, though the public IP address
  usually changes on restart unless an Elastic IP is attached.
- Terminated: instance and its root volume (by default) are deleted
  permanently. Cannot be undone or restarted.

========================================
2. USER DATA SCRIPTS
========================================

User data is a script that runs automatically the first time an
instance boots, before any login. This is the foundation of automated
server configuration.

Example: installing a package and starting a service without ever
manually SSHing in for setup.

Passed via --user-data at launch time, either as a raw string or a
file reference (--user-data file://script.sh).

========================================
3. EBS (ELASTIC BLOCK STORE) VOLUMES
========================================

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

========================================
4. INSTANCE METADATA
========================================

Every running EC2 instance can query information about itself via a
special internal-only address: http://169.254.169.254/latest/meta-data/

This lets scripts running on the instance discover things like their
own instance ID, public IP, or IAM role, without needing separate
credentials passed in.

AWS now defaults to IMDSv2, a more secure token-based version of this
service, requiring a PUT request first to get a session token before
metadata can be read (visible earlier as HttpTokens: required in the
describe-instances output).

========================================
5. ELASTIC IPS
========================================

A static public IP address that can be allocated and attached to an
instance. Unlike the default public IP, which changes when an instance
is stopped and started, an Elastic IP stays the same until it is
released.

Important cost note: an Elastic IP is free while attached to a
running instance, but AWS charges for it if it's allocated and NOT
attached to a running instance, to discourage hoarding scarce IPv4
addresses.

========================================
6. KEY TAKEAWAYS
========================================

- Stopping preserves data and hours saved, terminating deletes
  everything permanently
- User data scripts automate first-boot configuration
- EBS volumes are the persistent disk layer, independent of the
  instance's compute lifecycle
- Instance metadata lets scripts on the instance learn about
  themselves, secured via IMDSv2 tokens
- Elastic IPs give a stable address, but unattached ones cost money

========================================
NEXT STEPS: Day 3 - S3 Deep Dive
========================================
