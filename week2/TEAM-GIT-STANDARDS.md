TEAM GIT STANDARDS AND WORKFLOW GUIDE
Professional Development Team Git Practices

DOCUMENT VERSION: 1.0
EFFECTIVE DATE: June 13, 2026
AUTHOR: Iman
REVIEWED BY: Development Team
APPROVAL STATUS: Approved

========================================
1. INTRODUCTION
========================================

Purpose
This document defines the Git workflow, branching strategy, and best practices
for our development team. It ensures consistency, quality, and efficiency
across all projects.

Scope
- All developers
- All repositories
- All projects
- Mandatory compliance

Exceptions
Only approved by Tech Lead with documentation.

Document Updates
Changes require team discussion and consensus.
Update version and effective date on approval.

========================================
2. BRANCHING STRATEGY
========================================

Selected Strategy: GitHub Flow

Rationale:
- Small to medium team (2-15 developers)
- Continuous deployment capability
- Rapid iteration required
- Automated testing in place
- Clear and simple workflow

Main Branches:
- main: Production-ready code, always deployable
- No other long-lived branches

Feature Branches:
- Created from main
- Named descriptively
- Deleted after merge
- Short-lived (hours to days, not weeks)

Branch Naming Convention

Format: type/description

Types:
feature/   New features
bugfix/    Bug fixes
hotfix/    Emergency production fixes
docs/      Documentation updates
refactor/  Code refactoring
test/      Test additions
chore/     Maintenance

Examples:
feature/user-authentication
feature/payment-integration
bugfix/login-validation-error
hotfix/critical-security-patch
docs/api-documentation
refactor/database-optimization
test/unit-tests-auth-module
chore/update-dependencies

Guidelines:
- Use lowercase letters
- Use hyphens (not underscores)
- Be descriptive but concise
- Include ticket number if available
- Maximum 50 characters preferred

Examples with tickets:
feature/ticket-123-user-auth
bugfix/ticket-456-payment-crash

========================================
3. COMMIT STANDARDS
========================================

Commit Message Format

Use Conventional Commits specification:

type(scope): subject

[optional body]

[optional footer]

Types:
feat:     New feature
fix:      Bug fix
docs:     Documentation
style:    Code style (no logic change)
refactor: Refactoring
test:     Tests
chore:    Maintenance
perf:     Performance improvement
ci:       CI/CD changes

Scope (Optional):
Specify affected component
Examples: auth, payment, api, database

Subject Line:
- Maximum 50 characters
- Imperative mood ("add" not "added")
- No period at end
- Clear and descriptive

Body (Optional):
- Separated by blank line
- Explain what and why
- Explain any non-obvious changes
- Reference issues/tickets

Footer (Optional):
- Reference related issues
- Reference PRs
- Note breaking changes

BREAKING CHANGE: if incompatible change

Examples:

Simple:
"feat(auth): add two-factor authentication"

With body:
"feat(payment): implement Stripe integration

- Add Stripe API client
- Implement payment processing
- Add webhook handling
- Add transaction logging

Fixes #123"

Detailed:
"fix(api): prevent race condition in checkout

Previously, concurrent checkout requests could create
multiple orders. This happened because we weren't locking
the inventory check.

Solution: Implement database transaction for inventory
check and order creation as atomic operation.

Fixes #456
Related to #457"

Commit Best Practices

1. Commit Frequently
   - Multiple commits per day
   - Logical units of work
   - Each should be self-contained

2. Keep Commits Focused
   - One feature/fix per commit
   - Related changes only
   - Don't mix concerns

3. Don't Commit Broken Code
   - All tests must pass
   - Code must be functional
   - Linter must pass

4. Review Before Committing
   - git diff before staging
   - git diff --staged before committing
   - Verify message quality

5. Push Regularly
   - Don't hoard commits locally
   - Push at end of day minimum
   - Sync with team regularly

========================================
4. PULL REQUEST PROCESS
========================================

Pull Request Workflow

Step 1: Prepare Branch
- Create feature branch from main
- Keep branch up to date: git rebase origin/main
- Make commits following standards
- Push to remote

