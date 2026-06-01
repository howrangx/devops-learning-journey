DAY 3: TEXT PROCESSING AND SEARCHING
Command Reference and Learning Notes

LEARNING DATE: June 1, 2026
COMPLETED BY: Iman

========================================
1. PIPES AND REDIRECTION
========================================

Pipes: Chain commands together
Syntax: command1 | command2

Examples:
ls | wc -l              Count files
ls | sort               Sort file list
ps aux | grep python    Find Python processes

Redirection:
command > file          Overwrite file with output
command >> file         Append output to file
command 2> file         Redirect errors to file
command &> file         Redirect output and errors

========================================
2. GREP - SEARCH FOR PATTERNS
========================================

Basic syntax:
grep PATTERN FILE

Common options:
-i                      Case insensitive
-n                      Show line numbers
-c                      Count matching lines
-v                      Invert (show non-matching)
-E                      Extended regex (multiple patterns)
-o                      Show only matched part

Examples:
grep "ERROR" app.log
grep -i "error" app.log
grep -c "ERROR" app.log
grep -n "ERROR" app.log
grep -E "ERROR|WARNING" app.log
grep -v "DEBUG" app.log

Patterns:
^TEXT                   Line starts with TEXT
TEXT$                   Line ends with TEXT
.*pattern.*             Contains pattern anywhere
[0-9]                   Single digit
[a-z]                   Single letter

========================================
3. FIND - LOCATE FILES
========================================

Basic syntax:
find PATH [OPTIONS] [ACTION]

Common options:
-name PATTERN           Find by filename
-type f                 Find files only
-type d                 Find directories only
-mtime DAYS             Modified N days ago
-mtime -7               Modified in last 7 days
-size SIZE              File size (k, M, G)
-size +1k               Larger than 1KB
-size -10k              Smaller than 10KB

Examples:
find . -name "*.log"
find . -type f
find . -type d
find . -mtime -7
find . -size +1k
find . -name "*.log" -type f
find . -mtime 0

Actions:
-ls                     List file details
-delete                 Delete matched files
-exec COMMAND {} \;     Execute command on matches

========================================
4. AWK - PATTERN SCANNING AND PROCESSING
========================================

Basic syntax:
awk [OPTIONS] 'PATTERN {ACTION}' FILE

Fields:
$0                      Entire line
$1, $2, $3             First, second, third field
NF                      Number of fields
NR                      Number of records (line number)

Examples:
awk '{print}' file.txt
awk '{print $1}' file.txt
awk '{print $1, $3}' file.txt
awk -F: '{print $1}' /etc/passwd
awk '/ERROR/ {print}' app.log
awk '$3 == "ERROR" {print}' app.log

Advanced:
awk '{level[$3]++} END {for (l in level) print l, level[l]}' file
Count occurrences of each value in field 3

========================================
5. SED - STREAM EDITOR
========================================

Basic syntax:
sed 's/PATTERN/REPLACEMENT/' FILE
sed 's/PATTERN/REPLACEMENT/g' FILE

Common options:
s                       Substitute
g                       Global (all occurrences)
i                       Case insensitive
d                       Delete
p                       Print
-n                      Suppress automatic printing
-i                      In-place file editing

Examples:
sed 's/ERROR/CRITICAL/' file.log
sed 's/ERROR/CRITICAL/g' file.log
sed '/ERROR/d' file.log
sed -n '1,5p' file.log
sed -i 's/old/new/g' file.log

Address range:
sed '1,5d'              Delete lines 1-5
sed '10d'               Delete line 10
sed '1,5s/a/b/'         Substitute on lines 1-5

========================================
6. CUT - EXTRACT FIELDS
========================================

Basic syntax:
cut [OPTIONS] FILE

Options:
-c LIST                 Extract by character position
-f LIST                 Extract by field
-d DELIM                Field delimiter (default space)

Examples:
cut -c 1-10 file.txt
cut -d' ' -f1 file.txt
cut -d: -f1 /etc/passwd
cut -c 1-10,20-26 file.txt

Field lists:
-f 1                    Field 1
-f 1,3                  Fields 1 and 3
-f 1-3                  Fields 1, 2, and 3
-f 1-                   From field 1 to end

========================================
7. SORT AND UNIQ
========================================

Sort:
sort file.txt           Alphabetical sort
sort -r file.txt        Reverse sort
sort -n file.txt        Numeric sort
sort -u file.txt        Sort and remove duplicates

Uniq (requires sorted input):
sort file.txt | uniq
sort file.txt | uniq -c  Count occurrences
sort file.txt | uniq -d  Show only duplicates
sort file.txt | uniq -u  Show only unique lines

Counting:
awk '{print $3}' file.txt | sort | uniq -c
Count occurrences of each value in field 3

========================================
8. PRACTICAL EXAMPLES
========================================

Log analysis:
grep "ERROR" app.log | wc -l
Count error lines

grep "ERROR" app.log | awk '{print $1, $2}'
Show date and time of errors

grep -c "ERROR|WARNING" app.log
Count both errors and warnings

awk '/ERROR/ {print $1, $2, $10, $11}' app.log
Extract specific fields from errors

Generate reports:
echo "Errors: $(grep -c ERROR log.txt)"
echo "Warnings: $(grep -c WARNING log.txt)"

Find and process:
find . -name "*.log" -exec grep "ERROR" {} \;
Find all errors in log files

awk '{print $3}' file.txt | sort | uniq -c | sort -rn
Count and rank items

========================================
9. LOG ANALYZER SCRIPT
========================================

Created: log-analyzer.sh

Features:
- Accepts log file as argument
- Counts total lines
- Counts error entries
- Counts warning entries
- Counts info entries
- Shows log level distribution
- Lists recent error entries
- Lists recent warning entries
- Shows most recent 5 entries
- Generates error/warning percentages
- Saves report to dated file

Usage:
./log-analyzer.sh app.log

Output:
analysis-report-YYYYMMDD-HHMMSS.txt

Script handles:
- File existence check
- File readability check
- Error count
- Warning count
- Entry extraction
- Report generation

========================================
10. COMMAND COMBINATIONS
========================================

Count matching patterns:
grep "PATTERN" file | wc -l

Show with line numbers:
grep -n "PATTERN" file

Top N entries:
command | head -N
command | tail -N

Sort and count:
awk '{print $FIELD}' file | sort | uniq -c

Extract and filter:
cut -d: -f1 /etc/passwd | grep "^a"
Show fields starting with 'a'

Multiple conditions:
grep "ERROR" file | grep -v "DEBUG"
Errors but not debug errors

Complex pipeline:
find . -name "*.log" | xargs grep "ERROR" | awk '{print $1}' | sort | uniq -c

========================================
11. HANDS-ON PRACTICE PERFORMED
========================================

Created sample log file: app.log
15 log entries with INFO, ERROR, WARNING levels

Tested grep:
- Pattern matching
- Case insensitive search
- Line numbers
- Counting
- Inverse matching
- Multiple patterns

Tested awk:
- Field extraction
- Pattern matching
- Field counting
- Conditional processing
- Array operations

Tested sed:
- Substitution
- Deletion
- Specific line ranges
- In-place editing

Tested cut:
- Character extraction
- Field extraction
- Custom delimiters

Tested sort and uniq:
- Alphabetical sorting
- Numeric sorting
- Duplicate removal
- Duplicate counting

========================================
NEXT STEPS: Day 4 - Process Management and System Monitoring
========================================
