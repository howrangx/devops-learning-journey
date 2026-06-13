GIT TROUBLESHOOTING GUIDE
Solutions to common Git problems

========================================
1. AUTHENTICATION ISSUES
========================================

Problem: "Permission denied (publickey)"

Cause: SSH key not set up or not recognized

Solutions:

Check if SSH key exists:
ls -la ~/.ssh/

If not:
ssh-keygen -t rsa -b 4096 -C "your@email.com"

Add to GitHub:
1. Go to GitHub Settings > SSH and GPG keys
2. Click "New SSH key"
3. Copy your public key: cat ~/.ssh/id_rsa.pub
4. Paste into GitHub
5. Click "Add SSH key"

Test connection:
ssh -T git@github.com

Should see: "Hi username! You've successfully authenticated..."

If still fails:

Check SSH agent:
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa

Or use HTTPS instead of SSH:
git remote set-url origin https://github.com/user/repo.git
(requires personal access token as password)

========================================
2. CLONE AND PULL ISSUES
========================================

Problem: "fatal: could not read Username"

Cause: Git trying to use HTTPS without token

Solution:

Update remote to SSH:
git remote set-url origin git@github.com:user/repo.git

Or generate personal access token:
1. GitHub Settings > Developer settings > Personal access tokens
2. Create new token
3. Copy token
4. Use as password when prompted

Problem: "Repository not found"

Cause: Wrong repository URL or no access

Solution:

Check remote URL:
git remote -v

Correct URL format:
SSH: git@github.com:user/repo.git
HTTPS: https://github.com/user/repo.git

Verify you have access:
1. Check GitHub permissions
2. Check if user invited to team
3. Contact repository owner

Problem: "already exists" when cloning

Cause: Directory already exists

Solution:
rm -rf existing-directory
git clone url

Or clone to different directory:
git clone url directory-name

========================================
3. COMMIT ISSUES
========================================

Problem: "fatal: not a git repository"

Cause: Not in Git repository directory

Solution:
cd /path/to/repository

Or initialize:
git init
git remote add origin url
git pull origin main

Problem: "nothing to commit, working tree clean"

Cause: No changes made or all staged

Solution:
Check status:
git status

Make changes to files:
(edit files)

Stage changes:
git add .

Verify:
git status

Commit:
git commit -m "message"

Problem: Committed wrong file

Cause: Added file by mistake

Solution (before pushing):

Option 1: Amend last commit
git reset HEAD^ --soft
(select files to commit)
git add correct-files
git commit -m "message"

Option 2: Remove file from commit
git reset HEAD file-to-remove
git commit --amend

Option 3: Revert entire commit
git revert commit-hash

