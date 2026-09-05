DAY 2: RDS AND MANAGED DATABASES - HANDS-ON LOG
Session Record

LEARNING DATE: September 5, 2026
COMPLETED BY: Iman
REGION: us-east-1
ENVIRONMENT: WSL2 Ubuntu on Windows

========================================
1. SESSION OBJECTIVES
========================================

- Verify the account is clean and nothing from Day 1 is still billing
- Discover the correct engine version and instance class rather than
  assuming them
- Build the network and security layer before the database that uses it
- Launch a private, encrypted RDS instance with a password no human sees
- Prove the security boundary by confirming access fails from outside
  the VPC
- Connect and query from inside the VPC
- Tear down completely and verify the teardown

========================================
2. PRE-FLIGHT CHECKS
========================================

A four-region sweep across us-east-1, eu-north-1, eu-central-1 and
eu-west-1 returned no EC2 instances and no RDS instances. Day 1 had left
nothing behind.

This check runs before every day in Week 6. RDS bills from the moment an
instance exists, so the state of the account has to be known before
anything is created.

========================================
3. DISCOVERY, AND TWO QUERY MISTAKES
========================================

Newest available MySQL engine version:

aws rds describe-db-engine-versions \
  --engine mysql \
  --query "DBEngineVersions[-1].EngineVersion" --output text

Result: 8.4.11

Mistake 1: trusting [0]

An orderable-options query using OrderableDBInstanceOptions[0] returned
5.7.44-rds.20250213 with gp2 storage. That is simply the first element AWS
happened to return, not the newest or the best. MySQL 5.7 is past end of
life and gp2 is the older storage type, so building on that answer would
have silently selected both.

Index [0] answers "the first one", never "the right one".

Mistake 2: truncating the evidence

A follow-up query piped through head -20 was used to check whether
db.t3.micro appears in the class list for 8.4.11. The list is alphabetical,
so db.t3.* sorts after db.m5d.* and never appeared in the first twenty
lines. The query proved nothing and briefly suggested the class was
unsupported.

Mistake 3: a field name that does not exist

This query returned nothing at all:

--query "OrderableDBInstanceOptions[].AvailabilityZones[].ZoneName"

In EC2, an availability zone object has ZoneName. In RDS, the same concept
has Name. JMESPath returns an empty result for a key that does not exist
rather than raising an error, so a wrong field name and a genuine
no-matches result look identical.

An empty JMESPath result means either "nothing matched" or "that key does
not exist". Distinguishing the two requires removing filters one at a time
until output appears; the filter removed last is the cause.

Corrected queries:

aws rds describe-orderable-db-instance-options \
  --engine mysql --db-instance-class db.t3.micro \
  --query "OrderableDBInstanceOptions[].EngineVersion" \
  --output text | tr '\t' '\n' | sort -u

aws rds describe-orderable-db-instance-options \
  --engine mysql --engine-version 8.4.11 --db-instance-class db.t3.micro \
  --query "OrderableDBInstanceOptions[].AvailabilityZones[].Name" \
  --output text | tr '\t' '\n' | sort -u

aws rds describe-orderable-db-instance-options \
  --engine mysql --engine-version 8.4.11 --db-instance-class db.t3.micro \
  --query "OrderableDBInstanceOptions[].[StorageType,SupportsStorageEncryption,MultiAZCapable]" \
  --output table

Findings:
- db.t3.micro supports MySQL 5.7.44, 8.0.42 through 8.0.46, and 8.4.5
  through 8.4.11
- All six us-east-1 availability zones support the configuration
- gp2, gp3, io1 and io2 are all available
- Storage encryption is supported
- The configuration is Multi-AZ capable

Build target selected: MySQL 8.4.11 on db.t3.micro, 20 GB gp3, encrypted.
The newest engine version the cheapest instance class supports.

========================================
4. NETWORK AND SECURITY LAYER
========================================

Built before the database, so the database is never briefly reachable
while rules are still being added.

Identifiers were captured into shell variables rather than pasted, keeping
resource IDs out of shell history:

