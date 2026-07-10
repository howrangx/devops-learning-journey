# Day 3: S3 Deep Dive

## Versioning

By default, uploading a new object with the same key overwrites the
old one permanently. Versioning changes this: every upload to the
same key creates a new version, and old versions remain retrievable.

Key concepts:
- Once enabled, versioning cannot be fully disabled, only suspended
  (new uploads stop creating versions, but existing versions remain)
- Deleting an object with versioning enabled doesn't actually remove
  data; it adds a "delete marker" as the newest version. The object
  appears gone in normal listings, but prior versions are still there
  and recoverable
- Permanent deletion requires removing a specific version ID directly
- Versioning protects against accidental overwrites and deletions, at
  the cost of extra storage for every version kept

## Access Control

S3 access can be controlled at multiple layers:

- Block Public Access settings: account-wide and bucket-level
  switches that override everything else; AWS enables these by
  default on new buckets as a safety net
- Bucket Policy: a JSON document attached to the bucket defining who
  can perform which actions, the modern recommended approach
- IAM Policies: permissions attached to specific IAM users/roles
  (rather than the bucket itself), determining what that identity can
  do across any S3 resource
- ACLs (Access Control Lists): a legacy, older mechanism, mostly
  discouraged in favor of bucket policies today

For learning purposes, buckets should stay private by default, with
Block Public Access left enabled, unless there's a specific reason
to serve content publicly (such as static website hosting).

## Storage Classes

S3 offers multiple storage tiers trading cost against retrieval speed
and availability, useful for optimizing costs based on how often data
is actually accessed.

- Standard: default tier, frequent access, higher cost per GB
- Intelligent-Tiering: automatically moves objects between tiers
  based on access patterns, useful when access frequency is unknown
  or unpredictable
- Standard-IA (Infrequent Access): lower storage cost, but charges a
  retrieval fee, suited to backups accessed occasionally
- Glacier and Glacier Deep Archive: very low storage cost, but
  retrieval can take minutes to hours, meant for long-term archival
  data rarely, if ever, accessed

Storage class is set per-object and can be changed after upload
through lifecycle rules or manual transitions.

## Lifecycle Rules

Automated rules that transition objects between storage classes, or
delete them, after a specified number of days. Useful for
automatically moving old logs to cheaper storage, or expiring
temporary files without manual cleanup.

## Key Takeaways

- Versioning protects against accidental overwrite/delete, but
  increases storage usage and cost over time
- Bucket policies are the modern, recommended way to control S3
  access, not legacy ACLs
- Block Public Access is a safety default and should stay enabled
  unless there's a specific reason to serve public content
- Storage class selection should be driven by actual access patterns,
  not assumptions
