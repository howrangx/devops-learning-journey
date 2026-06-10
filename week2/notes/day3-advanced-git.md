DAY 3: ADVANCED GIT WORKFLOWS
Command Reference and Learning Notes

LEARNING DATE: June 10, 2026
COMPLETED BY: Iman

========================================
1. GIT REBASING
========================================

What is Rebasing?
- Moves commits to a new base
- Rewrites commit history
- Creates linear history
- Alternative to merging

Rebase vs Merge:
Merge: Creates merge commit, preserves history
Rebase: Moves commits, cleaner history

When to Rebase:
- Local branches (before pushing)
- Private feature branches
- Before creating pull request
- Never on shared public branches

Basic Rebase:
git rebase main
Move current branch commits on top of main

Interactive Rebase:
git rebase -i HEAD~3
Edit, reorder, or squash last 3 commits

Rebase Options:
pick (p)      Keep commit
reword (r)    Change commit message
squash (s)    Combine with previous
fixup (f)     Combine, discard message
drop (d)      Remove commit
exec (x)      Run shell command

Undo Rebase:
git reflog
Find original HEAD reference

git reset --hard original_reference
Return to state before rebase

Example Workflow:
git checkout feature-branch
git rebase main
(resolve conflicts if any)
git push --force origin feature-branch

========================================
2. GIT CHERRY-PICK
========================================

What is Cherry-picking?
- Apply specific commit to current branch
- Copy commit without merging entire branch
- Useful for selective changes

When to Use:
- Apply specific bugfix to multiple branches
- Copy commits between branches
- Avoid merging unrelated changes

Basic Cherry-pick:
git cherry-pick commit_hash
Apply specific commit to current branch

Cherry-pick Multiple:
git cherry-pick commit1 commit2 commit3

Cherry-pick Range:
git cherry-pick commit1..commit5
Include commit1 to commit5 (not commit1 itself)

git cherry-pick commit1^..commit5
Include all from commit1 to commit5

Continue After Conflict:
(resolve conflicts)
git add .
git cherry-pick --continue

Abort Cherry-pick:
git cherry-pick --abort

Example Workflow:
git log main (find bugfix commit)
git checkout production-branch
git cherry-pick abc123def (bugfix commit hash)
git push origin production-branch

========================================
3. GIT STASHING
========================================

What is Stashing?
- Temporarily save changes
- Clean working directory
- Apply changes later
- Useful for switching branches

Stash Changes:
git stash
Save uncommitted changes

Stash with Message:
git stash save "WIP: feature name"

View Stashes:
git stash list

Show Stash Details:
git stash show
git stash show -p (show changes)

Apply Stash:
git stash apply
Apply latest stash, keep it

git stash apply stash@{n}
Apply specific stash

Pop Stash:
git stash pop
Apply and remove latest stash

Delete Stash:
git stash drop
Delete latest stash

git stash drop stash@{n}
Delete specific stash

Clear All Stashes:
git stash clear

Example Workflow:
(working on feature)
git stash
(switch to fix urgent bug)
(make fixes)
git commit -m "Fix urgent bug"
git checkout feature-branch
git stash pop
(continue feature work)

========================================
4. GIT TAGGING
========================================

What are Tags?
- Mark specific points in history
- Usually for releases
- Version identification
- Permanent markers

Lightweight Tag:
git tag v1.0.0
Create simple tag

Annotated Tag:
git tag -a v1.0.0 -m "Version 1.0.0"
Tag with message and metadata

List Tags:
git tag
git tag -l "v1.*" (pattern)

View Tag Details:
git show v1.0.0

Push Tags:
git push origin v1.0.0 (single tag)
git push origin --tags (all tags)

Delete Tag:
git tag -d v1.0.0 (local)
git push origin :v1.0.0 (remote)
git push origin --delete v1.0.0 (remote, newer syntax)

Tag Specific Commit:
git tag v1.0.0 abc123def

