================================================
DAY 1: LINUX BASICS & COMMAND LINE MASTERY
Command Reference & Learning Notes
================================================

LEARNING DATE: May 29, 2026
COMPLETED BY: Iman

================================================
1. UNDERSTANDING LINUX FILESYSTEM
================================================

Key Directories:
- / (root)      = Base of entire filesystem
- ~ ($HOME)     = User's home directory
- .             = Current directory
- ..            = Parent directory

Filesystem Hierarchy:
- /bin          Essential command binaries
- /home         User home directories
- /etc          System configuration
- /var          Variable data (logs, caches)
- /tmp          Temporary files
- /usr          User programs and libraries
- /root         Root user's home
- /opt          Optional software

================================================
2. NAVIGATION COMMANDS
================================================

pwd             Print Working Directory
                Shows: /home/shimple/devops-learning/devops-learning-journey/week1

ls              List directory contents
ls -l           Long format with details
ls -la          Include hidden files (starting with .)
ls -lh          Human-readable file sizes

cd PATH         Change Directory
cd ~            Go to home directory
cd ..           Go to parent directory
cd -            Go to previous directory
cd /absolute/path   Absolute path (starts with /)
cd relative/path    Relative path (from current location)

================================================
3. FILE OPERATIONS
================================================

touch FILE              Create empty file
mkdir DIR               Create directory
mkdir -p DIR1/DIR2/DIR3 Create nested directories (with parents)

cat FILE                Display entire file content
cat -n FILE             Display with line numbers

echo "TEXT" > FILE      Write text to file (overwrite)
echo "TEXT" >> FILE     Append text to file

cp FILE COPY            Copy file
cp -r DIR COPY          Copy directory (recursive)

mv SOURCE DEST          Move or rename file/directory

rm FILE                 Delete file
rm -r DIR               Delete directory and contents
rm -i FILE              Interactive delete (asks for confirmation)

ls -R                   List directory recursively (show all subdirs)

================================================
4. PATH TYPES
================================================

Absolute Path:
- Starts with /
- Example: /home/shimple/week1
- Works from anywhere

Relative Path:
- Doesn't start with /
- From current location
- Examples:
  - file.txt (current dir)
  - ./file.txt (current dir, explicit)
  - ../file.txt (parent dir)
  - subdir/file.txt (subdirectory)

Home Directory:
- ~ = /home/username
- ~user = /home/user (other user's home)

================================================
5. HANDS-ON PRACTICE RESULTS
================================================

Created files:
- test-file.txt
- file1.txt, file2.txt, file3.txt

Created directories:
- practice/nested/deep (nested structure)

File operations tested:
- Create files with touch
- Add content with echo and >/>
- View content with cat
- Copy files and directories
- Move and rename files
- Delete files and directories

================================================
6. KEY TAKEAWAYS
================================================

1. Always confirm the current location: use pwd frequently
2. List before acting: use ls to see what is there
3. Use absolute paths when unsure
4. Back up before deleting: cp before rm
5. Use -i flag for safety: rm -i instead of rm
6. Hidden files start with .: Use ls -a to see them
7. Directories vs files: d prefix in ls -l means directory

================================================
7. TROUBLESHOOTING NOTES
================================================

Command not found?
- Check spelling
- Check if program is installed
- Use: which COMMAND

File not found?
- Use pwd to verify current directory
- Use ls to see available files
- Check spelling and case sensitivity

Permission denied?
- File might need chmod (future topic)
- Might need sudo for system files

================================================
NEXT STEPS: Day 2 - File Permissions & User Management
================================================
