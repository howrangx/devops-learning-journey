GIT WORKFLOW EXAMPLES
Practical scenarios and solutions

LEARNING DATE: June 10, 2026
COMPLETED BY: Iman

========================================
EXAMPLE 1: FEATURE DEVELOPMENT WORKFLOW
========================================

Scenario: Develop new user profile feature

Steps:
1. Create feature branch
   git checkout -b feature/user-profile

2. Make changes and commit
   echo "user profile code" > user_profile.py
   git add .
   git commit -m "feat: add user profile module"

3. Make more changes
   echo "profile validation" >> user_profile.py
   git add .
   git commit -m "feat: add profile validation"

4. Push to remote
   git push origin feature/user-profile

5. Create pull request on GitHub
   (GitHub interface)

6. Address review comments
   (make additional commits)
   git add .
   git commit -m "refactor: improve validation logic"
   git push origin feature/user-profile

7. Merge when approved
   (GitHub interface: click Merge)

8. Delete feature branch
   git checkout main
   git pull origin main
   git branch -d feature/user-profile

========================================
EXAMPLE 2: BUGFIX HOTFIX WORKFLOW
========================================

Scenario: Critical bug in production

Steps:
1. Pull latest main
   git checkout main
   git pull origin main

2. Create hotfix branch
   git checkout -b hotfix/payment-crash

3. Fix the bug
   (edit payment.js)
   git add .
   git commit -m "fix: prevent payment crash on invalid input"

4. Push and create PR
   git push origin hotfix/payment-crash
   (create pull request)

5. Merge to main
   (GitHub: click Merge)

6. Tag release
   git checkout main
   git pull
   git tag -a v1.2.3 -m "Emergency patch v1.2.3"
   git push origin v1.2.3

7. Deploy immediately
   (deployment process)

========================================
EXAMPLE 3: HANDLING MERGE CONFLICTS
========================================

Scenario: Feature branch conflicts with main

Steps:
1. Try to merge
   git checkout main
   git pull
   git merge feature/conflicting

2. Conflicts detected
   git status (shows conflicted files)

3. Open conflicted file and resolve
   (edit file, choose which changes to keep)

4. Stage resolved changes
   git add .

5. Complete merge
   git commit -m "Merge feature branch, resolve conflicts"

6. Push
   git push origin main

========================================
EXAMPLE 4: REBASING BEFORE MERGE
========================================

Scenario: Clean history before merging

Steps:
1. Fetch latest main
   git fetch origin main

2. Rebase feature branch
   git checkout feature/new-feature
   git rebase origin/main

3. Resolve conflicts if any
   (edit files)
   git add .
   git rebase --continue

4. Force push (only on private branch)
   git push --force origin feature/new-feature

5. Create clean pull request
   (GitHub: shows no conflicts)

========================================
EXAMPLE 5: CHERRY-PICKING SPECIFIC COMMITS
========================================

Scenario: Apply bugfix to multiple branches

Steps:
1. Find bugfix commit hash
   git log main --oneline
   (note: abc123def = bugfix commit)

2. Apply to release branch
   git checkout release-1.2
   git cherry-pick abc123def

3. Apply to develop branch
   git checkout develop
   git cherry-pick abc123def

4. Push changes
   git push origin release-1.2
   git push origin develop

========================================
EXAMPLE 6: STASHING WORK IN PROGRESS
========================================

Scenario: Need to switch branches without committing

Steps:
1. Stash current work
   git stash save "WIP: authentication module"

2. Switch to other branch
   git checkout main

3. Fix production issue
   (make commits)

4. Return to feature
   git checkout feature/auth

5. Restore stashed work
   git stash pop

6. Continue working
   (edit and commit)

========================================
EXAMPLE 7: INTERACTIVE REBASE TO CLEAN HISTORY
========================================

Scenario: Multiple small commits, want to combine

Steps:
1. Start interactive rebase
   git rebase -i HEAD~3 (last 3 commits)

2. Editor opens with:
   pick abc123 First commit
   pick def456 Second commit
   pick ghi789 Third commit

3. Change to squash (s) to combine:
   pick abc123 First commit
   s def456 Second commit
   s ghi789 Third commit

4. Save and close editor

5. Edit combined commit message
   (editor shows combined message)

6. Save final message

7. Force push (only private branch)
   git push --force origin feature-branch

========================================
EXAMPLE 8: VERSION MANAGEMENT WITH TAGS
========================================

Scenario: Release version 2.0.0

Steps:
1. Ensure main is ready
   git checkout main
   git pull origin main

2. Create annotated tag
   git tag -a v2.0.0 -m "Release version 2.0.0"

3. View tag
   git show v2.0.0

4. Push tag
   git push origin v2.0.0

5. Create release on GitHub
   (GitHub Releases section)

6. Deploy v2.0.0
   (deployment process with tag)

========================================
EXAMPLE 9: WORKING WITH UPSTREAM (CONTRIBUTING TO OTHERS' PROJECT)
========================================

Scenario: Contribute to open source project

Steps:
1. Fork project on GitHub
   (GitHub: click Fork)

2. Clone the fork
   git clone your-fork-url

3. Add upstream reference
   git remote add upstream original-project-url

4. Create feature branch
   git checkout -b feature/improvement

5. Make changes and commit
   (edit, add, commit)

6. Fetch latest upstream
   git fetch upstream
   git rebase upstream/main

7. Push to the fork
   git push origin feature/improvement

8. Create pull request
   (GitHub: compare across forks)

9. After merge, sync fork
   git fetch upstream
   git checkout main
   git rebase upstream/main
   git push origin main

========================================
EXAMPLE 10: CONTINUOUS INTEGRATION WORKFLOW
========================================

Scenario: Automated testing before merge

Steps:
1. Push feature branch
   git push origin feature/new-code

2. GitHub Actions run tests
   (automated on push)

3. Tests fail (example)
   (fix code)
   git add .
   git commit -m "fix: address test failures"
   git push origin feature/new-code

4. Tests pass
   (GitHub shows: All checks passed)

5. Create pull request
   (requires passing tests)

6. Code review
   (reviewer approves)

7. Merge pull request
   (GitHub: merge button enabled)

========================================
BEST PRACTICES FOR ALL WORKFLOWS
========================================

1. Always pull before pushing
   git pull origin branch_name

2. Create meaningful branch names
   feature/user-auth
   bugfix/payment-issue
   hotfix/critical-crash

3. Write clear commit messages
   "feat: add two-factor authentication"
   "fix: prevent null pointer exception"

4. Keep commits focused
   One feature or fix per commit

5. Rebase before merging
   Keep history clean

6. Use pull requests for review
   Never push directly to main

7. Delete branches after merge
   Keeps repo clean

8. Use tags for releases
   Track versions

9. Self-review the PR first
   Check for issues before others review

10. Keep branches short-lived
    Reduce merge conflicts

========================================
END OF GIT WORKFLOW EXAMPLES
========================================