VPC_ID=$(aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" \
  --query "Vpcs[0].VpcId" --output text)
SUBNET_A=$(aws ec2 describe-subnets \
  --filters "Name=availability-zone,Values=us-east-1a" "Name=vpc-id,Values=$VPC_ID" \
  --query "Subnets[0].SubnetId" --output text)
SUBNET_B=$(aws ec2 describe-subnets \
  --filters "Name=availability-zone,Values=us-east-1b" "Name=vpc-id,Values=$VPC_ID" \
  --query "Subnets[0].SubnetId" --output text)
APP_SG=$(aws ec2 describe-security-groups \
  --filters "Name=group-name,Values=week5-sg" \
  --query "SecurityGroups[0].GroupId" --output text)

DB subnet group across two availability zones:

aws rds create-db-subnet-group \
  --db-subnet-group-name week6-db-subnets \
  --db-subnet-group-description "Week 6 database subnets" \
  --subnet-ids $SUBNET_A $SUBNET_B

Why two AZs are required for a single-AZ instance:

A subnet group is a list of permitted placements, not a set of instances.
Two subnets do not create two databases. With --no-multi-az there is
exactly one database in one AZ, and if that AZ fails the database is down.
There is no standby.

The requirement exists for optionality. Converting to Multi-AZ later means
RDS has to place a standby somewhere, and the subnet group is where it
looks. Changing a subnet group on a live instance is disruptive, so AWS
enforces the network prerequisite at creation time, when it is free, rather
than during the incident that prompts the conversion.

The same pattern as the Day 1 instance profile: the container has to exist
before the thing that will need it.

Which two subnets, and why it is not arbitrary:
- Cross-AZ traffic between EC2 and RDS is billed per GB; same-AZ is free,
  so for a single-AZ database the AZ the application runs in is the one
  that matters
- AZ letters are account-specific. us-east-1a maps to a different physical
  datacentre for different accounts, so a letter means nothing across
  accounts
- Not every AZ offers every configuration, which is why the orderable
  options query above was run rather than assuming

us-east-1a and us-east-1b were chosen because the weekend capstone places
an Auto Scaling group across two AZs and reusing the same pair all week is
less state to track.

Database security group, created empty:

DB_SG=$(aws ec2 create-security-group \
  --group-name week6-db-sg \
  --description "Week 6 RDS MySQL access from application tier" \
  --vpc-id $VPC_ID --query GroupId --output text)

A new security group has no inbound rules, so the database is unreachable
from the moment it exists.

========================================
5. SOURCE GROUP VERSUS CIDR
========================================

Two ways to allow the application tier to reach MySQL:

aws ec2 authorize-security-group-ingress --group-id $DB_SG \
  --protocol tcp --port 3306 --cidr 172.31.0.0/16

aws ec2 authorize-security-group-ingress --group-id $DB_SG \
  --protocol tcp --port 3306 --source-group $APP_SG

The source-group form was chosen. Both work on the day they are written.

Maintenance: private IP addresses change every time an instance is
replaced. An Auto Scaling group replacing instances every few days
invalidates a CIDR-based assumption continuously, while a group reference
follows the instances automatically because it names an identity rather
than a location.

Least privilege: the CIDR rule allows anything in 172.31.0.0/16 to reach
the database, including instances unrelated to this application and
instances that have been compromised. The source-group rule allows only
instances carrying that specific group.

The same principle as the Day 1 IAM policy: name the identity, not the
location.

Note on idempotency: re-running an identical authorize command returns
InvalidPermission.Duplicate rather than succeeding silently. Security group
rules are idempotent in effect but not in API response.

========================================
6. FREE PLAN RESTRICTION ENCOUNTERED
========================================

The first create-db-instance attempt used --backup-retention-period 7 and
was refused:

An error occurred (FreeTierRestrictionError) when calling the
CreateDBInstance operation: The specified backup retention period exceeds
the maximum available to free tier customers.

This is not a cost warning. It is a hard API refusal.

The finding: the post-July-2025 free plan does not only meter usage against
a credit balance, it also caps certain configurations outright. Account
plan is therefore a design constraint, not just a billing detail, and it
has to be discovered by attempting the operation.

Retrying with --backup-retention-period 1 succeeded. One day of retention
still provides point-in-time recovery, with a 24-hour window instead of a
week. The important property is that it is not zero, because zero disables
automated backups and point-in-time recovery entirely.

========================================
7. INSTANCE CREATION
========================================

aws rds create-db-instance \
  --db-instance-identifier week6-mysql \
  --db-instance-class db.t3.micro \
  --engine mysql --engine-version 8.4.11 \
  --allocated-storage 20 --storage-type gp3 --storage-encrypted \
  --master-username dbadmin \
  --manage-master-user-password \
  --db-subnet-group-name week6-db-subnets \
  --vpc-security-group-ids $DB_SG \
  --no-publicly-accessible \
  --no-multi-az \
  --backup-retention-period 1 \
  --preferred-backup-window "03:00-04:00" \
  --preferred-maintenance-window "sun:05:00-sun:06:00" \
  --tags Key=Name,Value=week6-mysql Key=Week,Value=6

Result: week6-mysql, creating, mysql, 8.4.11, encrypted, retention 1

On --manage-master-user-password:

RDS generates the password, stores it in AWS Secrets Manager, and rotates
it on a schedule. No plaintext password is typed, stored in a file, or
placed on a command line.

The alternative considered was reading the password into a shell variable
with read -s. That keeps it out of files but still places it on the command
line, where it is visible in ps output while the command runs. On a
single-user machine that is not a meaningful exposure, but the managed
option is the production answer and costs a few cents per month for the
secret.

Creation took approximately eight minutes. The client EC2 instance was
launched in parallel rather than sequentially:

aws ec2 run-instances \
  --image-id $AMI_ID --instance-type t3.micro \
  --key-name week5-key --security-group-ids $APP_SG \
  --subnet-id $SUBNET_A \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=week6-day2-db-client},{Key=Week,Value=6}]'

