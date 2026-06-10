DAY 4: COLLABORATION AND PULL REQUESTS
Command Reference and Learning Notes

LEARNING DATE: June 10, 2026
COMPLETED BY: Iman

========================================
1. PULL REQUEST BASICS
========================================

What is a Pull Request?
- Request to merge branch into another
- GitHub/GitLab/Bitbucket feature
- Code review mechanism
- Discussion and collaboration tool
- Not a Git feature (platform-specific)

Why Use Pull Requests?
- Code review before merge
- Discussion of changes
- Automated testing
- Prevents direct main branch commits
- Documents decision making
- Audit trail of changes
- Team accountability

Pull Request Workflow:
1. Create feature branch
2. Make changes and push
3. Create pull request on GitHub
4. Reviewers examine changes
5. Address feedback with commits
6. Approval from reviewers
7. Merge pull request
8. Delete branch

Components of Pull Request:
- Title (clear, concise)
- Description (what, why, how)
- Changed files
- Diff view
- Comments and reviews
- Status checks
- Merge options

========================================
2. CREATING PULL REQUESTS
========================================

Creating PR on GitHub (Web Interface)

Steps:
1. Push feature branch to remote
   git push origin feature-name

2. Go to GitHub repository

3. Click "Pull requests" tab

4. Click "New pull request"

5. Select branches:
   - Base: main (or develop)
   - Compare: feature-name

6. Review changes

7. Click "Create pull request"

8. Fill in:
   - Title (50 chars or less)
   - Description
   - Labels
   - Assignees
   - Reviewers

9. Click "Create pull request"

Pull Request Title Examples:

Good:
"Add user authentication module"
"Fix payment processing crash"
"Update documentation for API"

Bad:
"Updates"
"Work in progress"
"Fix stuff"

Pull Request Description Examples:

Good:
"Implement user authentication

What:
- Add login functionality
- Add password hashing with bcrypt
- Add session management

Why:
- Required for user accounts
- Improves security

How:
- Uses bcrypt for password hashing
- Sessions stored in database
- 24-hour token expiration

Testing:
- Unit tests pass
- Integration tests pass
- Manual testing completed"

Bad:
"Made some changes"

========================================
3. REVIEWING PULL REQUESTS
========================================

Code Review Process:
1. Reviewer reads PR description
2. Reviews changed files
3. Examines diffs line by line
4. Tests changes locally
5. Provides feedback
6. Approves or requests changes

Reviewer Responsibilities:
- Check code quality
- Verify tests exist
- Look for security issues
- Check for performance problems
- Ensure documentation updated
- Verify follows conventions

GitHub Review Options:

Comment:
- General comment on PR
- Question or suggestion
- No approval/rejection

Approve:
- Review complete
- Changes look good
- Ready to merge
- Cannot block if not required

Request Changes:
- Issues found
- Must be addressed
- Blocks merge
- Requires re-review

Reviewing on GitHub:

1. Click "Files changed" tab

2. Hover over line for review

3. Click + icon to comment

4. Leave comment

5. Click "Start a review"

6. Add more comments

7. Click "Review changes"

8. Select option:
   - Comment
   - Approve
   - Request changes

9. Add summary message

10. Click "Submit review"

Review Best Practices:
- Be constructive and kind
- Ask questions, don't demand
- Acknowledge good work
- Focus on code, not person
- Explain why change needed
- Suggest improvements
- Test changes locally

Common Review Comments:

"Can you add error handling for this case?"
"This could be more efficient by using..."
"Please add unit tests for this function"
"Great implementation of this feature"
"Did you consider edge case where...?"
"Documentation should be updated for..."

========================================
4. ADDRESSING FEEDBACK
========================================

Responding to Review Comments:

1. Read comment
2. Discuss or fix as appropriate
3. Make changes
4. Commit with clear message
5. Push to same branch
6. Comment on review item
7. Request re-review

PR Message Examples:

"Good point. Fixed by adding error handling."
"Updated to use the more efficient approach."
"Added unit tests in latest commit."
"Disagree because... [explanation]"

Making Changes to PR:

When reviewer requests changes:
git checkout feature-branch
(make changes)
git add .
git commit -m "Address review feedback: improve error handling"
git push origin feature-branch

(GitHub shows new commits automatically)

Re-requesting Review:

Click "Re-request review" on reviewer
Or reply to comment asking for re-review

Conversation in PR:

Use comments for:
- Questions
- Suggestions
- Discussions
- Clarifications
- Status updates

Thread conversations:
- Keeps related discussion together
- Resolves when addressed
- Maintains context

========================================
5. MERGING PULL REQUESTS
========================================

Merge Options on GitHub:

Create a merge commit:
- Creates merge commit
- Preserves all commits
- Non-linear history
- Good for larger PRs

Squash and merge:
- Combines all commits
- Creates one commit on main
- Clean linear history
- Good for feature branches

Rebase and merge:
- Replays commits on base
- No merge commit
- Linear history
- Good for small focused PRs

Deleting Branch After Merge:

GitHub offers: "Delete branch" button
Or via command line:
git push origin --delete feature-branch
git branch -d feature-branch (local)

Merge Checks:
- All required reviews approved
- Status checks passed
- No conflicts
- Branch up to date with base

Merging via Command Line:

git checkout main
git pull origin main
git merge feature-branch
git push origin main

Or via GitHub (recommended):
- Review on web interface
- Click "Merge pull request"
- Confirm merge

