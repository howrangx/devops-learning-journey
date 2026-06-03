DAY 5: BASH SCRIPTING FUNDAMENTALS
Command Reference and Learning Notes

LEARNING DATE: June 3, 2026
COMPLETED BY: Iman

========================================
1. SCRIPT STRUCTURE
========================================

Shebang line:
#!/bin/bash
Must be first line, tells system to use bash

Comments:
# This is a comment
Comments start with # and continue to end of line

Basic structure:
#!/bin/bash
# Script description
# Author: Name
# Date: Date

# Commands here

Script execution:
chmod 755 script.sh
./script.sh
bash script.sh

========================================
2. VARIABLES
========================================

Variable assignment (no spaces):
NAME="value"
AGE=25
VERSION=1.0

Using variables:
echo $NAME
echo $AGE
echo ${VERSION}  (preferred for clarity)

Variable naming:
- Start with letter or underscore
- Contain letters, numbers, underscores
- Case sensitive (MY_VAR != my_var)

User input:
read VARIABLE
read -p "Prompt: " VARIABLE

Command substitution:
VAR=$(command)
VAR=`command`  (older syntax)

Example:
CURRENT_DATE=$(date)
HOSTNAME=$(hostname)

Arithmetic:
SUM=$((NUM1 + NUM2))
PRODUCT=$((A * B))
DIFF=$((X - Y))
DIV=$((NUM1 / NUM2))

String operations:
${#STRING}      Length of string
${STRING:0:5}   Substring (start at 0, length 5)
${STRING:5}     From position 5 to end

Local variables in functions:
local VAR="value"

========================================
3. CONDITIONAL STATEMENTS
========================================

If/else:
if [ condition ]; then
    commands
else
    commands
fi

If/elif/else:
if [ condition1 ]; then
    commands
elif [ condition2 ]; then
    commands
else
    commands
fi

File tests:
-f FILE         File exists
-d DIR          Directory exists
-e PATH         Path exists (file or directory)
-r FILE         Readable
-w FILE         Writable
-x FILE         Executable
-s FILE         File size > 0
-z STRING       String is empty
-n STRING       String is not empty

Numeric comparisons:
-eq             Equal
-ne             Not equal
-lt             Less than
-le             Less than or equal
-gt             Greater than
-ge             Greater than or equal

String comparisons:
=               Equal
!=              Not equal
<               Less than (ASCII)
>               Greater than (ASCII)

Logic operators:
&&              AND
||              OR
!               NOT

Example:
if [ -f "file.txt" ] && [ -x "file.txt" ]; then
    echo "File exists and is executable"
fi

========================================
4. CASE STATEMENTS
========================================

Case/esac:
case $VARIABLE in
    option1)
        commands
        ;;
    option2)
        commands
        ;;
    *)
        default commands
        ;;
esac

Patterns:
dev)            Exact match
[dD]ev)         Character range
dev|development) OR pattern
*)              Default case

Example:
case $ENV in
    dev)
        echo "Development"
        ;;
    prod)
        echo "Production"
        ;;
    *)
        echo "Unknown"
        ;;
esac

========================================
5. FOR LOOPS
========================================

For loop with list:
for item in item1 item2 item3
do
    echo $item
done

For loop with range:
for i in {1..10}
do
    echo $i
done

C-style for loop:
for ((i = 1; i <= 10; i++))
do
    echo $i
done

Loop through files:
for file in *.txt
do
    echo $file
done

Loop through command output:
for user in $(cat /etc/passwd | cut -d: -f1)
do
    echo $user
done

Break and continue:
for i in {1..10}
do
    if [ $i -eq 5 ]; then
        break    # Exit loop
    fi
    if [ $i -eq 3 ]; then
        continue # Skip to next iteration
    fi
    echo $i
done

========================================
6. WHILE LOOPS
========================================

While loop:
while [ condition ]
do
    commands
done

Counter example:
COUNT=1
while [ $COUNT -le 10 ]
do
    echo $COUNT
    COUNT=$((COUNT + 1))
done

Read file line by line:
while IFS= read -r line
do
    echo "$line"
done < filename

Break and continue:
while [ condition ]
do
    if [ break_condition ]; then
        break
    fi
    if [ skip_condition ]; then
        continue
    fi
    commands
done

========================================
7. FUNCTIONS
========================================

Function definition:
function_name() {
    commands
}

