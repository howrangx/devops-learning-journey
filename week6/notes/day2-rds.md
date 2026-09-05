DAY 2: RDS AND MANAGED DATABASES
Command Reference and Learning Notes

LEARNING DATE: September 5, 2026
COMPLETED BY: Iman

========================================
1. WHAT RDS ACTUALLY MANAGES
========================================

A database on an EC2 instance is a database that has to be operated by
hand: installing the engine, patching it, configuring backups, testing
restores, setting up replication, monitoring disk growth, and handling
failover at three in the morning.

RDS takes over a specific list of those jobs:

- Provisioning the instance and installing the engine
- Operating system and engine patching, within a maintenance window
- Automated daily backups and transaction log capture
- Point-in-time recovery
- Synchronous standby replication and automatic failover, if Multi-AZ
- Read replica creation and management
- Storage scaling, including automatic growth if enabled
- Metrics and event notifications

It does not take over:

- Schema design, indexing, and query performance
- Deciding what to back up beyond the whole instance
- Access control inside the database, meaning users and grants
- Application-side connection pooling and retry logic
- Cost. A managed database costs more per hour than the raw compute.

The trade is control for time. There is no shell on an RDS host and no way
to install arbitrary extensions or plugins. Everything that would normally
be a config file edit happens through a parameter group instead. For most
workloads that is a good trade. For workloads that need an unusual
extension or kernel-level tuning, it is not.

========================================
2. ENGINES AND INSTANCE CLASSES
========================================

Engines available on RDS:

MySQL, PostgreSQL, MariaDB, Oracle, SQL Server, and Amazon Aurora, which
is AWS's own MySQL and PostgreSQL compatible engine with a different
storage layer.

Aurora is worth knowing about but is not part of this week. Its storage is
distributed across three availability zones with six copies, it scales
storage automatically, and it fails over faster than standard RDS. It also
has no free or low-cost tier, so it is not something to experiment with on
a credit budget.

Never hardcode an engine version. Ask what is currently available:

aws rds describe-db-engine-versions \
  --engine mysql \
  --query "DBEngineVersions[].EngineVersion" \
  --output text

Expected output: a list of MySQL versions, oldest to newest.

Instance classes follow the same families as EC2, prefixed with db:

- db.t3 and db.t4g - burstable, cheapest, fine for development
- db.m - general purpose, balanced CPU and memory
- db.r - memory optimised, for large working sets

db.t4g classes run on Graviton and are slightly cheaper than db.t3 for the
same specification.

Confirm a class is actually orderable for the chosen engine and region
before trying to launch, because the error message if it is not is
unhelpful:

aws rds describe-orderable-db-instance-options \
  --engine mysql \
  --db-instance-class db.t3.micro \
  --query "OrderableDBInstanceOptions[0].[EngineVersion,StorageType,MultiAZCapable]" \
  --output text

========================================
3. STORAGE
========================================

Storage types:

gp2 and gp3 - general purpose SSD. gp3 allows IOPS and throughput to be
provisioned independently of size, which is usually the better default.

io1 and io2 - provisioned IOPS SSD, for workloads that need guaranteed
high IOPS. Considerably more expensive.

magnetic - legacy, do not use.

Two properties worth understanding early.

Minimum size. MySQL and PostgreSQL on RDS require at least 20 GB.

Storage autoscaling. Setting --max-allocated-storage above
--allocated-storage lets RDS grow the volume automatically when free space
runs low. This prevents the most common production database outage, which
is a full disk. It also means storage costs can grow without anyone
approving it, so the maximum is a real budget decision, not a formality.

Storage can be increased but never decreased. Shrinking requires dumping
and reloading into a new instance.

========================================
4. DB SUBNET GROUPS
========================================

An RDS instance does not take a subnet. It takes a DB subnet group, which
is a named collection of subnets, and RDS picks one from the group.

A DB subnet group must contain subnets in at least two availability zones,
even for a single-AZ instance. This surprises people, and the reason is
that AWS wants the option of promoting the instance to Multi-AZ later
without the network having to be rebuilt.

Find the subnets in a VPC and which AZ each is in:

aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=VPC_ID" \
  --query "Subnets[].[SubnetId,AvailabilityZone,CidrBlock]" \
  --output table

Create the group:

aws rds create-db-subnet-group \
  --db-subnet-group-name week6-db-subnets \
  --db-subnet-group-description "Week 6 database subnets" \
  --subnet-ids SUBNET_ID_A SUBNET_ID_B

