DAY 4: PROCESS MANAGEMENT AND SYSTEM MONITORING
Command Reference and Learning Notes

LEARNING DATE: June 1, 2026
COMPLETED BY: Iman

========================================
1. PROCESS BASICS
========================================

Every running program is a process with:
- PID (Process ID) - Unique identifier
- PPID (Parent Process ID) - Parent process
- User - Process owner
- CPU and Memory usage
- Status - Running, sleeping, stopped

Process States:
R - Running (using CPU)
S - Sleeping (waiting for input)
Z - Zombie (terminated but parent hasn't acknowledged)
T - Stopped (paused)
W - Paging (moving to/from disk)

========================================
2. PS COMMAND - VIEW PROCESSES
========================================

Basic syntax:
ps [OPTIONS]

Common options:
ps              Show your processes
ps a            Show all processes
ps aux          Show all with detailed info
ps -ef          Show process tree
ps -o pid,cmd   Show specific columns

Output columns:
USER    = Process owner
PID     = Process ID
%CPU    = CPU percentage
%MEM    = Memory percentage
VSZ     = Virtual memory size (KB)
RSS     = Actual memory used (KB)
STAT    = Process state
COMMAND = Command that started process

Useful examples:
ps aux | grep bash
ps aux --sort=-%cpu | head -10
ps aux --sort=-%mem | head -10
ps -o pid,nice,cmd

========================================
3. TOP COMMAND - REAL-TIME MONITORING
========================================

Launch top:
top              Interactive view (press q to quit)
top -b -n 1      Batch mode, single update
top -u user      Monitor specific user
top -o %CPU      Sort by CPU
top -o %MEM      Sort by memory
top -d 2         Update every 2 seconds

Interactive keys:
q = Quit
Space = Update screen
M = Sort by memory
P = Sort by CPU
T = Sort by time
u = Filter by user
k = Kill process
h = Help

========================================
4. HTOP COMMAND - ENHANCED TOP
========================================

Installation:
sudo apt install -y htop

Launch:
htop             Interactive enhanced view

Interactive keys:
q = Quit
Arrow keys = Navigate
F3 = Search
F4 = Filter
F6 = Sort options
F9 = Kill process
u = Filter by user
t = Toggle tree view

Advantages over top:
- Color output
- Easier navigation
- Better layout
- Killing processes easier

========================================
5. KILL COMMAND - PROCESS CONTROL
========================================

Graceful termination:
kill PID
kill -15 PID
kill -SIGTERM PID

Force kill:
kill -9 PID
kill -SIGKILL PID

Kill by name:
killall process_name
killall bash

Kill by pattern:
pkill pattern
pkill -f "python script.py"

Signals:
SIGTERM (15) = Terminate gracefully
SIGKILL (9)  = Kill immediately
SIGHUP (1)   = Reload configuration
SIGSTOP      = Pause process
SIGCONT      = Resume process
SIGINT (2)   = Interrupt (Ctrl+C)

========================================
6. PROCESS PRIORITY
========================================

Check nice value:
ps -o pid,nice,cmd

Run with lower priority:
nice -n 10 command
Lower priority = higher number (up to 19)

Run with higher priority (needs sudo):
sudo nice -n -10 command
Higher priority = negative number (down to -20)

Change priority of running process:
renice -n 5 -p PID
renice -n -10 -p PID

Nice values:
-20 to -1   = High priority (needs root)
0           = Default priority
1 to 19     = Lower priority

========================================
7. BACKGROUND JOBS AND CONTROL
========================================

Run in background:
command &

View background jobs:
jobs
jobs -l

Bring to foreground:
fg %1
fg %job_number

Resume in background:
bg %1

Run immune to terminal disconnect:
nohup command &
nohup command > output.log 2>&1 &

Check if process running:
pgrep process_name

========================================
8. CPU MONITORING
========================================

CPU cores:
nproc

CPU information:
lscpu
cat /proc/cpuinfo

Load average:
uptime

System activity:
vmstat 1 5  (1 second interval, 5 times)

Top CPU processes:
ps aux --sort=-%cpu | head -10

Continuous monitoring:
watch uptime

========================================
9. MEMORY MONITORING
========================================

Memory usage:
free
free -h
free -h -t

Memory breakdown:
Total = Total memory
Used = Memory in use
Free = Completely unused memory
Available = Free + reclaimable cache

Top memory processes:
ps aux --sort=-%mem | head -10

Memory hogs:
ps aux --sort=-%mem | head -5

Continuous monitoring:
watch -n 1 free -h

Swap usage:
free -h | grep Swap

========================================
10. DISK MONITORING
========================================

Disk space:
df
df -h
df -h /

Inode usage:
df -i

Directory size:
du -sh /path
du -sh *
du -h --max-depth=1

Large files:
find . -type f -size +100M

Sort directories:
du -sh * | sort -hr

Disk activity:
iostat (if installed)

========================================
11. NETWORK MONITORING
========================================

Network interfaces:
ip link show
ifconfig

IP addresses:
ip addr
hostname -I

Active connections:
ss -tn
netstat -tuln

Established connections:
ss -tn | grep ESTAB

Listening ports:
ss -tn | grep LISTEN

Network statistics:
netstat -s

DNS resolution:
nslookup domain.com
dig domain.com

========================================
12. SYSTEM MONITOR SCRIPT
========================================

Created: system_monitor.sh

Features:
- System uptime and hostname
- CPU cores and model
- Load average
- Total and used memory
- Memory percentage with warnings (>80%)
- Disk usage with warnings (>80%)
- Swap usage
- Top 5 CPU processes
- Top 5 memory processes
- Network interfaces
- Network connections count
- Overall health summary
- Generates timestamped report file

Usage:
./system_monitor.sh

Output:
system-status-YYYYMMDD-HHMMSS.txt

Alerts for:
- Memory above 80%
- Disk above 80%
- Shows warning count

========================================
13. QUICK HEALTH CHECK SCRIPT
========================================

Created: quick-health-check.sh

Features:
- Quick CPU load
- Memory summary
- Disk usage summary
- Running process count
- Connected users count

Usage:
./quick-health-check.sh

Output:
One-page system overview

Speed:
Executes in seconds

Use case:
Quick system status checks

========================================
14. COMMON MONITORING PATTERNS
========================================

Find process and kill:
ps aux | grep process_name
kill -9 PID

Monitor in real-time:
watch -n 1 command

Continuous logging:
command > output.log &
tail -f output.log

Find resource hogs:
ps aux --sort=-%mem | head -5
ps aux --sort=-%cpu | head -5

Count processes:
ps aux | wc -l
ps aux | grep user | wc -l

Monitor specific user:
ps -u username
top -u username

Check if running:
ps aux | grep "exact command" | grep -v grep

========================================
15. TROUBLESHOOTING SCENARIOS
========================================

High CPU usage:
ps aux --sort=-%cpu | head -5
Kill if necessary: kill -9 PID

High memory usage:
ps aux --sort=-%mem | head -5
Check for memory leak or growth

Disk space full:
df -h
du -sh * | sort -hr
Find and delete large files

Process not responding:
kill -9 PID
killall process_name

Find zombie processes:
ps aux | grep Z

Connection issues:
ss -tuln
Check if service listening

========================================
16. HANDS-ON PRACTICE PERFORMED
========================================

Created monitoring scripts:
- system_monitor.sh: Comprehensive monitoring
- quick-health-check.sh: Quick overview

Tested commands:
- ps with various options
- top and htop
- free for memory
- df for disk
- vmstat for system activity
- kill and killall
- nice and renice
- jobs and background processes

Generated reports:
- system-status-YYYYMMDD-HHMMSS.txt files

========================================
NEXT STEPS: Day 5 - Bash Scripting Fundamentals
========================================
