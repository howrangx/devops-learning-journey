DAY 3: ADVANCED GIT WORKFLOWS
Command Reference and Learning Notes

LEARNING DATE: June 4, 2026
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
