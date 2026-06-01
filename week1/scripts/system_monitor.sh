#!/bin/bash

# System Monitor Script
# Monitors system health and generates reports
# Shows CPU, memory, disk usage with threshold alerts

# Create output file
OUTPUT_FILE="system-status-$(date +%Y%m%d-%H%M%S).txt"

# Start monitoring
{
    echo "=========================================="
    echo "SYSTEM HEALTH REPORT"
    echo "=========================================="
    echo "Generated: $(date)"
    echo "Hostname: $(hostname)"
    echo "Kernel: $(uname -r)"
    echo ""
    
    # System uptime
    echo "SYSTEM UPTIME"
    echo "=========================================="
    uptime
    echo ""
    
    # CPU Information
    echo "CPU INFORMATION"
    echo "=========================================="
    CPU_CORES=$(nproc)
    echo "CPU Cores: $CPU_CORES"
    lscpu | grep "Model name"
    echo ""
    
    # Load Average
    echo "LOAD AVERAGE"
    echo "=========================================="
    LOAD=$(uptime | awk -F'load average:' '{print $2}')
    echo "Load Average: $LOAD"
    echo ""
    
    # Memory Usage
    echo "MEMORY USAGE"
    echo "=========================================="
    MEM_INFO=$(free -h | grep Mem)
    TOTAL_MEM=$(echo $MEM_INFO | awk '{print $2}')
    USED_MEM=$(echo $MEM_INFO | awk '{print $3}')
    
    # Calculate memory percentage
    MEM_PERCENT=$(free | grep Mem | awk '{printf "%.1f", ($3/$2)*100}')
    
    echo "Total Memory: $TOTAL_MEM"
    echo "Used Memory: $USED_MEM"
    echo "Memory Usage: ${MEM_PERCENT}%"
    
    # Check if above threshold
    THRESHOLD_CHECK=$(echo $MEM_PERCENT | awk '{if ($1 >= 80) print "1"; else print "0"}')
    if [ "$THRESHOLD_CHECK" = "1" ]; then
        echo "WARNING: Memory usage above 80%"
    fi
    echo ""
    
    # Disk Usage
    echo "DISK USAGE"
    echo "=========================================="
    DISK_INFO=$(df -h / | tail -1)
    DISK_SIZE=$(echo $DISK_INFO | awk '{print $2}')
    DISK_USED=$(echo $DISK_INFO | awk '{print $3}')
    DISK_PERCENT=$(echo $DISK_INFO | awk '{print $5}' | sed 's/%//')
    
    echo "Filesystem: $(echo $DISK_INFO | awk '{print $1}')"
    echo "Total Size: $DISK_SIZE"
    echo "Used Space: $DISK_USED"
    echo "Disk Usage: ${DISK_PERCENT}%"
    
    if [ "$DISK_PERCENT" -ge 80 ]; then
        echo "WARNING: Disk usage above 80%"
    fi
    echo ""
    
    # Swap Usage
    echo "SWAP USAGE"
    echo "=========================================="
    SWAP_INFO=$(free -h | grep Swap)
    SWAP_TOTAL=$(echo $SWAP_INFO | awk '{print $2}')
    SWAP_USED=$(echo $SWAP_INFO | awk '{print $3}')
    echo "Swap Total: $SWAP_TOTAL"
    echo "Swap Used: $SWAP_USED"
    echo ""
    
    # Top CPU Processes
    echo "TOP 5 CPU CONSUMING PROCESSES"
    echo "=========================================="
    ps aux --sort=-%cpu | head -6 | tail -5
    echo ""
    
    # Top Memory Processes
    echo "TOP 5 MEMORY CONSUMING PROCESSES"
    echo "=========================================="
    ps aux --sort=-%mem | head -6 | tail -5
    echo ""
    
    # Network Interfaces
    echo "NETWORK INTERFACES"
    echo "=========================================="
    ip link show | grep "^[0-9]:" | head -5
    echo ""
    
    # Open Connections
    echo "NETWORK CONNECTIONS"
    echo "=========================================="
    echo "Established connections: $(ss -tn 2>/dev/null | grep ESTAB | wc -l)"
    echo "Listening ports: $(ss -tn 2>/dev/null | grep LISTEN | wc -l)"
    echo ""
    
    # System Load Health
    echo "SYSTEM HEALTH SUMMARY"
    echo "=========================================="
    
    WARNINGS=0
    
    # Check memory
    MEMORY_CHECK=$(echo $MEM_PERCENT | awk '{if ($1 >= 80) print "1"; else print "0"}')
    if [ "$MEMORY_CHECK" = "1" ]; then
        echo "Alert: Memory usage at ${MEM_PERCENT}%"
        WARNINGS=$((WARNINGS + 1))
    fi
    
    # Check disk
    if [ "$DISK_PERCENT" -ge 80 ]; then
        echo "Alert: Disk usage at ${DISK_PERCENT}%"
        WARNINGS=$((WARNINGS + 1))
    fi
    
    if [ $WARNINGS -eq 0 ]; then
        echo "Status: All systems operating normally"
    else
        echo "Status: $WARNINGS warning(s) detected"
    fi
    
    echo ""
    echo "=========================================="
    echo "Report End: $(date)"
    echo "=========================================="
    
} > "$OUTPUT_FILE"

# Display report to console
cat "$OUTPUT_FILE"

# Save location message
echo ""
echo "=========================================="
echo "Full report saved to: $OUTPUT_FILE"
echo "=========================================="

exit 0