The subnets chosen determine reachability. Public subnets plus
--publicly-accessible gives the instance a public DNS name that resolves
to a routable address. Private subnets, or public subnets with
--no-publicly-accessible, mean the database can only be reached from
inside the VPC.

Default to not publicly accessible. A database exposed to the internet and
protected only by a password is one leaked credential away from a breach,
and RDS endpoints are trivially discoverable.

========================================
5. PARAMETER GROUPS AND OPTION GROUPS
========================================

Because there is no shell on the host, engine configuration happens
through a parameter group. A parameter group is the RDS equivalent of
my.cnf or postgresql.conf.

Every instance gets a default parameter group, and the default is not
editable. Changing any setting means creating a new group and associating
it with the instance.

aws rds create-db-parameter-group \
  --db-parameter-group-name week6-mysql-params \
  --db-parameter-group-family mysql8.0 \
  --description "Week 6 custom parameters"

aws rds modify-db-parameter-group \
  --db-parameter-group-name week6-mysql-params \
  --parameters "ParameterName=max_connections,ParameterValue=100,ApplyMethod=pending-reboot"

ApplyMethod matters. Parameters are either dynamic, meaning they take
effect immediately, or static, meaning they require a reboot. Setting
ApplyMethod=immediate on a static parameter is rejected. Check which a
parameter is:

aws rds describe-engine-default-parameters \
  --db-parameter-group-family mysql8.0 \
  --query "EngineDefaults.Parameters[?ParameterName=='max_connections'].[ParameterName,ApplyType,ParameterValue]" \
  --output text

Option groups are a separate mechanism for engine features that are more
than a setting, such as Oracle Enterprise Manager or SQL Server backup to
S3. MySQL and PostgreSQL rarely need them.

========================================
6. MULTI-AZ VERSUS READ REPLICAS
========================================

These two get confused constantly. They solve different problems and are
not substitutes.

Multi-AZ - availability

A standby instance in a second availability zone, kept in sync by
synchronous replication. It cannot be read from, connected to, or
addressed in any way. It exists only to take over.

On failure, RDS repoints the same endpoint DNS name at the standby.
Failover typically completes in 60 to 120 seconds. The application sees
dropped connections and then recovery, with no configuration change.

Multi-AZ roughly doubles the cost, because two instances are being paid
for to serve one workload.

Read replicas - scale and geography

An asynchronously replicated copy with its own endpoint, which can be read
from. Replicas take read load off the primary, serve reports without
touching production, or keep a copy in another region.

Because replication is asynchronous, a replica can lag. An application
that writes and then immediately reads from a replica may not see its own
write. This is a real class of bug and it is why read routing has to be a
deliberate decision, not a default.

A read replica can be promoted to a standalone instance, which is a
disaster recovery path but not automatic failover.

Summary:
- Need the database to survive an AZ failure: Multi-AZ
- Need more read throughput: read replicas
- Need both: use both, they are independent settings

========================================
7. BACKUPS, SNAPSHOTS, AND RECOVERY
========================================

Automated backups

A daily storage snapshot plus continuous capture of transaction logs,
retained for a configurable period. Setting --backup-retention-period to 0
disables backups entirely, which also disables point-in-time recovery.
Never do this on anything that matters.

Automated backups are deleted when the instance is deleted, unless
explicitly retained.

Manual snapshots

Taken on demand, kept until explicitly deleted, and they survive instance
deletion. This is the snapshot to take before a risky migration.

aws rds create-db-snapshot \
  --db-instance-identifier week6-mysql \
  --db-snapshot-identifier week6-mysql-manual-1

Point-in-time recovery

Restores to any second within the retention window, by replaying
transaction logs onto the nearest snapshot. It always creates a NEW
instance. It never overwrites the existing one.

aws rds restore-db-instance-to-point-in-time \
  --source-db-instance-identifier week6-mysql \
  --target-db-instance-identifier week6-mysql-restored \
  --restore-time 2026-09-05T14:30:00Z

The operational consequence: recovery is not instant. It means provisioning
a new instance, waiting for it, and then repointing the application.
Recovery time objectives should be planned around that, not around the idea
that the data "comes back".

The rule that matters more than any of this: a backup that has never been
restored is not a backup, it is a hope. Test the restore.

========================================
8. SECURING THE DATABASE
========================================

Four layers, and all four should be in place.

