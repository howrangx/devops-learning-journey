DAY 1: IAM DEEP DIVE
Command Reference and Learning Notes

LEARNING DATE: August 31, 2026
COMPLETED BY: Iman

========================================
1. WHY IAM COMES FIRST
========================================

In Week 5 the IAM user iman-devops was created and given broad access so
that EC2, S3, and VPC work could proceed without friction. That is a
reasonable way to learn a service. It is not how a production account is
run.

IAM is the control plane for everything else in AWS. Every API call made
by the CLI, the console, an EC2 instance, or a Lambda function is checked
against IAM before anything happens. A misconfigured security group exposes
one instance. A misconfigured IAM policy can expose the whole account.

Two ideas drive the rest of this day:

Least privilege
Grant only the permissions a principal actually needs, scoped to the
specific resources it needs them on. Start from nothing and add, rather
than starting from everything and removing.

Roles over keys
Long-lived access keys are the most commonly leaked AWS credential. Roles
issue short-lived credentials that rotate automatically. Anywhere a role
can be used, it should be.

========================================
2. THE FOUR IAM IDENTITY TYPES
========================================

Users
A user represents a single person or a single application with long-lived
credentials. A user can have a console password, access keys, or both.

Groups
A group is a container for users. Policies attached to a group apply to
every user in it. Groups have no credentials and cannot be a principal in
a policy. They exist purely to avoid attaching the same policy to twenty
users individually.

Roles
A role is a set of permissions that can be assumed temporarily by anyone
the role trusts. A role has no password and no access keys. When assumed,
it issues temporary credentials through STS that expire, typically after
one hour.

Roles are used by:
- EC2 instances, through an instance profile
- Lambda functions, through an execution role
- Users in another AWS account, through cross-account access
- Federated identities from an external identity provider
- A user in the same account who needs to escalate briefly

Root user
The account owner. Has unrestricted access and cannot be limited by any
policy. It should have MFA enabled, no access keys, and should be used
only for the handful of tasks that require it, such as closing the account
or changing the support plan.

List what currently exists in the account:

aws iam list-users --query "Users[].UserName" --output table
aws iam list-groups --query "Groups[].GroupName" --output table
aws iam list-roles --query "Roles[].RoleName" --output table

Expected output for roles: several service-linked roles created
automatically by AWS, with names beginning AWSServiceRoleFor. Those are
managed by AWS and should not be edited.

Confirm the identity the CLI is currently using:

aws sts get-caller-identity

Expected output:
{
    "UserId": "AIDA...",
    "Account": "the AWS account ID",
    "Arn": "arn:aws:iam::the AWS account ID:user/iman-devops"
}

The UserId prefix is meaningful. AIDA is an IAM user, AROA is a role,
ASIA is a temporary session credential from STS.

========================================
3. ANATOMY OF A POLICY DOCUMENT
========================================

An IAM policy is a JSON document. Every policy has the same shape.

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowListingOneBucket",
            "Effect": "Allow",
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::iman-devops-week5-2026"
        }
    ]
}

Version
Always the literal string "2012-10-17". This is a policy language version,
not a date to be chosen. Omitting it silently disables features such as
policy variables.

Statement
An array of one or more statements. Each is evaluated independently.

Sid
Statement ID. Optional, free text, useful for reading a long policy later.

Effect
Either "Allow" or "Deny". Nothing else.

Action
The API operations covered, in the form service:Operation. Wildcards are
allowed: "s3:Get*" covers GetObject, GetBucketPolicy, and everything else
beginning with Get. "NotAction" is the inverse and is easy to get wrong.

Resource
The ARNs the statement applies to. Some actions do not operate on a
specific resource and require "*".

Condition
Optional. Additional tests that must all pass for the statement to apply.

Principal
Who the policy applies to. Only used in resource-based policies. An
identity-based policy has no Principal because the identity it is attached
to is the principal.

ARN structure:

arn:partition:service:region:account-id:resource

