TEAM GIT ONBOARDING GUIDE
Complete guide for new developers joining the team

========================================
1. WELCOME TO THE TEAM!
========================================

This guide helps you get started with our Git workflow and development process.

Time Required: 2-3 hours
Prerequisites: Git installed, GitHub account
Support: Ask in #engineering Slack channel

What You'll Learn:
- Our branching strategy
- How to create and review PRs
- Our commit conventions
- Common workflows
- Tools and setup

========================================
2. INITIAL SETUP (30 MINUTES)
========================================

Step 1: Clone the Repository

git clone https://github.com/your-org/your-repo.git
cd your-repo

Step 2: Configure Git (if not already done)

git config --global user.name "Your Name"
git config --global user.email "your.email@company.com"

Verify:
git config --global user.name
git config --global user.email

Step 3: Set Up Commit Message Template

Download template:
curl https://raw.githubusercontent.com/your-org/your-repo/.gitmessage -o ~/.gitmessage

Configure:
git config --global commit.template ~/.gitmessage

Step 4: Verify SSH Access

Test GitHub connection:
ssh -T git@github.com

Expected response:
Hi username! You've successfully authenticated...

If fails, set up SSH key:
ssh-keygen -t rsa -b 4096 -C "your.email@company.com"
(add public key to GitHub: Settings > SSH and GPG keys)

Step 5: Install Recommended Tools

Optional but recommended:
- GitKraken: Visual Git client
- GitHub CLI: Command line tool for GitHub
- Pre-commit hooks: Automated checks

Install GitHub CLI:
brew install gh (macOS)
choco install gh (Windows)
sudo apt install gh (Linux)

Step 6: Create Your First Branch

git checkout -b feature/onboarding-test
git log --oneline (verify you can see history)
git checkout main (switch back)

Success! You're ready to start.

========================================
3. QUICK START GUIDE (15 MINUTES)
========================================

Typical Day Workflow

Morning:
1. Pull latest changes
   git checkout main
   git pull origin main

2. Create feature branch
   git checkout -b feature/issue-name

Development:
3. Make changes
   (edit files)

4. Check what changed
   git status
   git diff

5. Stage and commit
   git add .
   git commit -m "feat(scope): description"

6. Push to remote
   git push -u origin feature/issue-name

Code Review:
7. Create PR on GitHub
   (go to repository, click "Pull requests" > "New pull request")

8. Describe your changes
   (fill in PR template)

9. Request reviewers
   (click "Reviewers", select team members)

Waiting for Review:
10. Address feedback
    (make commits to same branch)

11. Request re-review
    (comment "@reviewer please review")

Merging:
12. Merge when approved
    (click "Merge pull request" on GitHub)

13. Delete branch
    (click "Delete branch" or: git branch -d feature/name)

14. Celebrate!
    (your code is now in production)

========================================
4. KEY COMMANDS YOU'LL USE
========================================

Daily Commands

Status check:
git status                  (see what changed)

Create branch:
git checkout -b feature/name    (create + switch)

Switch branches:
git checkout main           (switch to main)
git switch feature/name     (modern syntax)

Commit changes:
git add .                   (stage all)
git commit -m "message"     (commit with message)

Push:
git push origin feature/name    (push to remote)
git push -u origin feature/name (first time, set tracking)

Pull:
git pull origin main        (fetch + merge latest)

View history:
git log --oneline           (see commits)
git log --graph --oneline --all (see branches)

Review before committing:
git diff                    (see changes)
git diff --staged           (see staged changes)

Undo changes:
git checkout -- file.txt    (discard changes)
git reset filename          (unstage file)

More Advanced

Update with main:
git fetch origin
git rebase origin/main

Interactive rebase:
git rebase -i HEAD~3        (combine last 3 commits)

Stash work:
git stash                   (save temporarily)
git stash pop               (restore)

See all commands:
git help                    (show help)
git command --help          (help for specific command)

========================================
5. UNDERSTANDING OUR WORKFLOW
========================================

Our Strategy: GitHub Flow

Why This Strategy:
- Simple and clear
- Works well for continuous deployment
- Fewer branches to manage
- Easy to understand