Network placement
Not publicly accessible, in private subnets where the architecture allows.
This is the strongest control because it removes the attack surface rather
than guarding it.

Security groups
The database security group should allow the engine port from the
application security group, not from a CIDR block. Referencing a security
group as the source means the rule follows the instances automatically as
they are created and destroyed. Writing a CIDR means maintaining a list of
addresses by hand.

aws ec2 authorize-security-group-ingress \
  --group-id DB_SECURITY_GROUP_ID \
  --protocol tcp --port 3306 \
  --source-group APP_SECURITY_GROUP_ID

That single command is the most important line of the day. Source-group
referencing is what makes the two-tier pattern hold together.

Credentials
The master password should never be typed into a file, a script, or a
command that lands in shell history. Two better approaches:

Read it into a variable that is not written anywhere:

read -s -p "Master password: " DB_PASSWORD
echo

Or let RDS own it entirely, which is the production answer:

aws rds create-db-instance \
  ... \
  --manage-master-user-password

With that flag RDS generates the password, stores it in AWS Secrets
Manager, and rotates it on a schedule. Nothing ever sees the plaintext.
Retrieval:

aws rds describe-db-instances \
  --db-instance-identifier week6-mysql \
  --query "DBInstances[0].MasterUserSecret.SecretArn" --output text

aws secretsmanager get-secret-value --secret-id SECRET_ARN \
  --query SecretString --output text

Secrets Manager charges per secret per month, so this is not free, but the
amount is small and the practice is correct.

Encryption
--storage-encrypted encrypts the volume, snapshots, and read replicas with
KMS. It costs nothing extra on the RDS side and can only be set at
creation time. An unencrypted instance cannot be converted in place. The
procedure is to snapshot it, copy the snapshot with encryption enabled, and
restore. Enabling it at creation means the problem never arises.

Database-level users
The master user is not the application user. Create a restricted user with
grants on one schema and use that from the application. The same
least-privilege logic as Day 1, one layer further in.

========================================
9. CONNECTING FROM EC2
========================================

The endpoint is a DNS name, not an address:

aws rds describe-db-instances \
  --db-instance-identifier week6-mysql \
  --query "DBInstances[0].Endpoint.[Address,Port]" --output text

Expected output resembles:
week6-mysql.abc123xyz.us-east-1.rds.amazonaws.com    3306

Never hardcode the resolved IP. RDS changes it on failover, and that is
precisely the mechanism that makes failover transparent.

Install a client on Amazon Linux 2023:

sudo dnf install -y mariadb105

That provides the mysql command, which speaks to MySQL and MariaDB alike.
For PostgreSQL the package is postgresql15.

Connect:

mysql -h ENDPOINT_ADDRESS -P 3306 -u admin -p

Test without a client, to isolate a network problem from a credentials
problem:

timeout 5 bash -c "cat < /dev/null > /dev/tcp/ENDPOINT_ADDRESS/3306" \
  && echo "port reachable" || echo "port not reachable"

That distinction is the whole of RDS troubleshooting. If the port is not
reachable, the problem is a security group, a subnet, or public
accessibility. If it is reachable but the login fails, the problem is
credentials or database-level grants. Establish which half the failure is
in before changing anything.

========================================
10. MONITORING AND MAINTENANCE
========================================

Metrics published to CloudWatch by default include CPUUtilization,
FreeableMemory, FreeStorageSpace, DatabaseConnections, ReadLatency,
WriteLatency, and ReplicaLag.

FreeStorageSpace is the one that pages people at night. Alarm on it.

Enhanced Monitoring adds OS-level metrics at up to one-second granularity
and costs extra. Performance Insights adds query-level analysis with a
free retention tier of seven days, and it is the fastest way to find which
query is causing a problem.

Maintenance and backup windows are weekly and daily slots when AWS may
patch and when backups run. Set them explicitly to a quiet period rather
than accepting the random default:

--preferred-maintenance-window "sun:05:00-sun:06:00"
--preferred-backup-window "03:00-04:00"

Times are UTC.

Deletion protection prevents an accidental delete-db-instance from
succeeding. Turn it on for anything real. It has to be disabled before a
genuine deletion, which is the point.

--deletion-protection

========================================
11. COST MODEL
========================================

An RDS instance bills for four things at once:

- Instance hours, whether or not any query runs
- Allocated storage per GB-month, whether or not it is used
- Backup storage beyond the size of the instance
- Data transfer out