Examples:
arn:aws:s3:::my-bucket                     a bucket, no region or account
arn:aws:s3:::my-bucket/*                   every object inside it
arn:aws:ec2:eu-central-1:123456789012:instance/i-0abc123
arn:aws:iam::123456789012:user/iman-devops

Note the S3 bucket ARN has empty region and account fields, because bucket
names are globally unique. Note also that a bucket and the objects in it
are two different resources. A policy allowing s3:GetObject on
arn:aws:s3:::my-bucket will never work, because objects live at
arn:aws:s3:::my-bucket/*. This is the single most common IAM mistake.

========================================
4. IDENTITY-BASED VS RESOURCE-BASED POLICIES
========================================

Identity-based policy
Attached to a user, group, or role. Answers the question "what may this
identity do?"

Resource-based policy
Attached to the resource itself. Answers the question "who may act on this
resource?" Contains a Principal element. Supported by a limited set of
services: S3 bucket policies, SQS queue policies, SNS topic policies, KMS
key policies, Lambda function policies, and a few others.

Why both exist:

Within a single account, either one is enough. An identity policy allowing
s3:GetObject on a bucket works even if the bucket has no bucket policy.

Across accounts, both are usually required. Account A's role must be
allowed to call the action, and account B's resource policy must name
account A as a permitted principal. The exception is KMS, where the key
policy alone can be sufficient.

A resource-based policy example, an S3 bucket policy that permits one
specific role to read:

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowWebTierRead",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::the AWS account ID:role/week6-ec2-s3-read"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::iman-devops-week5-2026/*"
        }
    ]
}

========================================
5. HOW A REQUEST IS ACTUALLY EVALUATED
========================================

When any API call arrives, AWS runs a fixed evaluation. Understanding the
order removes most IAM confusion.

Step 1: Default deny
Every request starts denied. Permissions are additive from there.

Step 2: Explicit deny
If any applicable policy contains a Deny that matches, the request is
denied immediately and no further evaluation happens. An explicit deny can
never be overridden by any allow, anywhere.

Step 3: Service control policies
If the account belongs to an AWS Organization, SCPs set the maximum
permissions for the whole account. An SCP does not grant anything. It only
limits. If the SCP does not allow the action, the request is denied.

Step 4: Resource-based policy
If the resource has one and it explicitly allows the principal, the request
can be allowed here even without an identity policy, for principals in the
same account.

Step 5: Identity-based policy
The policies attached to the user, its groups, and any assumed role.

Step 6: Permission boundary
If the identity has a boundary attached, the effective permissions are the
intersection of the boundary and the identity policy. The boundary grants
nothing on its own. It caps.

Step 7: Session policy
If credentials came from AssumeRole with an inline session policy, that
caps the session further.

Final result: allow only if something allowed it and nothing denied it.

The practical summary:
- Deny always wins
- Boundaries and SCPs limit, they never grant
- Absence of an allow is a deny

Test evaluation without making a real call, using the policy simulator:

aws iam simulate-principal-policy \
  --policy-source-arn arn:aws:iam::the AWS account ID:user/iman-devops \
  --action-names s3:GetObject \
  --resource-arns arn:aws:s3:::iman-devops-week5-2026/test.txt

Expected output includes an EvalDecision field of either "allowed" or
"implicitDeny" or "explicitDeny". This is a safe way to reason about a
policy before deploying it.

========================================
6. MANAGED VS INLINE POLICIES
========================================

AWS managed policy
Written and maintained by AWS, such as AmazonS3ReadOnlyAccess. Convenient,
but almost always broader than needed, and AWS can change the contents
without notice.

Customer managed policy
Written in-house, stored as a standalone object, attachable to many
identities, versioned with up to five versions retained. This is the
recommended default for anything non-trivial.

Inline policy
Embedded directly inside one user, group, or role. Deleted with it. Cannot
be reused. Appropriate when the policy must never be attached anywhere
else, for example a break-glass role.

List the managed policies attached to a user:

aws iam list-attached-user-policies --user-name iman-devops

List inline policies on that user:

aws iam list-user-policies --user-name iman-devops

Read the contents of a customer managed policy. This takes two calls,
because a policy has versions and the ARN alone does not identify one:

aws iam get-policy --policy-arn arn:aws:iam::the AWS account ID:policy/week6-s3-read

Note the DefaultVersionId in the output, then:

aws iam get-policy-version \
  --policy-arn arn:aws:iam::the AWS account ID:policy/week6-s3-read \
  --version-id v1

========================================
7. ROLES AND INSTANCE PROFILES
========================================

A role has two policies attached, and confusing them is common.

Trust policy
Also called the assume role policy document. It answers "who is allowed to
become this role?" It is a resource-based policy on the role itself.

Permission policy
The normal identity-based policy attached to the role. It answers "what
may this role do once assumed?"

A trust policy allowing the EC2 service to assume the role:

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

Note that the Action is sts:AssumeRole, not the permissions the role will
have. The Principal is a service, not a user.

Instance profiles

An EC2 instance cannot be given a role directly. It is given an instance
profile, which is a thin container holding exactly one role. When a role
is created in the console an instance profile of the same name is created
automatically. When a role is created with the CLI it is not, and the
profile must be created and populated by hand. This trips up almost
everyone the first time.

Once attached, code on the instance retrieves credentials from the
instance metadata service, the same IMDSv2 endpoint explored in Week 5
Day 2. The AWS CLI and every AWS SDK do this automatically, which is why
an instance with a role needs no configuration file and no access keys at
all.

Retrieve the role name from inside an instance:

TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 300" -s)

curl -H "X-aws-ec2-metadata-token: $TOKEN" -s \
  http://169.254.169.254/latest/meta-data/iam/security-credentials/

Expected output: the name of the attached role.

========================================
8. CONDITIONS
========================================

Conditions turn a blunt policy into a precise one. All conditions in a
statement must be true for the statement to apply.

Restrict to a source IP range:

"Condition": {
    "IpAddress": {
        "aws:SourceIp": "203.0.113.0/24"
    }
}

Require multi-factor authentication:

"Condition": {
    "Bool": {
        "aws:MultiFactorAuthPresent": "true"
    }
}

Restrict to one region:

"Condition": {
    "StringEquals": {
        "aws:RequestedRegion": "eu-central-1"
    }
}

Restrict to resources carrying a specific tag:

"Condition": {
    "StringEquals": {
        "aws:ResourceTag/Environment": "development"
    }
}

Require that new resources are created with a specific tag value. Note the
key is aws:RequestTag with a slash and the tag name, which describes the
tag being sent in the request, not the tag already on a resource:

"Condition": {
    "StringEquals": {
        "aws:RequestTag/Owner": "iman"
    }
}

Require that a specific tag key is present at all, using a set operator
because aws:TagKeys is multi-valued:

"Condition": {
    "ForAllValues:StringEquals": {
        "aws:TagKeys": ["Owner", "Environment"]
    }
}

Common condition operators:
StringEquals, StringNotEquals, StringLike (supports wildcards)
NumericLessThan, NumericGreaterThan
DateGreaterThan, DateLessThan
Bool
IpAddress, NotIpAddress
ArnEquals, ArnLike

A caution on aws:MultiFactorAuthPresent. When used with Bool and "true"
in a Deny statement, a request made with credentials that cannot have MFA
at all, such as an EC2 instance role, evaluates the key as absent rather
than false. Use BoolIfExists in deny statements to avoid locking out
service principals unintentionally.

========================================
9. AUDITING AND CREDENTIAL HYGIENE
========================================

Credential report

An account-wide CSV listing every user, when passwords and keys were last
rotated, and whether MFA is enabled.

aws iam generate-credential-report

Wait a few seconds, then:

aws iam get-credential-report --query Content --output text | base64 -d

Expected output: CSV with columns including user, password_enabled,
password_last_used, mfa_active, access_key_1_last_rotated,
access_key_1_last_used_date.

Last accessed data

Shows which services an identity has actually used, which is the fastest
way to shrink an over-broad policy. Generate, then retrieve by job ID:

aws iam generate-service-last-accessed-details \
  --arn arn:aws:iam::the AWS account ID:user/iman-devops

aws iam get-service-last-accessed-details --job-id JOB_ID_FROM_PREVIOUS

Access keys

List keys for a user, including creation date:

aws iam list-access-keys --user-name iman-devops

The rotation procedure, in order, so access is never lost:
1. Create a second key: aws iam create-access-key --user-name iman-devops
2. Update every place the old key is configured
3. Deactivate the old key but do not delete it:
   aws iam update-access-key --user-name iman-devops \
     --access-key-id OLD_KEY_ID --status Inactive
4. Confirm nothing broke over the following days
5. Delete the old key:
   aws iam delete-access-key --user-name iman-devops \
     --access-key-id OLD_KEY_ID

An account may hold at most two access keys per user, which is exactly what
this procedure needs.

IAM Access Analyzer

Identifies resources shared outside the account or the organization.

aws accessanalyzer create-analyzer \
  --analyzer-name week6-analyzer \
  --type ACCOUNT

aws accessanalyzer list-findings \
  --analyzer-arn ANALYZER_ARN_FROM_PREVIOUS

There is no charge for an external access analyzer at the account level.

========================================
10. HANDS-ON EXERCISES
========================================

All exercises use the AWS CLI from WSL. Every file created here belongs in
week6/configs/, and every script in week6/scripts/.

Exercise 1: Read the account's current identity posture

aws sts get-caller-identity
aws iam list-attached-user-policies --user-name iman-devops
aws iam generate-credential-report
aws iam get-credential-report --query Content --output text | base64 -d

Goal: know exactly what iman-devops can do today, and whether MFA is on.

Exercise 2: Write a least-privilege customer managed policy

Create week6/configs/s3-week6-read.json:

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

Create the policy:

aws iam create-policy \
  --policy-name week6-s3-read \
  --policy-document file://week6/configs/s3-week6-read.json

Expected output: JSON containing the new policy ARN and DefaultVersionId
of v1.

Note the two separate statements. ListBucket acts on the bucket, GetObject
acts on the objects. They cannot share a Resource line.

Exercise 3: Create a role for EC2 and attach the policy

Create week6/configs/ec2-trust-policy.json:

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

Create the role and attach the policy:

aws iam create-role \
  --role-name week6-ec2-s3-read \
  --assume-role-policy-document file://week6/configs/ec2-trust-policy.json

aws iam attach-role-policy \
  --role-name week6-ec2-s3-read \
  --policy-arn arn:aws:iam::the AWS account ID:policy/week6-s3-read

Create the instance profile and put the role inside it:

aws iam create-instance-profile \
  --instance-profile-name week6-ec2-s3-read

aws iam add-role-to-instance-profile \
  --instance-profile-name week6-ec2-s3-read \
  --role-name week6-ec2-s3-read

Verify:

aws iam get-instance-profile \
  --instance-profile-name week6-ec2-s3-read \
  --query "InstanceProfile.Roles[].RoleName"

Expected output: a list containing week6-ec2-s3-read.

Exercise 4: Prove the role works, and prove its limits

Launch a t3.micro instance using the existing week5-key and week5-sg, with
the instance profile attached. Then over SSH:

aws s3 ls s3://iman-devops-week5-2026/

Expected: the bucket contents list successfully, with no credentials
configured anywhere on the instance.

aws s3 cp /etc/hostname s3://iman-devops-week5-2026/should-fail.txt

Expected: An error occurred (AccessDenied). The role can read and cannot
write, which is the entire point of least privilege.

aws ec2 describe-instances

Expected: AccessDenied as well. The role grants S3 read only.

Terminate the instance immediately after this exercise.

Exercise 5: Simulate before deploying

aws iam simulate-principal-policy \
  --policy-source-arn arn:aws:iam::the AWS account ID:role/week6-ec2-s3-read \
  --action-names s3:GetObject s3:PutObject \
  --resource-arns arn:aws:s3:::iman-devops-week5-2026/test.txt

Expected: allowed for GetObject, implicitDeny for PutObject.

========================================
11. TEARDOWN
========================================

IAM users, roles, and policies carry no charge, so they may be kept for the
Week 6 capstone. The EC2 instance from Exercise 4 must not be.

aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running" \
  --query "Reservations[].Instances[].[InstanceId,InstanceType]" \
  --output table

aws ec2 terminate-instances --instance-ids INSTANCE_ID

Confirm nothing else is running:

aws ec2 describe-addresses \
  --query "Addresses[?AssociationId==null].[PublicIp,AllocationId]" \
  --output table

Any Elastic IP listed by that command is allocated but unattached, and is
being billed. Release it:

aws ec2 release-address --allocation-id ALLOCATION_ID

========================================
HANDS-ON PRACTICE SUMMARY
========================================

Topics Covered:
- IAM identity types and when each applies
- Policy document structure and ARN format
- Identity-based vs resource-based policies
- The full request evaluation order
- Managed, customer managed, and inline policies
- Roles, trust policies, and instance profiles
- Condition keys and operators
- Credential reports, last-accessed data, and key rotation
- IAM Access Analyzer

Skills Practiced:
- Writing a policy document from scratch rather than attaching a managed one
- Separating bucket-level and object-level permissions correctly
- Creating a role with a service trust policy
- Building an instance profile by hand from the CLI
- Verifying permissions negatively, by confirming what is denied
- Simulating a policy before deploying it

Artifacts Created:
- configs/s3-week6-read.json: least-privilege S3 read policy
- configs/ec2-trust-policy.json: EC2 service trust policy
- IAM policy week6-s3-read
- IAM role week6-ec2-s3-read
- Instance profile week6-ec2-s3-read

Key Learnings:
- A bucket ARN and an object ARN are different resources and need
  separate statements
- Creating a role from the CLI does not create an instance profile
- An explicit deny cannot be overridden by any allow
- Permission boundaries and SCPs limit permissions, they never grant them
- Use BoolIfExists rather than Bool for MFA conditions in deny statements
- An instance with a role needs no access keys at all

========================================
NEXT STEPS: Day 2 - RDS and Managed Databases
========================================