Or alternative syntax:
function function_name {
    commands
}

Function with parameters:
my_function() {
    local PARAM1=$1
    local PARAM2=$2
    echo "Parameter 1: $PARAM1"
    echo "Parameter 2: $PARAM2"
}

Function return value:
my_function() {
    if [ condition ]; then
        return 0  (success)
    else
        return 1  (failure)
    fi
}

Check return value:
if my_function; then
    echo "Success"
else
    echo "Failed"
fi

Local variables:
local VAR="value"
Local variables exist only in function scope

Function with output:
get_date() {
    echo $(date)
}

DATE=$(get_date)

========================================
8. ERROR HANDLING
========================================

Exit codes:
0 = Success
1 = General error
2 = Misuse of shell command
127 = Command not found

Check exit code:
command
if [ $? -eq 0 ]; then
    echo "Success"
fi

Check command success:
if command; then
    echo "Success"
else
    echo "Failed"
fi

Set exit on error:
set -e    (exit on any error)
set +e    (disable)

Error messages to stderr:
echo "Error message" >&2

Parameter validation:
FILE="${1:?Error: Filename required}"

Exit with code:
exit 0
exit 1

========================================
9. USEFUL PATTERNS
========================================

Function with error checking:
process_file() {
    local FILE=$1
    
    if [ -z "$FILE" ]; then
        echo "Error: File required" >&2
        return 1
    fi
    
    if [ ! -f "$FILE" ]; then
        echo "Error: File not found" >&2
        return 2
    fi
    
    # Process file
    return 0
}

Cleanup on exit:
cleanup() {
    echo "Cleaning up..."
    rm -f /tmp/tempfile
}

trap cleanup EXIT

Option parsing:
while [ $# -gt 0 ]
do
    case "$1" in
        -f|--file)
            FILE="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=1
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

========================================
10. BACKUP SCRIPT
========================================

Created: backup_script.sh

Features:
- Takes source directory as argument
- Creates compressed tar.gz backups
- Names backups with timestamp
- Stores in ~/backups/week1/
- Keeps only last 5 backups
- Removes old backups automatically
- Shows backup size and location
- Error checking for all operations
- Returns appropriate exit codes

Usage:
./backup_script.sh /path/to/directory

Output:
- Backup confirmation
- File size
- List of recent backups

========================================
11. DEPLOYMENT CHECKER SCRIPT
========================================

Created: deployment_checker.sh

Features:
- Checks disk space (minimum 20% free)
- Validates required directories
- Checks system resources (memory, load)
- Verifies service status
- Lists listening ports
- Logs all checks with timestamps
- Generates summary report
- Returns appropriate exit codes

Checks performed:
- Disk space percentage
- Required directories exist and writable
- Memory and load average
- Service running (configurable)
- Open ports and connections

Usage:
./deployment_checker.sh
./deployment_checker.sh nginx

Output:
- Pass/Fail/Warn status for each check
- Summary showing ready/not ready
- Log file with all details

========================================
12. HANDS-ON SCRIPTS CREATED
========================================

Basic scripts:
- hello.sh: Simple greeting
- variables.sh: Variable usage
- conditionals.sh: If/else statements
- case-statement.sh: Case statements
- loops.sh: For loop examples
- while-loop.sh: While loop examples
- functions.sh: Function definitions
- error-handling.sh: Error checking

Practical scripts:
- backup_script.sh: Full backup utility
- deployment_checker.sh: Deployment validator

========================================
13. DEBUGGING BASH SCRIPTS
========================================

Enable debug mode:
bash -x script.sh
Set -x at top of script

View script execution:
Set -v (show lines before execution)
Set -x (show lines after expansion)

Debug specific sections:
set -x
critical_code
set +x

Check syntax:
bash -n script.sh

Find undefined variables:
set -u (exit if undefined variable used)

Redirect output:
echo "Debug: $VAR" >&2

========================================
14. SCRIPT BEST PRACTICES
========================================

Always include shebang
Use local variables in functions
Quote variables: "$VAR" not $VAR
Check command results: $?
Use meaningful variable names
Include comments and description
Add error handling and validation
Use functions for code reuse
Test scripts thoroughly
Include usage information
Handle signals with trap
Use exit codes properly
Keep scripts readable and simple

========================================
NEXT STEPS: Weekend Project - Capstone
========================================