Approximate rates for db.t3.micro with 20 GB gp3 in us-east-1: roughly 12
to 15 USD per month. Multi-AZ roughly doubles the instance portion.

Stopping an instance stops instance-hour charges but not storage charges,
and RDS automatically restarts a stopped instance after seven days. It is
not a way to park a database indefinitely.

For this account, on the credit-based plan, the only safe pattern is the
one used all week: create, verify, delete in the same session.

========================================
12. HANDS-ON EXERCISES
========================================

Prerequisite: run the multi-region sweep and check the credit balance
before starting. Everything below bills by the hour.

Exercise 1: discover, do not assume

Find the current engine version, confirm the instance class is orderable,
and list the subnets available in the default VPC. Nothing is created in
this step and nothing costs anything.

Exercise 2: build the network and security layer first

Create a DB subnet group across two availability zones. Create a security
group for the database. Add one ingress rule allowing port 3306 from the
Week 5 security group, referenced as a source group rather than a CIDR.

Doing this before the instance means the database is never briefly exposed
while rules are being added.

Exercise 3: launch the instance

A db.t3.micro, 20 GB gp3, encrypted, not publicly accessible, with a seven
day backup retention period, in the subnet group just created. The master
password read into a shell variable rather than typed into the command.

Creation takes five to ten minutes. Use the waiter rather than polling by
hand:

aws rds wait db-instance-available --db-instance-identifier week6-mysql

Exercise 4: connect and prove the boundary

From an EC2 instance in the Week 5 security group, install the client,
connect, create a schema and a table, insert a row, and read it back.

Then prove the boundary works: attempt to reach the endpoint from WSL,
outside the VPC entirely. It must fail. A database reachable from a laptop
is a database the internet can reach.

Exercise 5: snapshot and inspect recovery options

Take a manual snapshot. Look at the automated backup window and the
earliest restorable time. Do not run a restore, because that provisions a
second billable instance, but read the values and understand what they
would mean during an incident.

========================================
13. TEARDOWN
========================================

Order matters. The instance holds the subnet group and the security group,
so it goes first.

aws rds delete-db-instance \
  --db-instance-identifier week6-mysql \
  --skip-final-snapshot \
  --delete-automated-backups

aws rds wait db-instance-deleted --db-instance-identifier week6-mysql

--skip-final-snapshot is correct here and wrong in production, where the
final snapshot is the last line of defence against a mistaken deletion.

Then remove what the instance was holding:

aws rds delete-db-subnet-group --db-subnet-group-name week6-db-subnets
aws ec2 delete-security-group --group-id DB_SECURITY_GROUP_ID

Terminate any EC2 instance launched for the connection test.

Finally, confirm nothing was left behind. Snapshots survive instance
deletion and bill for storage, and this is the single most common way a
teardown quietly fails:

aws rds describe-db-instances --query "DBInstances[].DBInstanceIdentifier"
aws rds describe-db-snapshots --snapshot-type manual \
  --query "DBSnapshots[].[DBSnapshotIdentifier,AllocatedStorage]" --output table

========================================
HANDS-ON PRACTICE SUMMARY
========================================

Topics Covered:
- What RDS manages and what remains the operator's job
- Engines, instance classes, and discovering what is orderable
- Storage types, minimum sizes, and autoscaling
- DB subnet groups and the two-AZ requirement
- Parameter groups, and dynamic versus static parameters
- Multi-AZ versus read replicas
- Automated backups, manual snapshots, point-in-time recovery
- Network placement, source-group security rules, credential handling,
  and encryption at rest
- Connecting from EC2 and isolating network from credential failures
- CloudWatch metrics and maintenance windows
- The RDS cost model

Skills Practiced:
- Building the network and security layer before the resource that uses it
- Referencing a security group as a rule source instead of a CIDR
- Keeping a master password out of files and shell history
- Using waiters instead of polling
- Verifying a security boundary by confirming access fails from outside
- Tearing down in dependency order and checking for orphaned snapshots

Key Learnings:
- A DB subnet group needs two availability zones even for a single-AZ
  instance
- Storage can grow but never shrink
- Multi-AZ is availability and cannot be read from; read replicas are
  throughput and can lag
- Point-in-time recovery creates a new instance and takes real time
- Encryption can only be enabled at creation
- A stopped instance restarts itself after seven days and still bills for
  storage
- Snapshots outlive the instance and keep billing

========================================
NEXT STEPS: Day 3 - Elastic Load Balancing
========================================
