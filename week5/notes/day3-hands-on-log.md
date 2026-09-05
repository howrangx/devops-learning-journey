DAY 3: S3 DEEP DIVE - HANDS-ON LOG
Session Record

LEARNING DATE: July 10, 2026
COMPLETED BY: Iman
REGION: us-east-1
ENVIRONMENT: WSL2 Ubuntu on Windows

========================================
1. SESSION SUMMARY
========================================

Enabled versioning on the existing S3 bucket, uploaded multiple
versions of the same file, retrieved an old version specifically,
tested deletion behavior under versioning, and recovered a deleted
object by removing its delete marker.

========================================
2. RESOURCES MODIFIED
========================================

S3 Bucket

- Name: iman-devops-week5-2026
- Versioning: enabled (cannot be fully disabled, only suspended)
- Object: version-test.txt, three versions uploaded, one delete
  marker created and later removed to restore the object

========================================
3. COMMANDS USED
========================================

Enable versioning:
aws s3api put-bucket-versioning \
  --bucket iman-devops-week5-2026 \
  --versioning-configuration Status=Enabled

Confirm versioning status:
aws s3api get-bucket-versioning --bucket iman-devops-week5-2026

Upload multiple versions of the same key:
aws s3 cp version-test.txt s3://iman-devops-week5-2026/version-test.txt
(repeated three times with different file content)

List all versions of an object:
aws s3api list-object-versions \
  --bucket iman-devops-week5-2026 \
  --prefix version-test.txt \
  --query "Versions[].[VersionId,IsLatest,LastModified]" \
  --output table

Retrieve a specific old version:
aws s3api get-object \
  --bucket iman-devops-week5-2026 \
  --key version-test.txt \
  --version-id <version-id> \
  old-version-download.txt

Delete the current version (creates a delete marker, does not erase
data):
aws s3 rm s3://iman-devops-week5-2026/version-test.txt

List versions and delete markers together:
aws s3api list-object-versions \
  --bucket iman-devops-week5-2026 \
  --prefix version-test.txt \
  --query "{Versions: Versions[].[VersionId,IsLatest], DeleteMarkers: DeleteMarkers[].[VersionId,IsLatest]}" \
  --output json

Remove a delete marker to restore the object:
aws s3api delete-object \
  --bucket iman-devops-week5-2026 \
  --key version-test.txt \
  --version-id <delete-marker-version-id>

========================================
4. ISSUES ENCOUNTERED
========================================

1. Initial attempt to query both Versions and DeleteMarkers in one
   --query expression using a comma failed with a ParamValidation
   error, since JMESPath does not allow joining two top-level
   expressions with a plain comma. Resolved using a multi-select
   hash syntax instead: {Versions: ..., DeleteMarkers: ...}

========================================
5. KEY TAKEAWAYS
========================================

- Deleting an object under versioning does not remove data, it adds
  a delete marker as the new latest version
- The object appears gone in normal listings (aws s3 ls) while
  versioned, but is fully recoverable
- True permanent deletion requires targeting a specific version ID
  directly, not a plain delete
- Removing a delete marker's own version ID restores the object to
  its previously visible state
- JMESPath multi-select hash syntax ({key: expr, key: expr}) is
  needed to combine multiple queries into one structured result

========================================
END OF DAY 3 HANDS-ON LOG
========================================