Step 2: Create Pull Request
- Push branch to remote
- Click "New Pull Request" on GitHub
- Select main as base
- Write clear title and description
- Request reviewers
- Add labels and assignees

Step 3: Code Review
- Wait for reviews
- Address all feedback
- Respond to comments
- Request re-review when ready

Step 4: Merge
- Ensure all reviews approved
- Ensure CI/CD checks pass
- Ensure branch is up to date
- Click "Squash and merge" or "Merge"

Step 5: Deploy
- Automatic deployment if configured
- Verify in production
- Monitor for issues

Step 6: Cleanup
- Delete feature branch
- Close related issues

Pull Request Title

Format: Keep it concise
- Maximum 72 characters
- Describe change clearly
- Start with type (optional)

Examples:
"Add user authentication module"
"Fix payment processing crash"
"Update API documentation"
"feat: implement email notifications"

Pull Request Description

Include:
- What changes were made
- Why changes were made
- How changes work
- Any testing performed
- Screenshots/output if applicable
- Related issues or PRs

Template:
## Description
Brief description of changes

## Type of Change
- [ ] New feature
- [ ] Bug fix
- [ ] Breaking change
- [ ] Documentation update

## Related Issues
Fixes #123
Related to #456

## Testing Performed
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guide
- [ ] Self-reviewed code
- [ ] Comments added where needed
- [ ] Documentation updated
- [ ] Tests added/updated
- [ ] No console logs/debug code
- [ ] No hardcoded secrets

Code Review Guidelines

For Reviewers:
- Review within 24 hours
- Be constructive and kind
- Explain why, not just what
- Ask questions for clarity
- Acknowledge good work
- Approve when satisfied

For Authors:
- Respond to all comments
- Explain your decisions
- Make requested changes
- Push new commits to same branch
- Request re-review when ready
- Thank reviewers

Approval Rules
- Minimum 1 approval required
- All comments resolved
- All CI/CD checks pass
- Branch up to date with main

Merge Strategy
- Use "Squash and merge"
- Keeps history clean
- One commit per feature
- Simplifies reverting if needed

Merge Message Format:
Use PR title as commit message
Example: "Add user authentication module (#123)"

========================================
5. MAIN BRANCH PROTECTION
========================================

Branch Protection Rules

Settings > Branches > main

Rules Enforced:
- Require a pull request before merging
- Require code review approval (minimum 1)
- Dismiss stale pull request approvals
- Require status checks to pass
- Require branch to be up to date
- Require signed commits (recommended)
- Restrict who can push (optional)

Status Checks Required:
- All CI/CD tests must pass
- Code coverage minimum (if configured)
- Linter checks must pass
- Security scanning must pass

Access Control:
- Only allow main branch push by automation
- Require PRs for all changes
- No direct commits to main

Bypass Rules:
Only Tech Lead can bypass with:
- Documented reason
- Team notification
- Post-merge review

========================================
6. REPOSITORY STANDARDS
========================================

Required Files

README.md:
- Project description
- Setup instructions
- Usage examples
- Contributing guidelines
- License

.gitignore:
- OS files (.DS_Store, Thumbs.db)
- IDE settings (.vscode, .idea)
- Environment files (.env)
- Dependency directories (node_modules, venv)
- Build artifacts (dist, build)
- Logs (*.log)
- Secrets and keys

LICENSE:
- MIT, Apache 2.0, or other
- Specify project licensing terms

CONTRIBUTING.md:
- How to contribute
- Development setup
- Testing requirements
- Submission process
- Code of conduct

.github/pull_request_template.md:
- Standard PR template
- Reduces submission errors
- Ensures complete information

Repository Structure

Organize logically:

project/
  src/          Source code
  tests/        Test files
  docs/         Documentation
  scripts/      Utility scripts
  config/       Configuration
  .github/      GitHub templates
  README.md
  LICENSE
  CONTRIBUTING.md
  .gitignore

========================================
7. DEPLOYMENT AND RELEASES
========================================

Deployment Process

Step 1: Code Merged to main
- PR approved and merged
- CI/CD pipeline runs
- All tests pass
- Code review complete

