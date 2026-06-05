DAY 2: GIT BASICS AND GITHUB
Command Reference and Learning Notes

LEARNING DATE: June 5, 2026
COMPLETED BY: Iman

========================================
1. WHAT IS GIT?
========================================

Git Overview:
- Distributed version control system
- Created by Linus Torvalds (2005)
- Tracks changes to files over time
- Allows collaboration
- Enables reverting to previous versions
- Records who made what changes and when

Why Use Git?
- Version history (track all changes)
- Collaboration (work with others)
- Branching (work on features in parallel)
- Merging (combine changes from branches)
- Remote repositories (backup and sharing)
- Code review (pull requests)
- Accountability (who changed what)

Git vs GitHub:
Git = Version control software (local or server)
GitHub = Cloud hosting service for Git repositories

========================================
2. GIT CONCEPTS
========================================

Repository
- Folder containing project files and Git history
- Contains .git directory with metadata
- Can be local or remote

Commit
- Snapshot of project at a point in time
- Contains changes, metadata, and hash
- Has unique identifier (SHA-1 hash)
- Includes author, date, and message

Branch
- Independent line of development
- Default branch: main (or master in older repos)
- Can create feature branches
- Branches can be merged

Working Directory
- Your local files on disk
- Changes you're currently making
- Where you edit files

Staging Area (Index)
- Intermediate area between working directory and repository
- Select which changes to commit
- Stage changes with: git add
- Review staged changes before committing

Remote
- Copy of repository on server
- Usually named: origin
- Can have multiple remotes
- Synchronized with git push and git pull

========================================
3. BASIC GIT WORKFLOW
========================================

Typical Workflow:
1. Modify files in working directory
2. Stage changes (git add)
3. Commit changes (git commit)
4. Push to remote (git push)

Visual Flow:
Working Directory -> Staging Area -> Repository -> Remote

Initialize Repository:
git init

Clone Existing:
git clone repository_url

Check Status:
git status

View Changes:
git diff

Stage Changes:
git add filename
git add .                    (all changes)
git add *.txt              (pattern)

Unstage Changes:
git reset filename
git reset .                (all staged)

Commit Changes:
git commit -m "message"
git commit -am "message"   (stage and commit tracked files)

Push to Remote:
git push origin main

Pull from Remote:
git pull origin main

View History:
git log
git log --oneline
git log --graph --oneline --all

========================================
4. GIT CONFIGURATION
========================================

User Configuration
Set user name:
git config --global user.name "Your Name"

Set user email:
git config --global user.email "your@example.com"

View configuration:
git config --global --list

Project-specific configuration:
git config user.name "Project Name"  (without --global)

Useful Settings:
git config --global core.editor nano
git config --global color.ui true
git config --global init.defaultBranch main

SSH Keys Setup:
Generate key:
ssh-keygen -t rsa -b 4096 -C "your@example.com"

Add to GitHub:
1. Copy public key (~/.ssh/id_rsa.pub)
2. Settings > SSH and GPG keys > New SSH key
3. Paste key

Test connection:
ssh -T git@github.com

========================================
5. BASIC COMMANDS
========================================

Initialize a new repository:
git init

Clone existing repository:
git clone https://github.com/user/repo.git
git clone git@github.com:user/repo.git

Check repository status:
git status

View uncommitted changes:
git diff

View staged changes:
git diff --staged

Add files to staging area:
git add filename
git add .                   (all files)
git add *.txt              (pattern)

Remove files from staging:
git reset filename
git reset                  (all staged)

Commit staged changes:
git commit -m "Commit message"

Commit with detailed message:
git commit

Amend last commit:
git commit --amend

View commit history:
git log
git log -n 5               (last 5 commits)
git log --oneline          (short format)
git log --graph --all      (visual branch graph)
git log --author="name"    (by author)
git log -- filename        (specific file)

Push commits to remote:
git push
git push origin main       (specific branch)
git push -u origin main    (track remote branch)

Pull changes from remote:
git pull
git pull origin main       (specific branch)

Fetch without merging:
git fetch

View remote information:
git remote
git remote -v              (verbose)
git remote show origin     (details)

========================================
6. BRANCHES
========================================

What is a Branch?
- Independent line of development
- Allows parallel work
- Can be merged back to main

View branches:
git branch                 (local)
git branch -a              (all, including remote)

Create new branch:
git branch feature-name

Switch to branch:
git checkout feature-name
git switch feature-name    (newer syntax)

Create and switch:
git checkout -b feature-name
git switch -c feature-name (newer)

Delete branch:
git branch -d feature-name (safe)
git branch -D feature-name (force)

Rename branch:
git branch -m old-name new-name

