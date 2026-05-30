DAY 2: FILE PERMISSIONS AND USER MANAGEMENT
Command Reference and Learning Notes

LEARNING DATE: May 30, 2026
COMPLETED BY: Iman

========================================
1. PERMISSION BASICS
========================================

Permission Model: rwxrwxrwx
Read (r)    = Can view file or list directory
Write (w)   = Can modify file or create/delete in directory
Execute (x) = Can run file or enter directory

Position meanings:
- Positions 1-3: Owner permissions
- Positions 4-6: Group permissions
- Positions 7-9: Others permissions

File type indicator:
- = regular file
d = directory
l = symbolic link

========================================
2. NUMERIC PERMISSION SYSTEM
========================================

Calculation:
r (read)    = 4
w (write)   = 2
x (execute) = 1

Sum these values for each group:
7 = 4+2+1 = read + write + execute
6 = 4+2   = read + write
5 = 4+1   = read + execute
4 = 4     = read only
3 = 2+1   = write + execute
2 = 2     = write only
1 = 1     = execute only
0 = 0     = no permissions

Three-digit format: owner-group-others

========================================
3. COMMON PERMISSION PATTERNS
========================================

755 = rwxr-xr-x
Used for: Executable scripts and directories
Meaning: Owner full access, others can read and execute

644 = rw-r--r--
Used for: Regular data files
Meaning: Owner can read/write, others can read only

600 = rw-------
Used for: Private files
Meaning: Only owner can read and write

700 = rwx------
Used for: Private directories
Meaning: Only owner can access

777 = rwxrwxrwx
Used for: Rarely, when everyone needs full access
Meaning: Security risk, avoid unless necessary

400 = r--------
Used for: Read-only sensitive files
Meaning: Only owner can read

500 = r-x------
Used for: Execute-only files
Meaning: Owner can read and execute only

========================================
4. CHMOD COMMAND
========================================

Numeric method:
chmod 755 filename
chmod 644 filename
chmod 600 filename

Symbolic method:
u = user (owner)
g = group
o = others
a = all

+ = add permission
- = remove permission
= = set exactly

chmod u+x filename          Add execute for owner
chmod g-w filename          Remove write from group
chmod o-r filename          Remove read from others
chmod a+r filename          Add read for all
chmod u=rwx,g=rx,o= filename  Set specific permissions

========================================
5. FILE OWNERSHIP (chown)
========================================

View ownership:
ls -l filename

Change owner (requires sudo):
sudo chown newowner filename

Change owner and group:
sudo chown owner:group filename

Change only group:
sudo chown :group filename

Change recursively (directories):
sudo chown -R owner:group directory

========================================
6. USERS AND GROUPS
========================================

Current user:
whoami

User information:
id
groups

All users on system:
cat /etc/passwd

All groups:
cat /etc/group

Users logged in:
who

File format /etc/passwd:
username:password:UID:GID:name:home:shell

========================================
7. HANDS-ON PRACTICE SCENARIOS
========================================

Scenario 1: Secure Config File
Create: app-config.conf
Set: chmod 600 app-config.conf
Result: Only owner can read (no group/others access)
Use case: Database passwords, API keys

Scenario 2: Executable Script
Create: deploy.sh
Set: chmod 755 deploy.sh
Result: Owner can run, group/others can read and execute
Use case: Deployment scripts, system utilities

Scenario 3: Read-Only Log
Create: application.log
Set: chmod 444 application.log
Result: Everyone can read, no one can modify
Use case: Log files, audit trails, archives

========================================
8. SYMBOLIC CHMOD EXAMPLES
========================================

chmod u+x file              Owner: add execute
chmod g-w file              Group: remove write
chmod o-rwx file            Others: remove all
chmod a+r file              All: add read
chmod u=rwx,g=rx,o= file    Owner: rwx, Group: rx, Others: none
chmod 755 file              Equivalent: rwxr-xr-x

========================================
9. PRACTICAL EXAMPLES FROM DAY 2
========================================

Test files created:
- test-file.txt (regular file)
- script-file.sh (executable script)
- config-file.conf (configuration)
- data-file.log (log file)
- app-config.conf (sensitive config)
- deploy.sh (deployment script)
- application.log (read-only log)

Permission changes tested:
- Changed file to 755 (executable)
- Changed file to 400 (read-only)
- Changed file to 644 (standard)
- Changed file to 600 (private)
- Changed file to 444 (read-only for all)
- Used symbolic chmod (u+x, go-w, a+r)

========================================
10. SECURITY BEST PRACTICES
========================================

Private files (passwords, keys):
chmod 600 filename
Only owner can read and write

Shared scripts:
chmod 755 filename
Owner can modify, others can run

Data files:
chmod 644 filename
Owner can edit, others can read

Read-only files:
chmod 444 filename
No one can modify

Never use 777 unless absolutely necessary

========================================
NEXT STEPS: Day 3 - Text Processing and Searching
========================================