Step 2: Automated Deployment
- Deploy to staging (automatic)
- Run smoke tests
- Verify functionality

Step 3: Production Deployment
- Manual approval (or automatic)
- Deploy to production
- Monitor logs
- Verify deployment

Step 4: Monitoring
- Monitor application metrics
- Watch for errors
- Check user reports
- Document any issues

Release Versioning

Use Semantic Versioning: vMAJOR.MINOR.PATCH

MAJOR: Breaking changes
MINOR: New features (backward compatible)
PATCH: Bug fixes

Examples:
v1.0.0  Initial release
v1.1.0  Add new feature
v1.1.1  Fix bug
v2.0.0  Breaking change

Tagging Release:
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0

Release Notes:
Include in GitHub Releases:
- Summary of changes
- New features
- Bug fixes
- Breaking changes
- Migration guide if needed

========================================
8. SECURITY AND SECRETS
========================================

No Secrets in Code

Never commit:
- API keys
- Passwords
- Database credentials
- Private keys
- Tokens
- Connection strings

Use Instead:
- Environment variables (.env files, not committed)
- Secrets management tools
- Configuration files (gitignored)
- CI/CD secrets
- AWS Secrets Manager
- HashiCorp Vault

.env File Example:
DATABASE_URL=postgresql://...
API_KEY=xxx
SECRET_TOKEN=yyy

Add to .gitignore:
.env
.env.local
.env.*.local

Pre-commit Hooks:
Use to prevent secret commits:
- Scan for common patterns
- Block on detection
- Educate developers

If Secret Committed:

1. Rotate the secret immediately
2. Remove from history:
   - BFG Repo Cleaner (recommended)
   - git-filter-branch (slower)
3. Force push (only if not yet pushed)
4. Notify team
5. Document incident

Branch Protection:
- Require signed commits
- Audit all commits
- Monitor access
- Review logs regularly

========================================
9. TEAM WORKFLOWS
========================================

Feature Development Workflow

Day 1 - Developer Alice:
git checkout -b feature/payment-system
(implement feature)
git add .
git commit -m "feat(payment): add Stripe integration"
git push origin feature/payment-system
(creates PR, requests review)

Day 1 - Reviewer Bob:
Reviews code on GitHub
Requests change: "Add error handling"

Day 2 - Developer Alice:
(addresses feedback)
git add .
git commit -m "Address review: add error handling"
git push origin feature/payment-system
(requests re-review)

Day 2 - Reviewer Bob & Carol:
Both approve
All CI/CD checks pass

Day 2 - Developer Alice:
Clicks "Merge pull request"
Selects "Squash and merge"
Deletes feature branch

Day 3 - Automatic:
Code automatically deployed to staging
Tests run
Code deployed to production

Hotfix Workflow (Emergency)

Dev notices production bug:
git checkout main
git pull origin main
git checkout -b hotfix/critical-bug
(fix bug, test thoroughly)
git add .
git commit -m "fix: critical bug causing data loss"
git push origin hotfix/critical-bug
(creates PR, requests urgent review)

Reviewer:
Immediate code review (minutes, not hours)
Approves if acceptable

Deploy:
Merge immediately
Deploy to production
Verify fix
Monitor

Code Review Process Workflow

Developer creates PR:
- Clear title and description
- Linked to issue
- Requests specific reviewers
- CI/CD checks running

Reviewer 1 (Bob):
- Reviews code
- Understands changes
- Tests locally
- Leaves comments
- Approves or requests changes

Reviewer 2 (Carol):
- Reviews code
- Verifies test coverage
- Checks security
- Approves or requests changes

Developer addresses feedback:
- Makes requested changes
- Pushes to same branch
- Responds to comments
- Requests re-review

Final merge:
- All approvals received
- All checks pass
- No conflicts
- Ready for deployment

========================================
10. CONFLICT RESOLUTION
========================================

Preventing Conflicts

Best Practices:
1. Keep branches short-lived (1-3 days max)
2. Rebase frequently: git rebase origin/main
3. Communicate with team
4. Review before starting work
5. Break features into smaller pieces

