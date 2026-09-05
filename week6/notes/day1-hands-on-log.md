DAY 1: IAM DEEP DIVE - HANDS-ON LOG
Session Record

LEARNING DATE: August 31, 2026
COMPLETED BY: Iman
REGION: us-east-1
ENVIRONMENT: WSL2 Ubuntu on Windows

========================================
1. SESSION OBJECTIVES
========================================

- Audit the current identity posture of the account
- Remediate the findings before building anything new
- Write a least-privilege policy by hand rather than attaching a managed one
- Create an IAM role with a service trust policy
- Build an instance profile from the CLI
- Prove on a live instance that an EC2 role removes the need for access keys
- Prove the negative case: confirm what the role cannot do

========================================
2. ACCOUNT AUDIT
========================================

Commands run:

aws sts get-caller-identity
aws iam list-attached-user-policies --user-name iman-devops
aws iam generate-credential-report
aws iam get-credential-report --query Content --output text | base64 -d

Findings:

Finding 1: No MFA on the root user
The credential report showed mfa_active false for the root account. Root
cannot be restricted by any IAM policy, so MFA is the only meaningful
control over it. Highest severity finding of the audit.

Finding 2: No MFA on iman-devops
Same field, same value, on a user holding AdministratorAccess.

Finding 3: iman-devops holds AdministratorAccess
An AWS managed policy granting unrestricted access. Appropriate for the
Week 5 learning phase, not appropriate going into a week that creates a
database.

Finding 4: Stale administrator access key
access_key_1_last_rotated 2026-07-08
access_key_1_last_used_date 2026-07-13
Seven weeks unused. An unused credential carries the full risk of the
permissions it grants and delivers no benefit in return.

Positive finding: root has no access keys
password_enabled true, access keys absent. This is the correct state. An
access key is a non-interactive credential that works from anywhere with
no login step, no session expiry, and no MFA prompt, and it is the
credential that most often leaks through git history and environment
files. Removing it from root leaves only the interactive path.

========================================
3. MULTI-REGION RESOURCE SWEEP
========================================

An initial sweep covered only the CLI default region. Since the billing
console had been used in a different region, the sweep was repeated
across four regions before any new resources were created.

for r in us-east-1 eu-north-1 eu-central-1 eu-west-1; do
  echo "=== $r ==="
  aws ec2 describe-instances --region $r \
    --filters "Name=instance-state-name,Values=running,stopped" \
    --query "Reservations[].Instances[].[InstanceId,State.name,InstanceType]" --output text
  aws ec2 describe-vpcs --region $r --query "Vpcs[?IsDefault==\`false\`].[VpcId,CidrBlock]" --output text
  aws ec2 describe-nat-gateways --region $r --query "NatGateways[?State=='available'].[NatGatewayId]" --output text
  aws ec2 describe-addresses --region $r --query "Addresses[].[PublicIp,AllocationId]" --output text
done

Result: all four regions clean. No instances, no non-default VPCs, no NAT
gateways, no Elastic IPs. Week 5 teardown was complete.

Lesson: a resource sweep run without --region only reports on one region
out of roughly thirty. NAT gateways in particular cost around 32 USD per
month and appear nowhere in the places normally checked.

========================================
4. BILLING POSITION
========================================

This account was created 2026-07-02, which places it under the AWS free
tier introduced for accounts opened after 15 July 2025. That plan provides
credits rather than per-service monthly allowances.

Credits remaining: 119.99 USD
Days remaining: 125

Consequence for Week 6: there is no separate free bucket per service.
Every resource draws down one credit pool. Approximate monthly costs if
left running:

- Application Load Balancer: 16 to 18 USD
- RDS db.t3.micro with 20 GB storage: about 15 USD
- NAT Gateway: about 32 USD plus data processing

Build, verify, tear down in the same session is a requirement for the
remainder of this week, not a preference.

========================================
5. REMEDIATION PERFORMED
========================================

5.1 Root MFA enabled

A virtual MFA device was assigned to the root user through the console.
The IAM dashboard subsequently reported zero security recommendations.

5.2 Access key rotation

The full five-step procedure was followed rather than the shortcut.

Step 1 - create the replacement:
aws iam create-access-key --user-name iman-devops

Step 2 - reconfigure the CLI:
aws configure
Note: the value shown in brackets at each prompt is the current setting.
Pressing Enter keeps it. The new key ID and secret had to be pasted in
explicitly.

Step 3 - verify the new key is live, and observe both keys active:
aws sts get-caller-identity
aws iam list-access-keys --user-name iman-devops --output table

Output showed two keys, both Active. This is the key observation of the
exercise. Creating a new access key has no effect whatsoever on the
existing one. A rotation that stops here has doubled the attack surface
rather than reduced it.

Step 4 - deactivate the old key, then confirm the CLI still works:
aws iam update-access-key --user-name iman-devops \
  --access-key-id OLD_KEY_ID --status Inactive
aws sts get-caller-identity

Step 5 - delete the old key:
aws iam delete-access-key --user-name iman-devops --access-key-id OLD_KEY_ID

Result: one active key, created 2026-08-31.

