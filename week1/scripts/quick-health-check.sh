#!/bin/bash

# Quick System Health Check
# Fast overview of system status

echo "Quick System Health Check"
echo "Time: $(date)"
echo ""

# CPU Load
echo "CPU Load:"
uptime | awk -F'load average:' '{print $2}'

# Memory
echo ""
echo "Memory:"
free -h | grep Mem | awk '{print "Used: " $3 " / " $2}'

# Disk
echo ""
echo "Disk Root:"
df -h / | tail -1 | awk '{print "Used: " $3 " / " $2 " (" $5 ")"}'

# Running Processes
echo ""
echo "Running Processes: $(ps aux | wc -l)"

# Connected Users
echo "Connected Users: $(who | wc -l)"