--subnet-id pins the instance to us-east-1a rather than letting AWS choose.
Deliberate, because cross-AZ transfer between EC2 and RDS is billed per GB
while same-AZ is free.

Waiters were used instead of manual polling:

aws ec2 wait instance-running --instance-ids $APP_INSTANCE
aws rds wait db-instance-available --db-instance-identifier week6-mysql

RDS placed the instance in us-east-1a, matching the client instance.

========================================
8. PROVING THE SECURITY BOUNDARY
========================================

Run from WSL, outside the VPC, before attempting the working path:

ENDPOINT=$(aws rds describe-db-instances --db-instance-identifier week6-mysql \
  --query "DBInstances[0].Endpoint.Address" --output text)

dig +short $ENDPOINT
Result: 172.31.9.36

timeout 5 bash -c "cat < /dev/null > /dev/tcp/$ENDPOINT/3306"
Result: port NOT reachable

Two things are demonstrated at once.

The endpoint is a public DNS name that anyone can resolve, but it resolves
to a private RFC1918 address that is not routable from outside the VPC.
Public name, private address.

The failure mode is an unreachable port, not rejected credentials. The
connection never gets far enough for MySQL to form an opinion about
identity.

That distinction is most of RDS troubleshooting. An unreachable port means
a security group, a subnet, or public accessibility. A reachable port with
a failed login means credentials or database-level grants. Establishing
which half the failure is in comes before changing anything.

========================================
9. CONNECTING FROM INSIDE THE VPC
========================================

Client installed on Amazon Linux 2023:

sudo dnf install -y mariadb105

That package provides the mysql command. The client is MariaDB 10.5.29 and
the server is MySQL 8.4.11; they are different implementations speaking the
same wire protocol.

Password retrieved without it reaching a file or the terminal scrollback:

SECRET_ARN=$(aws rds describe-db-instances --db-instance-identifier week6-mysql \
  --query "DBInstances[0].MasterUserSecret.SecretArn" --output text)

DB_PASS=$(aws secretsmanager get-secret-value --secret-id "$SECRET_ARN" \
  --query SecretString --output text \
  | python3 -c "import json,sys; print(json.load(sys.stdin)['password'])")

The whole query run non-interactively from WSL in a single command:

ssh -i week5/week5-key.pem ec2-user@$PUB_IP \
  "MYSQL_PWD='$DB_PASS' mysql -h $ENDPOINT -u dbadmin" <<'SQL'
SELECT VERSION();
CREATE DATABASE IF NOT EXISTS week6;
USE week6;
CREATE TABLE IF NOT EXISTS servers (
  id INT PRIMARY KEY AUTO_INCREMENT,
  hostname VARCHAR(64),
  role VARCHAR(32)
);
INSERT INTO servers (hostname, role) VALUES ('web1','frontend'), ('db1','database');
SELECT * FROM servers;
SQL

Output:

VERSION()
8.4.11
id      hostname        role
1       web1    frontend
2       db1     database

Variables expand in the local shell before the command is sent, MYSQL_PWD
is read by the mysql client instead of prompting, and the heredoc supplies
the SQL on stdin. The same pattern works in a CI pipeline or a deployment
script, which is why it is worth preferring over an interactive session.

Caveats accepted for a learning environment: MYSQL_PWD is visible in
/proc/<pid>/environ on the instance, and the expanded password appears in
local ps output while the command runs. In production the application would
read the secret itself using an IAM role, exactly as the Day 1 instance
read S3.

Errors made before reaching the working command:

A placeholder written as <ENDPOINT> was pasted literally, and bash
interpreted the angle bracket as input redirection, producing "No such file
or directory" rather than anything about endpoints.

The SQL block was pasted at the bash prompt rather than inside the mysql
client, producing "CREATE: command not found".

