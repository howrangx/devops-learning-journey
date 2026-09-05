DAY 5: GIT BEST PRACTICES AND BRANCHING STRATEGIES
Command Reference and Learning Notes

LEARNING DATE: June 10, 2026
COMPLETED BY: Iman

========================================
1. GIT BEST PRACTICES
========================================

Commit Often, Push Regularly:
- Commit frequently (multiple times per day)
- Each commit should be logical unit
- Related changes together
- Independent changes separate

Example Good Commits:
Commit 1: "Add user login validation"
Commit 2: "Add user login error messages"
Commit 3: "Add user login tests"

Example Bad Commits:
Commit 1: "Fixed stuff"
Commit 2: "Work in progress"
Commit 3: "Final changes"

Write Meaningful Commit Messages:
- First line: summary (50 characters or less)
- Blank line
- Detailed explanation (optional)
- Reference issues if applicable

Format:
Type(scope): subject

Examples:
"feat(auth): add two-factor authentication"
"fix(payment): prevent race condition in checkout"
"docs(README): update installation instructions"
"refactor(api): simplify request handling"

Detailed Message Example:
"feat(notifications): add email notifications

- Implement email queue system
- Add notification templates
- Add user preference settings
- Configure SMTP credentials

Fixes #1234"

Use Branches Effectively:
- One feature per branch
- Descriptive names
- Short-lived (days, not weeks)
- Delete after merge

Never Push Directly to Main:
- Always use pull requests
- Requires code review
- Enables discussion
- Prevents accidents
- Maintains quality

Keep Repository Clean:
- Delete merged branches
- Remove temporary branches
- Clean up old tags
- Archive old branches if needed

Commands:
git branch -d merged-branch
git push origin --delete branch-name
git tag -d old-tag
git push origin --delete old-tag

Review Before Pushing:
- Check the changes: git diff
- Review staged changes: git diff --staged
- Check commit message
- Verify test results
- Run linter/formatter

Commands:
git diff
git diff --staged
git status
git log -p -n 1

Keep Branch Updated:
Before creating PR, sync with main:
git fetch origin
git rebase origin/main

Or before merging:
git checkout main
git pull origin main
git merge feature-branch

Avoid Force Pushes on Shared Branches:
Force push only on:
- Personal branches
- Private feature branches
- Never on main, develop, or shared branches

Commands to avoid on main:
git push --force
git push -f