Semantic Versioning:
v1.0.0 = MAJOR.MINOR.PATCH
v1 = Major version (breaking changes)
0 = Minor version (new features)
0 = Patch version (bug fixes)

Example Workflow:
(finish release)
git tag -a v2.0.0 -m "Release version 2.0.0"
git push origin v2.0.0
(deploy v2.0.0)

========================================
5. MERGE CONFLICTS
========================================

What Causes Conflicts?
- Same file edited in different branches
- Different changes at same location
- Git cannot automatically merge

Detecting Conflicts:
git status
Shows conflicted files

Merge Conflict Markers:
<<<<<<< HEAD
Current branch changes
=======
Incoming branch changes
>>>>>>> branch-name

Resolving Conflicts:
1. Open conflicted file
2. Choose which changes to keep
3. Remove conflict markers
4. git add filename
5. git commit -m "Resolve merge conflict"

Example Conflict File:
function greet(name) {
<<<<<<< HEAD
  return "Hello, " + name + "!";
=======
  return "Hi " + name;
>>>>>>> feature-branch
}

Resolution Option 1 (keep HEAD):
function greet(name) {
  return "Hello, " + name + "!";
}

Resolution Option 2 (keep incoming):
function greet(name) {
  return "Hi " + name;
}

Resolution Option 3 (combine):
function greet(name) {
  return "Hello, " + name;
}

Merge Tools:
git mergetool
Use visual merge tool

Abort Merge:
git merge --abort
Cancel ongoing merge

Conflict Resolution Workflow:
git merge feature-branch
(conflicts occur)
(edit conflicted files)
git add .
git commit -m "Resolve merge conflicts"
git push origin main

========================================
6. GITIGNORE
========================================

What is .gitignore?
- File that tells Git what to ignore
- Prevents tracking unnecessary files
- Supports patterns and wildcards

Creating .gitignore:
cat > .gitignore << 'EOF'
# Ignore patterns go here
*.log
__pycache__/
.env
EOF

Common Patterns:
*.log              Ignore all .log files
__pycache__/       Ignore directories
.env               Ignore specific file
*.tmp              Ignore file type
node_modules/      Ignore node modules
dist/              Ignore build output
.DS_Store          Ignore system files
*.swp              Ignore vim swap files

Nested Patterns:
docs/*.txt         .txt files in docs folder
docs/**/*.txt      .txt files in docs and subdirs

Negation:
*.log              Ignore all logs
!important.log     Except this one

Comments:
# This is a comment

Check What Would Be Ignored:
git status --ignored

Remove Already Tracked Files:
git rm --cached filename
git commit -m "Stop tracking file"

Example .gitignore:
# Logs
*.log
logs/

# Environment
.env
.env.local

# IDE
.vscode/
.idea/

# Python
__pycache__/
*.pyc
venv/

# Node
node_modules/
npm-debug.log

# Build
dist/
build/

# System
.DS_Store
Thumbs.db

========================================
7. GIT WORKFLOWS
========================================

Git Flow Workflow
Main branches:
- main (production)
- develop (staging)