Detecting Conflicts

When merging:
Git shows: "This branch has conflicts"

Resolving via GitHub Web:
- Click "Resolve conflicts" button
- GitHub provides conflict editor
- Select desired changes
- Mark as resolved
- Commit resolution

Resolving Locally

git checkout feature-branch
git fetch origin
git rebase origin/main
(conflicts displayed)

Edit conflicted files:
<<<<<<< HEAD
Current changes
=======
Incoming changes
>>>>>>> main

Keep desired version:
(remove markers)

git add .
git rebase --continue

Understanding Conflicts

Causes:
- Same file edited in multiple branches
- Same lines modified differently
- Deletions vs modifications

Prevention:
- Communicate changes
- Small focused branches
- Regular rebasing
- Clear division of work

Testing After Conflict

After resolving:
1. Run all tests: npm test
2. Build application: npm build
3. Manual testing
4. Code review of resolution

Only push after verification.

========================================
11. TOOLS AND INTEGRATIONS
========================================

GitHub Integration

Enabled:
- Actions (CI/CD)
- Dependabot (dependency updates)
- Security alerts
- Code scanning
- Branch protection rules

Recommended:
- Semantic PR titles (required)
- Conventional commits (enforced)
- Status checks (required)
- Code review (required)

Local Tools

Required:
- Git (latest version)
- Text editor or IDE
- Terminal/command line

Recommended:
- GitKraken (GUI)
- GitHub CLI (command line)
- Pre-commit hooks
- Linters and formatters
- IDE Git integration

Optional:
- git-flow extensions
- Tower (Git GUI)
- SourceTree (Git GUI)

CI/CD Integration

GitHub Actions:
- Automated testing
- Linting
- Building
- Deployment

Runs on:
- Pull request creation
- Every push
- Scheduled times

Status displayed:
- In PR
- In commit history
- In branch view

========================================
12. TEAM POLICIES
========================================

Time Expectations

Code Review:
- Target: 24 hours
- Critical: 4 hours
- Urgent: 1 hour

Merge to Production:
- Tested: 48 hours after approval
- Hotfixes: 4 hours
- Documentation: 1 week

Branch Lifetime:
- Target: 3-5 days
- Maximum: 2 weeks
- Stale: 1 month (consider closing)

Responsibilities

All Developers:
- Follow commit standards
- Write clear PRs
- Review peers' code
- Address feedback promptly
- Keep code clean
- Document changes

Code Reviewers:
- Review within 24 hours
- Be constructive
- Test changes locally
- Verify tests pass
- Check for security issues
- Approve when satisfied

Tech Lead:
- Enforce standards
- Resolve conflicts
- Make final decisions
- Document policies
- Train team
- Emergency overrides (rarely)

========================================
13. QUICK REFERENCE
========================================

Common Commands

Creating and switching:
git checkout -b feature/name    (create branch)
git checkout main               (switch to main)
git switch feature/name         (modern syntax)

Committing:
git add .                       (stage changes)
git commit -m "message"         (commit)
git commit -am "message"        (stage tracked, commit)

Updating:
git fetch origin                (download changes)
git pull origin main            (fetch and merge)
git rebase origin/main          (rebase)

Pushing:
git push origin feature/name    (push to remote)
git push -u origin feature/name (push and track)

Checking:
git status                      (current status)
git log --oneline               (commit history)
git diff                        (uncommitted changes)

Reviewing PRs Locally:
git fetch origin pull/ID/head:pr-branch
git checkout pr-branch
git log origin/main..HEAD       (show commits)

========================================
14. CONTACT AND ESCALATION
========================================

Questions or Issues:
- Ask in team Slack
- Comment in PR
- Email Tech Lead
- Weekly team syncs

Breaking the Rules:
- Discuss with Tech Lead
- Document reason
- Get approval
- Report to team

Feedback:
This document is living
Suggest improvements anytime
We improve together

Last Updated: June 13, 2026
Next Review: September 10, 2026

========================================
END OF TEAM GIT STANDARDS
========================================