Safe alternative:
git push --force-with-lease (safer, respects others' changes)

Use .gitignore:
- Prevent committing sensitive files
- Ignore build artifacts
- Ignore dependencies
- Ignore IDE settings

Common Patterns:
.env
*.log
node_modules/
__pycache__/
.DS_Store
.vscode/
dist/

Test Before Pushing:
- Run unit tests
- Run integration tests
- Run linter
- Manual testing

Never commit broken code.

Use Meaningful Tags:
- Tag releases
- Use semantic versioning
- Tag milestones
- Include release notes

Commands:
git tag -a v1.0.0 -m "Release 1.0.0"
git push origin v1.0.0

Synchronize Frequently:
git fetch origin (at least daily)
git pull origin main (for the current branch)

Prevents:
- Merge conflicts
- Wasted work
- Outdated code

Document Changes:
- Update README if needed
- Update CHANGELOG
- Update API docs
- Add comments for complex code

Keep Commits Atomic:
- Each commit self-contained
- Works independently
- Can be reverted without issues
- Passes tests

Don't Mix Concerns:
Bad: "Fix bug and refactor module"
Good: Two separate commits

Don't Rewrite Public History:
Once pushed to shared branch:
- Don't rebase
- Don't force push
- Use revert instead

Only safe if:
- Branch not shared
- Not merged to main
- Communicated with team

========================================
2. BRANCHING STRATEGIES
========================================

Git Flow Strategy

Overview:
- Complex projects
- Multiple environments
- Scheduled releases
- Large teams

Branches:
main (production)
develop (staging)
feature/* (features)
release/* (release prep)
hotfix/* (emergency fixes)

Feature Development:
git checkout -b feature/new-feature develop
(work)
git push origin feature/new-feature
(create PR to develop)
(merge when approved)

Release Process:
git checkout -b release/1.0.0 develop
(version bump, final fixes)
git push origin release/1.0.0
(create PR to main and develop)
(merge to both)
git tag -a v1.0.0 -m "Release 1.0.0"

Hotfix Process:
git checkout -b hotfix/critical-bug main
(fix bug)
git push origin hotfix/critical-bug
(create PR to main and develop)
(merge to both)

Advantages:
- Clear process
- Multiple environment support
- Scheduled releases

Disadvantages:
- Complex
- Many branches
- Overhead for small teams

GitHub Flow Strategy

Overview:
- Simple projects
- Continuous deployment
- Small to medium teams
- Regular releases

Branches:
main (production-ready)
feature branches (temporary)

Workflow:
git checkout -b feature-name
(work)
git push origin feature-name
(create PR)
(review and merge)
(deploy)

Rules:
- Anything in main is deployable
- Create descriptive feature branches
- PR before merging
- Delete branch after merge
- Deploy immediately after merge

Advantages:
- Simple
- Fast
- Continuous deployment
- Few branches

Disadvantages:
- Requires automated testing
- Requires deployment automation
- Not suitable for scheduled releases

Trunk-Based Development

Overview:
- Continuous delivery
- Multiple daily deployments
- Feature flags for incomplete features
- Minimal branching

Approach:
- Short-lived branches (hours or days)
- Multiple daily commits to main
- Features behind feature flags
- Continuous monitoring

Advantages:
- Simple process
- Fast feedback
- Fewer merge conflicts
- Continuous deployment

Disadvantages:
- Requires discipline
- Requires feature flags
- Requires robust testing
- Requires monitoring

Implementation:
git checkout -b feature-name
(work, commit frequently)
git push origin feature-name
(quick PR review)
(merge to main)
(feature enabled via flag in production)

========================================
3. BRANCH NAMING CONVENTIONS
========================================

Consistent Naming Scheme:

type/description

Types:
feature/   New features
bugfix/    Bug fixes
hotfix/    Emergency production fixes
docs/      Documentation changes
refactor/  Code refactoring
style/     Code style changes
test/      Test additions
chore/     Maintenance tasks

Examples:
feature/user-authentication
feature/payment-gateway
bugfix/login-error
hotfix/security-vulnerability
docs/api-documentation
refactor/database-queries
test/unit-tests-auth
chore/update-dependencies

Guidelines:
- Use lowercase
- Use hyphens (not underscores)
- Be descriptive
- Keep reasonably short
- Include issue number if available

Example with issue:
feature/issue-123-user-profile
bugfix/issue-456-payment-crash

Benefits:
- Easy to understand
- Consistent team standard
- Organized and searchable
- Self-documenting

========================================
4. TEAM STANDARDS AND CONVENTIONS
========================================

Commit Message Template:

Create .gitmessage file:

type(scope): subject

Body explaining what and why

Closes #issue-number

Use as template:
git config --global commit.template ~/.gitmessage

Conventional Commits Specification:
feat: new feature
fix: bug fix
docs: documentation
style: code style (no logic change)
refactor: code refactoring
test: adding tests
chore: maintenance
perf: performance improvement
ci: CI/CD changes

Code Review Checklist:

Code Quality:
- Follows style guide
- No code duplication
- Readable variable names
- Appropriate comments
- No dead code

Functionality:
- Solves stated problem
- No regressions
- Edge cases handled
- Error handling present

Testing:
- Unit tests included
- Tests pass
- Coverage adequate
- Integration tests updated

Documentation:
- README updated
- Inline comments added
- API docs updated
- Examples included

Security:
- No hardcoded secrets
- Input validation
- No SQL injection risk
- Authentication/authorization correct

Performance:
- No obvious performance issues
- Efficient algorithms
- Database queries optimized
- Large objects handled

PR Template for Repository:

Create .github/pull_request_template.md:

## Description
Brief description of changes

## Type of Change
- [ ] New feature
- [ ] Bug fix
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guide
- [ ] Self-reviewed code
- [ ] Comments added
- [ ] Documentation updated
- [ ] Tests added/updated

## Screenshots/Output
(if applicable)

GitHub Issue Template:

Create .github/ISSUE_TEMPLATE/bug_report.md:

## Description
Clear description of issue

## Steps to Reproduce
1. Step 1
2. Step 2
3. Step 3

## Expected Behavior
What should happen

## Actual Behavior
What actually happens

## Environment
- OS: 
- Version:
- Browser:

## Additional Context
Any other info

========================================
5. GITFLOW VS GITHUB FLOW COMPARISON
========================================

When to Use Git Flow:
- Large projects
- Multiple developers
- Production and staging environments
- Scheduled releases
- Complex deployment process

Examples:
- Enterprise applications
- Mobile apps with app store releases
- Projects with multiple version support

When to Use GitHub Flow:
- Smaller projects
- Continuous deployment
- Web applications
- Rapid iteration
- Automated testing

Examples:
- Startups
- SaaS applications
- Web services
- Open source projects

When to Use Trunk-Based:
- High-velocity teams
- Continuous delivery
- Automated testing and deployment
- Feature flags already in use

Examples:
- DevOps teams
- Cloud-native applications
- Microservices
- High-frequency deployment needs

Decision Matrix:

Git Flow:
- Team size: Large (10+)
- Release cycle: Scheduled (monthly, quarterly)
- Deployment: Manual or complex
- Environments: Multiple (dev, staging, prod)

GitHub Flow:
- Team size: Small to medium (2-15)
- Release cycle: Continuous (daily, weekly)
- Deployment: Automated
- Environments: Main or simple

Trunk-Based:
- Team size: Any
- Release cycle: Continuous (hourly, daily)
- Deployment: Fully automated
- Environments: Feature flags in production

========================================
6. COMMON MISTAKES AND HOW TO AVOID
========================================

Mistake 1: Forgetting to Pull Before Pushing

Problem:
- Outdated local changes
- Requires force push
- Loses others' work risk

Prevention:
git pull before git push
Always: git pull -> make changes -> git push

Better:
git fetch origin
git rebase origin/main

Mistake 2: Large Commits with Many Changes

Problem:
- Hard to review
- Hard to understand
- Hard to revert if needed

Prevention:
- Small focused commits
- One feature at a time
- Related changes together

Mistake 3: Poor Commit Messages

Problem:
- Unclear what changed
- Hard to find in history
- Bad for bisecting

Prevention:
- Use commit message template
- Follow conventions
- Be descriptive

Mistake 4: Not Keeping Branch Updated

Problem:
- Merge conflicts later
- Conflicts hard to resolve
- Other changes missed

Prevention:
- Rebase frequently
- Pull before PR
- Keep branches short-lived

Mistake 5: Committing Secrets

Problem:
- Security vulnerability
- Hard to remove (history)
- Requires key rotation

Prevention:
- Use .gitignore
- Use .env files
- Use secrets management
- Pre-commit hooks to check

Mistake 6: Force Pushing on Main

Problem:
- Rewrites history
- Breaks others' work
- Loses commits

Prevention:
- Never force push main
- Use --force-with-lease
- Protect main branch on GitHub

Mistake 7: Merge Conflicts Without Review

Problem:
- Wrong resolution
- Broken code
- Logic errors

Prevention:
- Test after resolving
- Have someone review
- Understand both sides

Mistake 8: Never Deleting Old Branches

Problem:
- Cluttered repository
- Confusing history
- Hard to find current branches

Prevention:
- Delete after merge
- Archive old branches
- Regular cleanup

Commands:
git branch -d merged-branch
git push origin --delete branch-name

Mistake 9: Committing Too Often to Main

Problem:
- Broken code in production
- Unclear history
- Testing issues

Prevention:
- Use feature branches
- Require PRs
- Require tests to pass
- Code review requirement

Mistake 10: Not Communicating Branch Work

Problem:
- Duplicate work
- Conflicting changes
- Wasted effort

Prevention:
- Create issue first
- Discuss in team
- Link PR to issue
- Update status in PR

========================================
7. PERFORMANCE AND OPTIMIZATION
========================================

Large Repository Management:

Shallow Clone (for large repos):
git clone --depth 1 repo-url
Clone recent history only

More efficient for:
- Large repositories
- Slow network
- CI/CD pipelines

Sparse Checkout:
git clone --sparse repo-url
Clone specific directories

Useful for:
- Monorepos
- Large codebases
- Selective checkout

Git LFS (Large File Storage):
Handle large binary files efficiently:
git lfs install
git lfs track "*.zip"
git add file.zip

For:
- Binary files
- Media files
- Large datasets

========================================
8. GIT SECURITY BEST PRACTICES
========================================

Protect Main Branch:

On GitHub:
Settings > Branches > Branch protection rules

Rules:
- Require pull request review
- Dismiss stale pull request approvals
- Require status checks to pass
- Require branches to be up to date
- Require signed commits
- Restrict who can push to main

Signed Commits:
Sign commits with GPG:
git config --global user.signingkey KEY_ID
git commit -S -m "message"

Or always sign:
git config --global commit.gpgsign true

Secrets Management:
Use environment variables:
export API_KEY="xxx"
python app.py

Or use secrets tools:
- AWS Secrets Manager
- HashiCorp Vault
- Azure Key Vault

Never commit:
- API keys
- Passwords
- Credentials
- Private keys

Monitor Commits:
- Review who has access
- Audit commit history
- Monitor branch changes
- Check for unsigned commits

Remove Secret from History:
BFG Repo Cleaner:
bfg --delete-files *.key

Or git-filter-branch (slower):
git filter-branch --tree-filter 'rm -f .env'

========================================
9. PRACTICAL WORKFLOW CHECKLIST
========================================

Before Creating PR:
[ ] Fetched latest main
[ ] Rebased on main
[ ] Tested code locally
[ ] Ran linter/formatter
[ ] Updated tests
[ ] Updated documentation
[ ] Committed with meaningful messages
[ ] Reviewed own changes
[ ] No secrets in code

Creating PR:
[ ] Clear title
[ ] Detailed description
[ ] Referenced related issue
[ ] Specified reviewers
[ ] Added labels
[ ] Assigned to self

During Review:
[ ] Responded to all comments
[ ] Made requested changes
[ ] Requested re-review
[ ] Verified CI/CD passed
[ ] Resolved conflicts

Before Merge:
[ ] All reviews approved
[ ] All checks passed
[ ] Branch up to date
[ ] Conflicts resolved
[ ] Tests passing
[ ] Ready for production

After Merge:
[ ] Deleted feature branch
[ ] Monitored deployment
[ ] Verified changes in production
[ ] Closed related issue

========================================
10. CONTINUOUS IMPROVEMENT
========================================

Learn from History:
git log --oneline --graph --all
Understand project history

Improve Workflow:
- Analyze merge patterns
- Look for conflicts
- Find slow reviews
- Identify bottlenecks

Team Retrospective:
Discuss:
- What worked well
- What could improve
- Process changes
- Tool changes

Metrics to Track:
- PR review time
- Time to merge
- Number of conflicts
- CI/CD pass rate
- Deployment frequency

Tools:
- GitHub Insights
- GitKraken
- Gitkraken CLI
- Custom dashboards

========================================
HANDS-ON PRACTICE SUMMARY
========================================

Topics Covered:
- Commit frequency and messages
- Branch creation and naming
- Pull request best practices
- Code review standards
- Team conventions
- Branching strategies
- Security practices
- Common mistakes
- Performance optimization

Strategies Learned:
- Git Flow (complex projects)
- GitHub Flow (simple, continuous)
- Trunk-Based Development (high-velocity)

Decision Framework:
- When to use each strategy
- Team size considerations
- Release cycle requirements
- Deployment complexity

Best Practices:
- Commit messages
- Branch naming
- Code review process
- Team standards
- Security guidelines
- Performance optimization

========================================
NEXT STEPS: Weekend Project - Advanced Git Collaboration Project
========================================