Shell variables set in WSL were referenced on the EC2 instance, where they
do not exist. The two machines have separate shells and share nothing.

========================================
10. TEARDOWN
========================================

Dependency order. The database holds the subnet group and the security
group, so it goes first.

aws ec2 terminate-instances --instance-ids $APP_INSTANCE

aws rds delete-db-instance \
  --db-instance-identifier week6-mysql \
  --skip-final-snapshot \
  --delete-automated-backups

aws rds wait db-instance-deleted --db-instance-identifier week6-mysql

aws rds delete-db-subnet-group --db-subnet-group-name week6-db-subnets
aws ec2 delete-security-group --group-id $DB_SG

--skip-final-snapshot is correct in a learning account and wrong in
production, where the final snapshot is the last defence against a mistaken
deletion.

The security group deletion fails if attempted before the database is fully
deleted, because RDS keeps a network interface attached until then. That is
a dependency, not an error.

========================================
11. TEARDOWN FAILURES CAUGHT BY VERIFICATION
========================================

Two teardown commands silently did nothing.

Both aws ec2 terminate-instances --instance-ids $APP_INSTANCE and
aws ec2 delete-security-group --group-id $DB_SG were run in a shell where
those variables were no longer set. The security group case surfaced
immediately as a parameter validation error. The instance termination did
not: it ran against an empty argument and the day appeared to end cleanly
while a t3.micro kept running.

The verification pass is what caught it:

aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running,pending,stopped" \
  --query "Reservations[].Instances[].[InstanceId,State.Name]" --output text

Result: one running instance, identified by its Name tag as
week6-day2-db-client, and terminated.

Principle: a teardown command that returns without error is not evidence
that anything was torn down. Only the listing afterwards is. Empty output
from a command that was never really executed looks identical to empty
output from a command that worked.

Recovery approach: look resources up by name and tag rather than relying on
remembered IDs, because that works in any shell at any time.

DB_SG=$(aws ec2 describe-security-groups \
  --filters "Name=group-name,Values=week6-db-sg" \
  --query "SecurityGroups[0].GroupId" --output text)

Final verification, all sections empty:

aws rds describe-db-instances
aws rds describe-db-snapshots --snapshot-type manual
aws rds describe-db-snapshots --snapshot-type automated
aws rds describe-db-subnet-groups
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running,pending,stopped"
aws ec2 describe-security-groups --filters "Name=group-name,Values=week6-*"
aws ec2 describe-volumes --filters "Name=status,Values=available"
aws ec2 describe-addresses --query "Addresses[?AssociationId==null]"
aws secretsmanager list-secrets --query "SecretList[?contains(Name,'rds')]"

The volume check matters because a terminated instance normally deletes its
root volume, but a volume left in available state bills for storage
indefinitely and appears in no instance listing. The secrets check matters
because an orphaned RDS-managed secret costs roughly 40 cents per month
forever. Both were clean.

========================================
HANDS-ON PRACTICE SUMMARY
========================================

Topics Covered:
- Discovering engine versions, instance classes and availability zones
  rather than assuming them
- DB subnet groups and the two-availability-zone requirement
- Security group rules by source group versus CIDR
- Free plan configuration restrictions
- RDS-managed master passwords in Secrets Manager
- Storage encryption at creation time
- Proving a network boundary from outside the VPC
- Non-interactive database access from a shell script
- Teardown in dependency order, and verifying it

Skills Practiced:
- Narrowing a query that returns nothing by removing filters one at a time
- Reading an empty JMESPath result as ambiguous rather than as an answer
- Building network and security layers before the resource that uses them
- Running provisioning steps in parallel and waiting with waiters
- Verifying a security control by confirming that access fails
- Looking resources up by name and tag rather than by remembered ID

Key Learnings:
- Index [0] answers "the first one", never "the right one"
- Piping a sorted list through head can hide the answer being looked for
- The same concept has different key names across services: ZoneName in
  EC2, Name in RDS
- An empty JMESPath result means either no matches or a non-existent key,
  and the two are indistinguishable
- A DB subnet group is a list of permitted placements, not a set of
  instances; two AZs buy optionality, not redundancy
- Free plan restrictions are enforced at the API and are a design
  constraint, not a billing footnote
- An RDS endpoint is a public DNS name resolving to a private address
- Unreachable port and rejected credentials are different failures with
  different causes
- Shell variables do not cross machines or survive a new terminal
- A teardown command that returns without error proves nothing; only the
  verification listing does

========================================
NEXT STEPS: Day 3 - Elastic Load Balancing
========================================