Merge branch to main:
git checkout main
git merge feature-name

View branch information:
git branch -v              (last commit on each)

========================================
7. GITHUB BASICS
========================================

Creating Repository on GitHub

Steps:
1. Go to github.com
2. Click + icon > New repository
3. Enter repository name
4. Add description (optional)
5. Choose public or private
6. Initialize with README (optional)
7. Add .gitignore (optional)
8. Add license (optional)
9. Click Create repository

Local to Remote:
git remote add origin https://github.com/user/repo.git
git branch -M main        (rename to main if needed)
git push -u origin main   (push and track)

Forking
- Copy entire repository to your account
- Create pull request to suggest changes
- Useful for contributing to others' projects

Cloning
- Download repository
- Have local copy to work with
git clone repository_url

========================================
8. COMMIT MESSAGES
========================================

Good Commit Messages:
- Clear and descriptive
- First line: summary (50 chars or less)
- Blank line
- Details (if needed)
- Reference issues if applicable

Examples:

Good:
"Add user authentication module

- Implement login functionality
- Add password hashing
- Create session management"

Bad:
"Fix stuff"
"Update code"
"Work in progress"

Conventional Commits:
type(scope): subject

feat: new feature
fix: bug fix
docs: documentation
style: code style
refactor: code refactoring
test: tests
chore: maintenance

Example:
"feat(auth): add two-factor authentication"

========================================
9. UNDOING CHANGES
========================================

Discard changes in working directory:
git checkout -- filename
git restore filename (newer)

Unstage file:
git reset filename
git restore --staged filename (newer)

Discard all changes:
git checkout -- .
git restore . (newer)

Revert last commit (keep changes):
git reset --soft HEAD~1
Changes staged, ready to commit

Revert last commit (discard changes):
git reset --hard HEAD~1
Warning: This deletes changes!

Revert specific commit (new commit):
git revert commit_hash
Creates new commit undoing changes

View what would be removed:
git clean -n

Remove untracked files:
git clean -fd

========================================
10. HANDS-ON GIT PRACTICE
========================================

Exercise 1: Initialize Repository
cd ~/devops-learning/devops-learning-journey
git init
git status

Exercise 2: Configure Git
git config user.name "Your Name"
git config user.email "your@example.com"

Exercise 3: Add Files
echo "test content" > test-file.txt
git add test-file.txt
git status

Exercise 4: Commit
git commit -m "Initial commit with test file"
git log --oneline

Exercise 5: Create Branch
git branch feature-test
git checkout feature-test
echo "feature content" > feature.txt
git add feature.txt
git commit -m "Add feature file"

Exercise 6: Switch Branches
git checkout main
git checkout feature-test
git checkout main

Exercise 7: View History
git log --oneline --graph --all

Exercise 8: Merge Branch
git merge feature-test
git log --oneline

Exercise 9: Check Remote
git remote -v

Exercise 10: Push to GitHub
git push -u origin main

========================================
11. GITHUB WORKFLOW BASICS
========================================

Typical GitHub Workflow:

1. Create repository on GitHub
2. Clone to local machine
3. Create feature branch
4. Make changes
5. Commit changes
6. Push branch
7. Create pull request on GitHub
8. Code review
9. Merge pull request
10. Delete branch

Pull Requests:
- Propose changes
- Request review
- Discussion before merging
- Automated tests can run
- Merge button when approved

Code Review:
- Others review code
- Suggest improvements
- Ask questions
- Approve or request changes

========================================
12. COMMON GIT WORKFLOWS
========================================

Feature Branch Workflow:
git checkout -b feature-name
(make changes)
git add .
git commit -m "Implement feature"
git push origin feature-name
(create pull request on GitHub)

Bugfix Workflow:
git checkout -b bugfix/issue-name
(fix bug)
git add .
git commit -m "Fix issue"
git push origin bugfix/issue-name
(create pull request)

Hotfix for Production:
git checkout -b hotfix/issue-name
git checkout main
git merge hotfix/issue-name
git tag -a v1.0.1 -m "Version 1.0.1"
git push origin main --tags

========================================
HANDS-ON PRACTICE SUMMARY
========================================

Topics Covered:
- Git initialization
- Configuration
- Basic workflow
- Staging and committing
- Branching and merging
- GitHub integration
- Commit messages
- Undoing changes
- Git history
- Remote operations

Skills Practiced:
- Creating repositories
- Staging and committing files
- Creating and switching branches
- Merging branches
- Viewing commit history
- Understanding Git workflow
- Preparing for GitHub
- Best practices for commits

========================================
NEXT STEPS: Day 3 - Advanced Git Workflows
========================================