========================================
6. CONFLICT RESOLUTION IN PR
========================================

When Conflicts Occur:

GitHub shows: "This branch has conflicts"

Resolving via Web:
- GitHub provides conflict resolution tool
- Shows conflicting sections
- Mark as resolved
- Commit resolution
- Finalize merge

Resolving Locally:

git checkout feature-branch
git fetch origin
git rebase origin/main
(resolve conflicts)
git add .
git rebase --continue
git push --force origin feature-branch

Then request re-review and merge.

Preventing Conflicts:

Keep branches short-lived
Rebase frequently:
git fetch origin
git rebase origin/main

Keep PR scope focused
Communicate with team

========================================
7. TEAM COLLABORATION PRACTICES
========================================

Branch Naming Conventions:

Descriptive names:
feature/user-authentication
feature/payment-integration
bugfix/login-crash
hotfix/security-patch
docs/api-documentation

Format:
type/description
type: feature, bugfix, hotfix, docs, refactor

Commit Message Conventions:

Use conventional commits:
feat: new feature
fix: bug fix
docs: documentation
style: code style (no logic change)
refactor: restructure without changing behavior
test: tests
chore: maintenance

Examples:
"feat: add two-factor authentication"
"fix: prevent null pointer in user module"
"docs: update installation instructions"
"refactor: simplify payment processing"

PR Size Guidelines:

Small: <200 lines changed
Good size: 200-400 lines
Large: 400-800 lines
Very large: >800 lines

Large PRs:
- Take longer to review
- More likely to have issues
- Should be broken into smaller PRs

Review Time Guidelines:

Try to review within:
- 24 hours: critical
- 48 hours: important
- 1 week: routine

Blocked by waiting:
Common reason for delayed merges
Set expectations early

Code Review Standards:

Must have:
- Code follows style guide
- Tests pass
- No obvious bugs
- Documentation updated

Nice to have:
- Performance improvements
- Security best practices
- Readability improvements
- Code comments where needed

========================================
8. GITHUB DISCUSSION AND COLLABORATION
========================================

Comments vs Conversations:

PR Comments:
- On specific code
- Line-specific
- Code review context

PR Conversations:
- General PR discussion
- Larger topics
- Design decisions

Using Labels:

Organization:
type: bug, feature, documentation
priority: critical, high, medium, low
status: in-progress, review, blocked
area: backend, frontend, database

Assigning PRs:

Who should PR be assigned to:
- PR author (shows they own)
- Primary reviewer
- Code owner
- Team lead

GitHub Teams:

Create teams:
Organize by project
Organize by expertise

Use for:
- Code owners (@mention)
- Default reviewers
- Permissions

CODEOWNERS File:

Create .github/CODEOWNERS file:

# Backend code
backend/ @backend-team

# Frontend code
frontend/ @frontend-team

# Database
database/ @database-expert

# Security
security/ @security-team

Auto-request these reviewers on PR

========================================
9. COMMON COLLABORATION ISSUES
========================================

Issue: PR Blocked on Approval

Solution:
- Check if review pending
- Re-request review if time passed
- Ask in chat if urgent
- Escalate if policy allows

Issue: Conflicting Opinions

Solution:
- Discuss in PR comments
- Tag tech lead if needed
- Document decision
- Move forward together

Issue: Large PR Hard to Review

Solution:
- Break into smaller PRs
- Update in batches
- Clarify scope better

Issue: Reviewer Offline

Solution:
- Wait for availability
- Ask another reviewer
- Escalate if urgent
- Rotate reviewers

Issue: PR Goes Stale

Solution:
- Rebase frequently
- Check for conflicts
- Respond to feedback
- Update status in PR

========================================
10. COLLABORATIVE WORKFLOW EXAMPLE
========================================

Scenario: Team building payment feature

Day 1 - Alice starts feature:
git checkout -b feature/payment-integration
(implements payment processing)
git add .
git commit -m "feat: add Stripe payment integration"
git push origin feature/payment-integration
(creates PR, requests review from Bob)

Day 1 - Bob reviews:
Reviews code on GitHub
Requests changes: "Add error handling for failed payments"
Marks for changes

Day 2 - Alice addresses feedback:
git checkout feature/payment-integration
(adds error handling)
git add .
git commit -m "Address review: add error handling for failed payments"
git push origin feature/payment-integration
(requests re-review)

Day 2 - Bob re-reviews:
Approves: "Looks good, well done!"

Day 2 - Carol reviews (2nd approval required):
Reviews code
Approves: "Great implementation"

Day 2 - Alice merges:
Clicks "Merge pull request" on GitHub
Selects "Squash and merge"
Deletes feature branch
PR is closed and merged to main

Day 3 - Deployment:
Code deployed to staging
Tests run on new code
Deployed to production

========================================
HANDS-ON PRACTICE SUMMARY
========================================

Topics Covered:
- Pull request creation and purpose
- PR description writing
- Code review process and responsibilities
- Reviewing on GitHub
- Addressing feedback
- Merge options and decisions
- Conflict resolution in PRs
- Branch naming conventions
- Commit message conventions
- Team collaboration practices
- GitHub features (labels, assignees, teams)
- Common collaboration issues
- Multi-reviewer workflows

Skills Practiced:
- Creating pull requests
- Writing clear descriptions
- Requesting reviews
- Making review feedback changes
- Merging pull requests
- Handling merge conflicts
- Team communication
- Code review best practices

========================================
NEXT STEPS: Day 5 - Git Best Practices and Branching
========================================