Main Principles:
1. main branch is always deployable
2. Create feature branch from main
3. Make changes and commit regularly
4. Push to remote
5. Create pull request
6. Code review
7. Merge when approved
8. Delete feature branch
9. Deploy

Visual Flow:

main branch (stable, in production)
   |
   +-- feature/user-auth (your work)
   |    |
   |    +-- commit 1
   |    +-- commit 2
   |    +-- commit 3
   |    |
   |    +-- PR created
   |    +-- review
   |    +-- feedback addressed
   |    |
   |    +-- MERGED
   |
   +-- (main now updated)

Branch Naming:
type/description

Examples:
feature/user-login
bugfix/payment-crash
hotfix/security-issue
docs/api-guide
refactor/database

Commit Messages:
feat(scope): description
fix(scope): description
docs(scope): description

Examples:
feat(auth): add password reset
fix(payment): handle timeout
docs(api): update endpoint docs

Pull Requests:
- Clear title
- Detailed description
- Link to issue
- Request reviewers
- Address all feedback
- Merge when approved

========================================
6. CREATING YOUR FIRST PR
========================================

Step-by-Step Guide

Step 1: Prepare
git checkout main
git pull origin main
git checkout -b feature/first-feature

Step 2: Make Changes
(edit files)
echo "Hello team" > hello.txt

Step 3: Commit
git add .
git commit -m "feat(onboarding): add hello file"

Step 4: Push
git push -u origin feature/first-feature

Step 5: Create PR on GitHub
1. Go to repository
2. Click "Pull requests" tab
3. Click "New pull request"
4. Select:
   - Base: main
   - Compare: feature/first-feature
5. Click "Create pull request"

Step 6: Fill PR Details
Title: "Add hello file to learn workflow"

Description:
This is my first PR! I added a hello.txt file
to learn the team's Git workflow.

Checklist:
- [ ] Code follows style guide
- [ ] Self-reviewed code
- [ ] Tests added (not needed for this one)
- [ ] No debug code

Step 7: Request Review
Click "Reviewers"
Select a team member

Step 8: Wait for Review
They'll review your code
They might ask questions or request changes

Step 9: Address Feedback (if any)
(make changes)
git add .
git commit -m "Address feedback: improve hello message"
git push origin feature/first-feature

Step 10: Merge
When approved, click "Merge pull request"
Choose "Squash and merge"
Click "Confirm squash and merge"

Step 11: Delete Branch
Click "Delete branch"

Congratulations! Your first PR merged!

========================================
7. CODE REVIEW EXPECTATIONS
========================================

Being Reviewed:

When someone reviews your code:
- They're helping you, not criticizing
- They want the code to be good
- They're sharing knowledge
- Take feedback constructively

Responding to Reviews:
1. Read all comments
2. Don't get defensive
3. Ask questions if unclear
4. Make changes if needed
5. Commit with clear message
6. Push to same branch
7. Request re-review
8. Thank them when done

Example Review Comment:
"This logic could be simpler using a switch statement.
Here's an example: ..."

Good Response:
"Good idea! I updated it to use switch statement
in the latest commit. Please review!"

Reviewing Others:

When asked to review:
1. Read PR description
2. Understand the change
3. Look at code
4. Test locally (optional but good)
5. Leave constructive comments
6. Approve or request changes
7. Be kind and helpful

How to Approve:
1. Click "Review changes"
2. Select "Approve"
3. Add summary (optional)
4. Click "Submit review"

========================================
8. COMMON SCENARIOS
========================================

Scenario 1: Making a Mistake in Commit

Problem: Committed with wrong message

Solution:
git commit --amend
(edit message)
git push --force-with-lease origin branch

Scenario 2: Forgot to Pull Before Working

Problem: Your changes conflict with main

Solution:
git fetch origin
git rebase origin/main
(resolve conflicts if any)
git push --force-with-lease origin branch

Scenario 3: Committed Sensitive Data

Problem: Accidentally committed a password

Solution:
1. Immediately rotate the password
2. Contact Tech Lead
3. They'll handle removing from history
4. Never do this again (use .env files)

Scenario 4: Branch Out of Sync with Main

Problem: Main updated, your branch is behind

Solution:
git fetch origin
git rebase origin/main
git push --force-with-lease origin branch