Why deactivate and delete are separate steps: deactivate is reversible,
delete is not. In a real environment nobody knows every place a key is
configured. Deactivating breaks the unknown consumers as recoverable
errors and they surface as complaints, and a single command restores
service. Deleting removes that escape hatch. The gap between the two steps
is a controlled discovery window.

Deleting immediately was acceptable here only because the credential
report provided evidence of seven weeks with no usage.

========================================
6. POLICY AUTHORING
========================================

File created: week6/configs/s3-week6-read.json

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ListTheBucket",
            "Effect": "Allow",
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::iman-devops-week5-2026"
        },
        {
            "Sid": "ReadObjectsInTheBucket",
            "Effect": "Allow",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::iman-devops-week5-2026/*"
        }
    ]
}

Two statements are required because the two actions operate on two
different resources. s3:ListBucket asks a bucket what it contains, so its
resource is the bare bucket ARN. s3:GetObject fetches one object, so its
resource is the object ARN ending in /*. They cannot share a Resource
line.

Error made and corrected during this exercise: Action and Resource values
were initially transposed. The file still parsed as valid JSON, because
python3 -m json.tool validates punctuation and has no concept of an IAM
policy.

Rule adopted: every Action value begins with a service prefix, every
Resource value begins with arn:. A value in the wrong field is visible at
a glance.

Why this matters beyond the obvious: AWS would have rejected the
transposed version with MalformedPolicyDocument, because an ARN does not
match the shape of an action name. But the subtler version of the same
mistake, s3:GetObject paired with the bare bucket ARN, is well-formed in
both fields. AWS accepts it, creates the policy, and every download then
fails with AccessDenied while nothing in the policy looks wrong.

Policy created:

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

aws iam create-policy \
  --policy-name week6-s3-read \
  --policy-document file://week6/configs/s3-week6-read.json

Capturing the account ID into a shell variable keeps it out of command
history and out of anything committed to the repository.

========================================
7. ROLE AND INSTANCE PROFILE
========================================

File created: week6/configs/ec2-trust-policy.json

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}

A role carries two policies answering two different questions.

The trust policy answers who may borrow this role. It names a principal,
here the EC2 service, and permits the single action sts:AssumeRole. It
mentions no S3 at all, because borrowing the role and using the role are
separate concerns.

The permission policy, week6-s3-read, answers what the borrower may do
once it holds the role.

The separation is what allows the same permissions to be handed to a
Lambda function later by editing one line of the trust policy, without
touching what the role can do.

Commands:

aws iam create-role \
  --role-name week6-ec2-s3-read \
  --assume-role-policy-document file://week6/configs/ec2-trust-policy.json

aws iam attach-role-policy \
  --role-name week6-ec2-s3-read \
  --policy-arn arn:aws:iam::ACCOUNT_ID:policy/week6-s3-read

aws iam create-instance-profile --instance-profile-name week6-ec2-s3-read

aws iam add-role-to-instance-profile \
  --instance-profile-name week6-ec2-s3-read \
  --role-name week6-ec2-s3-read

Observation: the create-instance-profile response contained "Roles": [].
The profile is created empty. Adding the role is a second, separate API
call. Creating a role in the console generates a matching instance profile
automatically; creating one from the CLI does not, so a role built this
way cannot be attached to any instance until the profile is created and
populated by hand.

Identifier prefixes observed across the session:
AIDA - IAM user
AROA - IAM role
AIPA - instance profile
ASIA - temporary session credential issued by STS

========================================
8. POLICY SIMULATION
========================================

Run before launching anything, at no cost.

aws iam simulate-principal-policy \
  --policy-source-arn arn:aws:iam::ACCOUNT_ID:role/week6-ec2-s3-read \
  --action-names s3:GetObject s3:PutObject s3:DeleteObject \
  --resource-arns arn:aws:s3:::iman-devops-week5-2026/test.txt \
  --query "EvaluationResults[].[EvalActionName,EvalDecision]" --output table

Results:
s3:GetObject      allowed
s3:PutObject      implicitDeny
s3:DeleteObject   implicitDeny

aws iam simulate-principal-policy \
  --policy-source-arn arn:aws:iam::ACCOUNT_ID:role/week6-ec2-s3-read \
  --action-names s3:ListBucket \
  --resource-arns arn:aws:s3:::iman-devops-week5-2026 \
  --query "EvaluationResults[].[EvalActionName,EvalDecision]" --output table

Result:
s3:ListBucket     allowed

implicitDeny versus explicitDeny:

implicitDeny means nothing allowed the action. This is the default state
of every permission in AWS. It can be turned into an allow later by adding
a permission in any policy that applies.

explicitDeny means a Deny statement matched. It cannot be overridden by
any Allow from any source.

The operational difference: an implicit deny in an incident means a
permission is missing and should be added. An explicit deny means someone
forbade it deliberately, and the correct next step is to find out why
before changing anything.

========================================
9. LIVE VERIFICATION ON EC2
========================================

Instance launched with the instance profile attached and no credentials
configured on it:

AMI_ID=$(aws ssm get-parameters \
  --names /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 \
  --query "Parameters[0].Value" --output text)

INSTANCE_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type t3.micro \
  --key-name week5-key \
  --security-group-ids WEEK5_SECURITY_GROUP_ID \
  --iam-instance-profile Name=week6-ec2-s3-read \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=week6-day1-iam-test},{Key=Week,Value=6}]' \
  --query "Instances[0].InstanceId" --output text)

Resolving the AMI through SSM rather than hardcoding an ID means the
command keeps working as AWS publishes new images.

Test 1: where do the credentials come from

aws configure list

NAME       : VALUE                : TYPE      : LOCATION
profile    : <not set>            : None      : None
access_key : ****************MOKH : iam-role  :
secret_key : ****************5P80 : iam-role  :
region     : us-east-1            : imds      :

TYPE reads iam-role and LOCATION is empty. There is no credentials file on
the instance. The CLI queried the instance metadata service and received
temporary credentials. The region was also supplied by metadata.

Test 2: the permitted action

aws s3 ls s3://iman-devops-week5-2026/

Listed successfully.

Test 3: a write, which the policy does not grant

aws s3 cp /etc/hostname s3://iman-devops-week5-2026/should-fail.txt

An error occurred (AccessDenied) when calling the PutObject operation:
User: arn:aws:sts::ACCOUNT_ID:assumed-role/week6-ec2-s3-read/i-INSTANCE_ID
is not authorized to perform: s3:PutObject on resource: ... because no
identity-based policy allows the s3:PutObject action

Test 4: an unrelated service

aws ec2 describe-instances

An error occurred (UnauthorizedOperation) ... because no identity-based
policy allows the ec2:DescribeInstances action

Reading the identity in those errors:
- The ARN begins arn:aws:sts rather than arn:aws:iam, because the
  credentials are temporary
- assumed-role rather than user
- The session name is the instance ID, which is how CloudTrail attributes
  an action to one specific machine rather than to the role in general

Reading the error wording: "because no identity-based policy allows" is
the phrasing of an implicit deny. An explicit deny produces a different
message, "with an explicit deny in an identity-based policy". The two
messages point at two different debugging paths.

Test 5: credentials at their source

TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 300" -s)

curl -H "X-aws-ec2-metadata-token: $TOKEN" -s \
  http://169.254.169.254/latest/meta-data/iam/security-credentials/

Returned: week6-ec2-s3-read

curl -H "X-aws-ec2-metadata-token: $TOKEN" -s \
  http://169.254.169.254/latest/meta-data/iam/security-credentials/week6-ec2-s3-read

Returned a JSON document containing Code, LastUpdated, Type, AccessKeyId
beginning ASIA, SecretAccessKey, Token, and Expiration. Values redacted
here deliberately.

The Expiration field is the entire argument for roles over keys. These
credentials stop working on their own and are replaced automatically. The
key deleted earlier in this session would have worked forever.

Operational note: this specific command returns live credentials. Its
output is never pasted into a chat, a ticket, a commit, or a log file.

========================================
10. TEARDOWN
========================================

aws ec2 terminate-instances --instance-ids $INSTANCE_ID \
  --query "TerminatingInstances[].[InstanceId,CurrentState.Name]" --output text

Result: shutting-down

aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running,pending,stopped" \
  --query "Reservations[].Instances[].[InstanceId]" --output text

Result: empty. No instances remain.

Retained deliberately for the rest of Week 6, at no cost:
- Policy week6-s3-read
- Role week6-ec2-s3-read
- Instance profile week6-ec2-s3-read

IAM objects carry no charge.

========================================
11. KEY LEARNINGS
========================================

- Creating a new access key does nothing to the old one. Both remain
  active until the old one is explicitly deactivated or deleted.
- Deactivate is reversible and delete is not, which is why they are
  separate steps separated by time in a real environment.
- Valid JSON is not a valid policy. Structural validation catches nothing
  about IAM semantics.
- A bucket ARN and an object ARN are different resources and need separate
  statements. AWS will accept the wrong pairing without complaint.
- A trust policy answers who may assume a role; a permission policy
  answers what the role may then do. They are separate documents because
  they are separate questions.
- Creating a role from the CLI does not create an instance profile, and
  the profile is created empty.
- implicitDeny means nothing granted it; explicitDeny means something
  forbade it and cannot be overridden.
- An instance with a role has no credentials file at all, and its
  credentials carry an expiry.
- A resource sweep without an explicit region reports on one region only.
- Under the post-July-2025 free tier there is no per-service free
  allowance. Every resource consumes the same credit pool.

========================================
12. FOLLOW-UP ITEMS
========================================

Open:
- iman-devops still holds AdministratorAccess and has no MFA. Adding MFA
  to that user is the next remediation step.
- Long-lived access keys remain in use for CLI access. IAM Identity Center
  (aws configure sso) or an assumed-role profile with mfa_serial would
  remove them entirely. Scheduled for Week 15, DevSecOps.

Deferred with reason:
- Reducing iman-devops below AdministratorAccess would obstruct the
  remaining weeks of the course and is not appropriate while the account
  is a single-user learning environment.

========================================
NEXT STEPS: Day 2 - RDS and Managed Databases
========================================
