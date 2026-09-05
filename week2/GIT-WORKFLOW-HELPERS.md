GIT WORKFLOW HELPERS AND AUTOMATION
Practical scripts and tools for team efficiency

========================================
1. WORKFLOW HELPER SCRIPTS
========================================

These scripts automate common Git workflows and save time.

Script 1: Start Feature Branch

Purpose: Create and set up feature branch correctly

Script: start-feature.sh

#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: ./start-feature.sh <feature-name>"
    echo "Example: ./start-feature.sh user-authentication"
    exit 1
fi

FEATURE_NAME=$1

echo "Starting feature: $FEATURE_NAME"

# Ensure main is up to date
git checkout main
git pull origin main

# Create feature branch
git checkout -b feature/$FEATURE_NAME

echo "Feature branch created: feature/$FEATURE_NAME"
echo "Ready to start development!"

Usage:
./start-feature.sh user-authentication

Script 2: Push and Create PR

Purpose: Push branch and open PR on GitHub

Script: push-and-pr.sh

#!/bin/bash

BRANCH=$(git rev-parse --abbrev-ref HEAD)

if [ "$BRANCH" == "main" ]; then
    echo "Error: Cannot create PR from main branch"
    exit 1
fi

# Push branch
echo "Pushing branch: $BRANCH"
git push -u origin $BRANCH

echo ""
echo "Create PR at:"
echo "https://github.com/YOUR_REPO/pull/new/$BRANCH"

Usage:
./push-and-pr.sh

Script 3: Rebase and Clean

Purpose: Update branch and squash commits

Script: rebase-clean.sh

#!/bin/bash

echo "Fetching latest main..."
git fetch origin

echo "Rebasing on main..."
git rebase origin/main

if [ $? -eq 0 ]; then
    echo "Rebase successful!"
    echo "Ready to push with: git push --force-with-lease"
else
    echo "Rebase failed. Resolve conflicts and continue with:"
    echo "git rebase --continue"
fi

Usage:
./rebase-clean.sh

Script 4: Sync Fork with Upstream

Purpose: Update forked repository with upstream changes

Script: sync-fork.sh

#!/bin/bash

echo "Adding upstream remote..."
git remote add upstream original-repo-url

echo "Fetching upstream..."
git fetch upstream

echo "Checking out main..."
git checkout main

echo "Rebasing on upstream/main..."
git rebase upstream/main

echo "Pushing to your fork..."
git push origin main

Usage:
./sync-fork.sh

Script 5: Clean Local Branches

Purpose: Delete merged branches locally

Script: clean-branches.sh

#!/bin/bash

echo "Fetching remote..."
git fetch origin

echo "Deleting local merged branches..."
git branch -d $(git branch --merged | grep -v '\*\|main\|develop')

echo "Deleting stale branches..."
git remote prune origin

echo "Cleanup complete!"

Usage:
./clean-branches.sh

========================================
2. GIT ALIASES FOR EFFICIENCY
========================================

Add to .gitconfig or run commands:

git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
git config --global alias.visual 'log --graph --oneline --all'
git config --global alias.amend 'commit --amend --no-edit'
git config --global alias.fixup 'commit --fixup'
git config --global alias.squash 'commit --squash'

Usage:
git co feature/branch     (instead of git checkout)
git st                    (instead of git status)
git visual                (instead of git log --graph --oneline --all)
git amend                 (amend last commit without changing message)

========================================
3. PRE-COMMIT HOOKS
========================================

Prevent common mistakes before committing.

Purpose:
- Check for secrets
- Verify code format
- Run linters
- Check file sizes
- Block debug code

Create file: .git/hooks/pre-commit

#!/bin/bash

echo "Running pre-commit checks..."

# Check for debug code
if grep -r "console.log\|debugger\|print(" --include="*.js" --include="*.py" .; then
    echo "Error: Debug code found. Please remove before committing."
    exit 1
fi