Supporting branches:
- feature/* (new features)
- release/* (prepare release)
- hotfix/* (urgent production fixes)

Feature Branch:
git checkout -b feature/new-feature develop
(work on feature)
git push origin feature/new-feature
(create pull request to develop)

Release Branch:
git checkout -b release/1.0.0 develop
(version bumps, bug fixes)
git push origin release/1.0.0
(create pull request to main and develop)

Hotfix Branch:
git checkout -b hotfix/1.0.1 main
(fix production bug)
git push origin hotfix/1.0.1
(create pull request to main and develop)

GitHub Flow Workflow
Simpler than Git Flow:
- main branch is production-ready
- Create feature branch from main
- Work and commit
- Create pull request
- Code review
- Merge to main
- Deploy

Steps:
git checkout -b feature-name
(make changes)
git add .
git commit -m "Implement feature"
git push origin feature-name
(create pull request on GitHub)
(review and merge)
git checkout main
git pull origin main

Trunk-Based Development
- Continuous small commits to main
- Features behind feature flags
- Frequent releases
- Minimal branching

Advantages:
- Simpler
- Fewer merge conflicts
- Continuous integration
- Fast feedback

========================================
8. GIT HOOKS (BASICS)
========================================

What are Git Hooks?
- Scripts that run at Git events
- Automate tasks
- Located in .git/hooks/

Common Hooks:
pre-commit (before commit)
post-commit (after commit)
pre-push (before push)
post-checkout (after branch switch)

Hook Names:
.git/hooks/pre-commit
.git/hooks/post-commit
.git/hooks/pre-push
.git/hooks/commit-msg

Creating Pre-commit Hook:
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
echo "Running pre-commit checks..."
exit 0
EOF

chmod +x .git/hooks/pre-commit

Hook Execution:
Script must be executable (chmod +x)
Script returns 0 for success, 1 for failure
If fails, Git operation is aborted

Example Pre-commit:
Check for debug code:
grep -r "console.log" . && exit 1

Example Pre-push:
Run tests before push:
npm test || exit 1

Tools for Hooks:
Husky (simplifies hook management)
pre-commit (Python-based)

========================================
9. COMMON ADVANCED WORKFLOWS
========================================

Workflow: Feature Development
git checkout -b feature/user-auth
(make changes)
git add .
git commit -m "feat: implement user authentication"
git push origin feature/user-auth
(create pull request)
(address review comments with new commits)
(merge when approved)

Workflow: Hotfix Production Bug
git checkout main
git pull origin main
git checkout -b hotfix/critical-bug
(fix bug)
git add .
git commit -m "fix: critical bug in payment"
git push origin hotfix/critical-bug
(create urgent pull request)
git checkout main
git merge hotfix/critical-bug
git tag -a v1.0.1 -m "Release v1.0.1"
git push origin main --tags

Workflow: Sync Fork with Upstream
git remote add upstream original-repo-url
git fetch upstream
git checkout main
git rebase upstream/main
git push origin main

Workflow: Squash Commits Before Merge
git rebase -i HEAD~5
(select squash for commits to combine)
git push --force origin feature-branch

========================================
10. HANDS-ON ADVANCED EXERCISES
========================================

Exercise 1: Create and Apply Stash
git checkout -b test-stash
echo "work in progress" > test.txt
git stash save "WIP: test feature"
git checkout main
git checkout test-stash
git stash pop

Exercise 2: Create Tags
git tag v1.0.0
git tag -a v1.1.0 -m "Version 1.1.0 release"
git tag -l
git show v1.1.0

Exercise 3: Rebase Branch
git checkout -b feature-test
echo "feature" > feature.txt
git add .
git commit -m "Add feature"
git checkout main
git rebase feature-test
git log --oneline

Exercise 4: Cherry-pick Commit
git log --oneline
(note commit hash)
git checkout -b test-cherry
git cherry-pick commit_hash

Exercise 5: Create .gitignore
echo "*.log" > .gitignore
echo ".env" >> .gitignore
git add .gitignore
git commit -m "Add gitignore"

========================================
HANDS-ON PRACTICE SUMMARY
========================================

Advanced Concepts Covered:
- Rebasing and interactive rebase
- Cherry-picking commits
- Stashing changes
- Tagging versions
- Merge conflict resolution
- Gitignore patterns
- Git workflow strategies
- Git hooks basics

Workflows Explained:
- Git Flow (complex projects)
- GitHub Flow (simple, effective)
- Trunk-Based Development (continuous delivery)

Skills Practiced:
- Advanced branch management
- Commit history manipulation
- Temporary work storage
- Version management
- Conflict resolution
- Workflow selection

========================================
NEXT STEPS: Day 4 - Collaboration and Pull Requests
========================================