After pushing:
Contact Tech Lead (don't force push to main)

Problem: Committed sensitive data

Cause: Password or key in commit

Solution (URGENT):

1. Rotate the secret immediately
2. Contact Tech Lead
3. Remove from history (Tech Lead will do)
4. Never commit secrets again

Prevention:
Use .gitignore for:
.env
.env.local
*.key
*.pem

Use environment variables:
export API_KEY="xxx"
(don't commit)

========================================
4. PUSH AND PULL ISSUES
========================================

Problem: "updates were rejected"

Cause: Remote has newer commits

Solution:
git pull origin branch
(merge or rebase)

Fix conflicts if any:
(edit files)
git add .
git commit -m "Resolve merge conflicts"

Then push:
git push origin branch

Problem: "Permission to push denied"

Cause: Not allowed to push to this branch

Solution:
1. Check you have write access
2. Check branch protection rules
3. Use pull request instead

Problem: Accidentally pushed to wrong branch

Cause: Pushed to main instead of feature

Solution (only if not merged yet):

Revert on remote:
git push origin HEAD~1:branch-name
git push --force origin branch-name

Or contact Tech Lead.

Problem: Large file rejected

Cause: File too large for GitHub

Solution:
Use Git LFS:
git lfs install
git lfs track "*.large"
git add file.large
git commit -m "Add large file"
git push origin branch

========================================
5. BRANCH ISSUES
========================================

Problem: "fatal: pathspec 'branch' did not match"

Cause: Branch doesn't exist locally

Solution:
List local branches:
git branch

List all branches:
git branch -a

Fetch remote branches:
git fetch origin

Switch to remote branch:
git checkout branch-name
(Git auto creates local tracking branch)

Problem: Deleted branch by mistake

Cause: Used git branch -d

Solution (if recently deleted):
git reflog
(find deleted branch reference)
git checkout -b branch-name deleted-ref

Example:
git reflog
(shows: abc123 HEAD@{5}: branch: -c feature/old)
git checkout -b feature/old abc123

If not in reflog:
Cannot recover. Contact Tech Lead.

Problem: Renamed branch locally but remote still has old name

Cause: Branch renamed but not pushed

Solution:
Delete old remote branch:
git push origin --delete old-branch-name

Or rename:
git branch -m old-name new-name
git push -u origin new-name
git push origin --delete old-name

Problem: Too many local branches

Cause: Merged branches not deleted

Solution:
Delete local branches:
git branch -d feature/name

Delete multiple merged branches:
git branch -d $(git branch --merged)

Delete remote branches:
git push origin --delete branch-name

Clean up stale remote tracking branches:
git remote prune origin

========================================
6. MERGE AND REBASE ISSUES
========================================

Problem: "Merge conflict"

Cause: Same file edited in different branches

Solution:

View conflicted files:
git status

Open file and see:
<<<<<<< HEAD
Your changes
=======
Their changes
>>>>>>> branch-name

Choose which to keep:
(edit to desired state)
(remove conflict markers)

Stage and commit:
git add .
git commit -m "Resolve merge conflicts"

Continue:
git push origin branch

Problem: Rebase conflict

Cause: Same lines edited during rebase

Solution:
(resolve conflicts in files)
git add .
git rebase --continue

If multiple conflicts:
Repeat for each conflict

To abort:
git rebase --abort

To skip commit:
git rebase --skip

Problem: "fatal: cannot rebase: You have unstaged changes"

Cause: Uncommitted changes

Solution:
Commit changes:
git add .
git commit -m "WIP: work in progress"

Then rebase:
git rebase origin/main

Problem: Rebase went wrong

Cause: Confused state during rebase

Solution:
Abort:
git rebase --abort

Go back to before:
git reflog
(find previous state)
git reset --hard previous-ref

========================================
7. HISTORY AND LOG ISSUES
========================================

Problem: Can't find commit

Cause: Commit hash changed or unclear description

Solution:
Search by message:
git log --grep="search term"

Search by author:
git log --author="name"

Search by date:
git log --since="2 weeks ago"

Search by file:
git log -- filename

View all changes:
git log -p (show diffs)
git log --stat (show file changes)

View tree:
git log --graph --oneline --all

Problem: Commit history looks messy

Cause: Too many small commits

Solution (only on unpushed branches):

Squash commits:
git rebase -i HEAD~5
(select 'squash' for commits to combine)

Or reset and recommit:
git reset HEAD~5
(keeps changes, removes commits)
git add .
git commit -m "Clean commit message"

Problem: Want to understand commit details

Solution:
Show specific commit:
git show commit-hash

Show what changed:
git show commit-hash -- filename

Show commit stats:
git show commit-hash --stat

========================================
8. STASH ISSUES
========================================

Problem: "Need to switch branches but have uncommitted changes"

Cause: Dirty working directory

Solution:
Stash changes:
git stash

Switch branches:
git checkout other-branch

Come back:
git checkout original-branch

Restore changes:
git stash pop

Problem: Lost stashed changes

Cause: Stash cleared or lost

Solution:
View all stashes:
git stash list

View stash details:
git stash show -p stash@{n}

Apply old stash:
git stash apply stash@{n}

Recover lost stash:
git reflog
(find stash reference)
git stash apply ref

========================================
9. UNDO AND RECOVERY
========================================

Problem: "Need to undo last commit"

Cause: Committed wrong changes

Solution (before pushing):

Keep changes, undo commit:
git reset --soft HEAD~1

Discard changes, undo commit:
git reset --hard HEAD~1

Solution (after pushing):

Create reverse commit:
git revert commit-hash

Or contact Tech Lead (don't force push main).

Problem: "Accidentally deleted file"

Cause: Deleted but not committed

Solution:
Restore from staging:
git checkout -- filename

Or from last commit:
git checkout HEAD -- filename

Problem: "Want to go back to specific commit"

Cause: Need to undo multiple commits

Solution:
View history:
git log --oneline

Reset to commit:
git reset --soft commit-hash
(keep changes)

git reset --hard commit-hash
(discard changes)

Or revert commits:
git revert commit-hash~3..HEAD
(creates reverse commits for last 3)

========================================
10. SPECIAL SITUATIONS
========================================

Problem: "Accidentally committed to main"

Cause: Forgot to create branch

Solution:

Create branch from main:
git branch feature/name

Reset main to before commit:
git reset --hard HEAD~1

Push both:
git push -u origin feature/name
git push --force origin main

Contact Tech Lead about main protection rules.

Problem: "Two different local branches have same commit"

Cause: Branched from same point

Solution:
View branches:
git log --graph --oneline --all

Identify divergence point:
git merge-base branch1 branch2

This is normal. Proceed.

Problem: "Submodules not updating"

Cause: Submodule not initialized

Solution:
Initialize submodules:
git submodule update --init --recursive

Update submodules:
git submodule foreach git pull origin main

Add submodule:
git submodule add url path

Problem: "File mode changes show as changes"

Cause: File permissions changed

Solution:
Check change:
git diff filename

If legitimate permission change:
git add filename
git commit -m "Update file permissions"

If false positive:
git config core.fileMode false
(ignore permission changes)

========================================
11. ASKING FOR HELP
========================================

When Asking for Help, Include:

What you were trying to do:
"I was trying to merge feature branch to main"

What happened:
"Got merge conflict error"

Command you ran:
git merge feature/branch

Full error message:
<<<<<<< HEAD
conflict marker
=======
conflict marker
>>>>>>> feature/branch

What you've tried:
"I tried resolving manually but still getting error"

Exact state:
git status
git log --oneline -5

Getting Help

Slack: #git-help
Tech Lead: In person or Slack DM
Documentation: Check TEAM-GIT-STANDARDS.md

========================================
12. PREVENTION TIPS
========================================

Avoid Common Issues

1. Always pull before working
   git pull origin main

2. Commit frequently
   Multiple small commits, not one big commit

3. Push at end of day
   Don't hoard commits locally

4. Review before committing
   git diff before git add
   git diff --staged before git commit

5. Test before pushing
   npm test (or equivalent)

6. Use .gitignore
   Prevents committing secrets

7. Use meaningful names
   Descriptive branch names
   Clear commit messages

8. Communicate
   Tell team what you're working on
   Discuss big changes

9. Follow standards
   Use commit format
   Use branch naming
   Follow PR process

10. Keep learning
    Read Git documentation
    Ask questions
    Learn from mistakes

========================================
END OF TROUBLESHOOTING GUIDE
========================================