# Check for secrets
if grep -r "password\|secret\|API_KEY" --include="*.env" .; then
    echo "Error: Potential secrets found in committed files."
    exit 1
fi

# Check file sizes
for file in $(git diff --cached --name-only); do
    size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
    if [ $size -gt 10485760 ]; then
        echo "Error: File $file is too large (>10MB)"
        exit 1
    fi
done

echo "Pre-commit checks passed!"
exit 0

Make executable:
chmod +x .git/hooks/pre-commit

========================================
4. COMMIT MESSAGE HELPER
========================================

Interactive guide for writing commit messages.

Script: commit-template.txt

Create file: ~/.gitmessage

type(scope): subject

# <type> can be
#   feat     (new feature)
#   fix      (bug fix)
#   refactor (code change that neither fixes a bug nor adds feature)
#   style    (changes that don't affect code meaning)
#   test     (adding missing tests, refactoring tests)
#   docs     (documentation only changes)
#   chore    (other changes that don't modify src or test files)
#
# <scope> is optional; specify the section of the codebase affected
#
# <subject> uses imperative, present tense: "change" not "changed"/"changes"
# don't capitalize first letter, no period (.) at end
# limit to 50 characters
#
# <body> optional; explain what and why, not how
# wrap at 72 characters
# separate from subject by blank line
#
# <footer> optional; note breaking changes, deprecations, tickets
#
# Example:
#
# feat(auth): add two-factor authentication
#
# Users can now enable two-factor authentication for enhanced security.
# This requires SMS or authenticator app verification on login.
#
# Fixes #123
# Closes #456

Configure Git to use template:
git config --global commit.template ~/.gitmessage

========================================
5. BRANCH ANALYSIS TOOLS
========================================

Understand the repository structure.

Show Branches with Last Commit:
git branch -vv

Show Branches Sorted by Commit Date:
git branch -v --sort=committerdate

Find Stale Branches (older than 30 days):
git branch -v | awk '$3 ~ /[0-9]+ months ago/ || $3 ~ /[0-9]+ years ago/'

Count Commits Per Developer:
git log --oneline --pretty=format:%an | sort | uniq -c | sort -rn

Show Large Files:
git rev-list --all --objects | sort -k2 | tail -10

Show Commit Activity:
git log --pretty=format:"%h %an %ad %s" --date=short

========================================
6. WORKFLOW AUTOMATION WITH GITHUB ACTIONS
========================================

Automate testing and deployment.

Create: .github/workflows/test.yml

name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run tests
        run: npm test
      - name: Run linter
        run: npm run lint

Create: .github/workflows/deploy.yml

name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Deploy to production
        run: ./deploy.sh

========================================
7. COMMON WORKFLOW PATTERNS
========================================

Pattern 1: Feature Development
git checkout -b feature/name
(make changes)
git add .
git commit -m "feat: description"
git push -u origin feature/name
(create PR, get reviews, merge)

Pattern 2: Hotfix
git checkout main && git pull
git checkout -b hotfix/name
(fix issue)
git commit -m "fix: critical issue"
git push origin hotfix/name
(urgent PR, merge, tag, deploy)

Pattern 3: Sync with Main
git fetch origin
git rebase origin/main
(resolve conflicts if needed)
git push --force-with-lease

Pattern 4: Clean Commits
git rebase -i HEAD~5
(squash or reword as needed)
git push --force-with-lease

Pattern 5: Amend Last Commit
git add .
git commit --amend --no-edit
git push --force-with-lease

========================================
8. DOCUMENTATION TEMPLATE
========================================

For documenting Git workflows:

## Workflow Name

### Purpose
Why this workflow exists.

### When to Use
When should developers use this.

### Prerequisites
What's needed before starting.

### Steps
1. Step 1
   Command: git command

2. Step 2
   Command: git command

### Troubleshooting
- Issue 1: Solution
- Issue 2: Solution

### Related Workflows
Link to related workflows.

========================================
END OF WORKFLOW HELPERS
========================================