Scenario 5: Merge Conflict

Problem: PR shows "Can't automatically merge"

Solution:
Option A (via GitHub web interface):
1. Click "Resolve conflicts"
2. Edit conflicted sections
3. Mark as resolved
4. Commit resolution

Option B (via command line):
git fetch origin
git rebase origin/main
(resolve conflicts in editor)
git add .
git rebase --continue
git push --force-with-lease

========================================
9. TOOLS AND RESOURCES
========================================

Essential Tools

Git: Version control (already installed)
GitHub: Repository hosting
Text editor: VS Code, Sublime, etc

Recommended Tools

GitHub CLI: Command line for GitHub
  brew install gh

GitKraken: Visual Git client
  Download from gitkraken.com

Pre-commit hooks: Automated checks
  pip install pre-commit

Learning Resources

Our Documentation:
- TEAM-GIT-STANDARDS.md
- GIT-WORKFLOW-HELPERS.md
- REAL-WORLD-SCENARIO.md
- GIT-TROUBLESHOOTING.md

External Resources:
- GitHub Learning Lab: github.com/skills
- Git Documentation: git-scm.com/doc
- Conventional Commits: conventionalcommits.org
- GitHub Guides: guides.github.com

Video Tutorials:
- Git Basics (YouTube)
- GitHub Workflow (YouTube)

Getting Help:
1. Ask in #engineering Slack
2. Ask your assigned mentor
3. Check GIT-TROUBLESHOOTING.md
4. Search GitHub issues
5. Check team wiki/docs

========================================
10. YOUR FIRST WEEK CHECKLIST
========================================

Day 1 (Setup)
[ ] Clone repository
[ ] Configure Git with name/email
[ ] Set up SSH access
[ ] Verify GitHub access
[ ] Read TEAM-GIT-STANDARDS.md
[ ] Set up commit template
[ ] Install recommended tools

Day 2-3 (Learning)
[ ] Create first feature branch
[ ] Make a test commit
[ ] Push to remote
[ ] Create first PR
[ ] Ask for review
[ ] Address feedback
[ ] Merge PR
[ ] Celebrate!

Day 4-5 (Real Work)
[ ] Work on first assigned ticket
[ ] Follow team standards
[ ] Create proper PR
[ ] Request reviews
[ ] Participate in code reviews
[ ] Address feedback
[ ] Merge changes

By End of Week:
[ ] Comfortable with Git workflow
[ ] Created 3+ PRs
[ ] Reviewed peers' code
[ ] Merged to main
[ ] No major issues

========================================
11. DO's AND DON'Ts
========================================

DO:

DO commit often (multiple times per day)
DO write clear commit messages
DO create descriptive branch names
DO pull before starting work
DO ask questions (via Slack or PR comments)
DO test before pushing
DO review your own code first
DO be respectful in reviews
DO document complex changes
DO update PRs based on feedback

DON'T:

DON'T commit to main directly (use PRs)
DON'T push without testing
DON'T write vague commit messages
DON'T ignore PR reviews
DON'T force push to main
DON'T commit secrets/passwords
DON'T merge your own code without review
DON'T leave PR unresolved for weeks
DON'T be defensive about feedback
DON'T ignore linter errors

========================================
12. QUICK REFERENCE
========================================

Most Used Commands

Create and work:
git checkout -b feature/name
(work)
git add .
git commit -m "message"
git push -u origin feature/name

Update:
git pull origin main
git fetch origin
git rebase origin/main

Review and merge:
(review on GitHub)
(address feedback with new commits)
(merge on GitHub)
git checkout main
git pull origin main

Clean up:
git branch -d feature/name

Getting help:
git --help
git command --help
man git-command

========================================
13. CONTACT AND QUESTIONS
========================================

Questions?

Slack channels:
#engineering - general questions
#git-help - Git-specific issues
#onboarding - new developer help

People to ask:
- Your assigned mentor
- Tech Lead
- Any team member

Documentation:
- TEAM-GIT-STANDARDS.md
- GIT-TROUBLESHOOTING.md
- GitHub Guides

Welcome to the team!

========================================
END OF TEAM ONBOARDING GUIDE
========================================
