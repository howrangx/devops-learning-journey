#!/bin/bash

# DEVOPS SYSTEM ADMINISTRATION DASHBOARD
# Comprehensive system monitoring and management tool
# Integrates all Week 1 learning concepts

# Script Information
SCRIPT_VERSION="1.0"
SCRIPT_AUTHOR="Iman"
SCRIPT_DATE="June 2026"

# Configuration
LOG_DIR="${HOME}/.devops-dashboard"
LOG_FILE="${LOG_DIR}/dashboard-$(date +%Y%m%d-%H%M%S).log"
REPORT_DIR="${HOME}/devops-reports"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Ensure log directory exists
mkdir -p "$LOG_DIR"
mkdir -p "$REPORT_DIR"

# Function: Log all actions
log_action() {
    local ACTION=$1
    local DETAILS=$2
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ACTION: $ACTION | $DETAILS" >> "$LOG_FILE"
}

# Function: Display menu
show_main_menu() {
    clear
    echo "=========================================="
    echo "DEVOPS SYSTEM ADMINISTRATION DASHBOARD"
    echo "=========================================="
    echo "Version: $SCRIPT_VERSION"
    echo "User: $(whoami) | Hostname: $(hostname)"
    echo ""
    echo "MAIN MENU"
    echo "=========================================="
    echo "1. System Information"
    echo "2. System Monitoring"
    echo "3. Process Management"
    echo "4. File and Permission Management"
    echo "5. Log Analysis"
    echo "6. System Health Check"
    echo "7. Generate System Report"
    echo "8. View Recent Logs"
    echo "9. Exit"
    echo "=========================================="
    echo ""
}

# Function: System Information
system_info_menu() {
    clear
    echo "=========================================="
    echo "SYSTEM INFORMATION"
    echo "=========================================="
    
    echo "Hostname: $(hostname)"
    echo "Kernel: $(uname -r)"
    echo "OS: $(lsb_release -d | cut -f2)"
    echo ""
    
    echo "--- Uptime ---"
    uptime
    echo ""
    
    echo "--- CPU Information ---"
    echo "CPU Cores: $(nproc)"
    lscpu | grep "Model name"
    echo ""
    
    echo "--- Memory Summary ---"
    free -h
    echo ""
    
    echo "--- Disk Summary ---"
    df -h | head -5
    echo ""
    
    log_action "SYSTEM_INFO" "Displayed system information"
    
    read -p "Press Enter to return to main menu..."
}

# Function: System Monitoring
system_monitoring_menu() {
    clear
    echo "=========================================="
    echo "SYSTEM MONITORING"
    echo "=========================================="
    
    echo "--- Load Average ---"
    uptime
    echo ""
    
    echo "--- Memory Usage ---"
    MEM_PERCENT=$(free | grep Mem | awk '{printf "%.1f", ($3/$2)*100}')
    echo "Memory: $MEM_PERCENT%"
    free -h | grep Mem
    echo ""
    
    echo "--- Disk Usage ---"
    DISK_PERCENT=$(df / | tail -1 | awk '{print $5}')
    echo "Root Filesystem: $DISK_PERCENT"
    df -h / | tail -1
    echo ""
    
    echo "--- Top 5 CPU Processes ---"
    ps aux --sort=-%cpu | head -6
    echo ""
    
    echo "--- Top 5 Memory Processes ---"
    ps aux --sort=-%mem | head -6
    echo ""
    
    echo "--- Network Status ---"
    echo "Listening Ports: $(ss -tn | grep LISTEN | wc -l)"
    echo "Established Connections: $(ss -tn | grep ESTAB | wc -l)"
    echo ""
    
    log_action "MONITORING" "Displayed system monitoring data"
    
    read -p "Press Enter to return to main menu..."
}

# Function: Process Management
process_management_menu() {
    clear
    echo "=========================================="
    echo "PROCESS MANAGEMENT"
    echo "=========================================="
    
    read -p "Enter process name to search (or leave blank for all): " PROCESS_NAME
    
    if [ -z "$PROCESS_NAME" ]; then
        echo ""
        echo "--- Running Processes ---"
        ps aux | head -10
    else
        echo ""
        echo "--- Processes matching '$PROCESS_NAME' ---"
        ps aux | grep "$PROCESS_NAME" | grep -v grep
        
        log_action "PROCESS_SEARCH" "Searched for: $PROCESS_NAME"
    fi
    
    echo ""
    read -p "Press Enter to return to main menu..."
}

# Function: File and Permission Management
file_management_menu() {
    clear
    echo "=========================================="
    echo "FILE AND PERMISSION MANAGEMENT"
    echo "=========================================="
    
    echo "Current Directory: $(pwd)"
    echo ""
    
    read -p "Enter directory to navigate to (or press Enter for current): " DIR
    
    if [ -n "$DIR" ]; then
        if [ -d "$DIR" ]; then
            cd "$DIR" 2>/dev/null
            log_action "FILE_NAV" "Navigated to: $DIR"
        else
            echo "Error: Directory not found"
            log_action "FILE_NAV_ERROR" "Directory not found: $DIR"
        fi
    fi
    
    echo ""
    echo "--- Files in Current Directory ---"
    ls -lh | head -15
    echo ""
    
    read -p "Press Enter to return to main menu..."
}

# Function: Log Analysis
log_analysis_menu() {
    clear
    echo "=========================================="
    echo "LOG ANALYSIS"
    echo "=========================================="
    
    LOG_PATH="/var/log/syslog"
    
    if [ ! -f "$LOG_PATH" ]; then
        LOG_PATH="/var/log/system.log"
    fi
    
    if [ ! -f "$LOG_PATH" ]; then
        echo "System log file not found"
        read -p "Press Enter to return to main menu..."
        return
    fi
    
    echo "Analyzing: $LOG_PATH"
    echo ""
    
    TOTAL_LINES=$(wc -l < "$LOG_PATH")
    ERROR_COUNT=$(grep -ic "error" "$LOG_PATH")
    WARNING_COUNT=$(grep -ic "warning" "$LOG_PATH")
    
    echo "Total Lines: $TOTAL_LINES"
    echo "Errors: $ERROR_COUNT"
    echo "Warnings: $WARNING_COUNT"
    echo ""
    
    echo "--- Recent Entries (last 10) ---"
    tail -10 "$LOG_PATH"
    echo ""
    
    log_action "LOG_ANALYSIS" "Analyzed log file: $LOG_PATH"
    
    read -p "Press Enter to return to main menu..."
}

# Function: System Health Check
health_check_menu() {
    clear
    echo "=========================================="
    echo "SYSTEM HEALTH CHECK"
    echo "=========================================="
    
    WARNINGS=0
    ALERTS=0
    
    # CPU Load Check
    echo "--- CPU Load ---"
    LOAD=$(uptime | awk -F'load average:' '{print $2}' | cut -d, -f1 | xargs)
    echo "Load Average: $LOAD"
    echo "Status: OK"
    echo ""
    
    # Memory Check
    echo "--- Memory ---"
    MEM_PERCENT=$(free | grep Mem | awk '{printf "%.0f", ($3/$2)*100}')
    echo "Memory Usage: $MEM_PERCENT%"
    
    if [ "$MEM_PERCENT" -ge 80 ]; then
        echo "Status: WARNING"
        WARNINGS=$((WARNINGS + 1))
    else
        echo "Status: OK"
    fi
    echo ""
    
    # Disk Check
    echo "--- Disk Space ---"
    DISK_PERCENT=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    echo "Disk Usage: $DISK_PERCENT%"
    
    if [ "$DISK_PERCENT" -ge 80 ]; then
        echo "Status: WARNING"
        WARNINGS=$((WARNINGS + 1))
    else
        echo "Status: OK"
    fi
    echo ""
    
    # Overall Status
    echo "=========================================="
    echo "OVERALL HEALTH STATUS"
    echo "=========================================="
    
    if [ $WARNINGS -eq 0 ]; then
        echo "Status: HEALTHY"
    elif [ $WARNINGS -lt 3 ]; then
        echo "Status: DEGRADED - $WARNINGS warning(s)"
    else
        echo "Status: CRITICAL - Multiple warnings"
    fi
    
    log_action "HEALTH_CHECK" "Performed system health check (Warnings: $WARNINGS)"
    
    echo ""
    read -p "Press Enter to return to main menu..."
}

# Function: Generate System Report
generate_report() {
    clear
    echo "=========================================="
    echo "GENERATING SYSTEM REPORT"
    echo "=========================================="
    
    REPORT_FILE="${REPORT_DIR}/system-report-$(date +%Y%m%d-%H%M%S).txt"
    
    {
        echo "SYSTEM ADMINISTRATION REPORT"
        echo "Generated: $(date)"
        echo "=========================================="
        echo ""
        
        echo "SYSTEM INFORMATION"
        echo "=========================================="
        echo "Hostname: $(hostname)"
        echo "Kernel: $(uname -r)"
        echo "OS: $(lsb_release -d | cut -f2)"
        echo "Uptime: $(uptime | awk -F'up' '{print $2}')"
        echo ""
        
        echo "RESOURCES"
        echo "=========================================="
        echo "CPU Cores: $(nproc)"
        echo ""
        echo "Memory:"
        free -h | grep Mem
        echo ""
        echo "Disk:"
        df -h / | tail -1
        echo ""
        
        echo "TOP PROCESSES"
        echo "=========================================="
        echo "CPU Hogs:"
        ps aux --sort=-%cpu | head -6
        echo ""
        echo "Memory Hogs:"
        ps aux --sort=-%mem | head -6
        echo ""
        
        echo "SYSTEM HEALTH"
        echo "=========================================="
        MEM_PERCENT=$(free | grep Mem | awk '{printf "%.1f", ($3/$2)*100}')
        DISK_PERCENT=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
        echo "Memory: $MEM_PERCENT%"
        echo "Disk: $DISK_PERCENT%"
        
    } > "$REPORT_FILE"
    
    echo "Report generated: $REPORT_FILE"
    echo ""
    echo "--- Report Preview ---"
    head -30 "$REPORT_FILE"
    echo ""
    
    log_action "REPORT_GENERATION" "Generated report: $REPORT_FILE"
    
    read -p "Press Enter to return to main menu..."
}

# Function: View Recent Logs
view_logs() {
    clear
    echo "=========================================="
    echo "RECENT DASHBOARD LOGS"
    echo "=========================================="
    echo ""
    
    if [ -f "$LOG_FILE" ]; then
        echo "--- Recent Actions (last 20) ---"
        tail -20 "$LOG_FILE"
    else
        echo "No log file found"
    fi
    
    echo ""
    read -p "Press Enter to return to main menu..."
}

# Function: Exit gracefully
exit_dashboard() {
    clear
    echo "=========================================="
    echo "Exiting DEVOPS DASHBOARD"
    echo "=========================================="
    echo ""
    echo "Log file: $LOG_FILE"
    echo "Reports directory: $REPORT_DIR"
    echo ""
    
    log_action "EXIT" "Dashboard closed"
    
    echo "Thank you for using DEVOPS Dashboard!"
    echo ""
    exit 0
}

# Main Loop
main() {
    while true
    do
        show_main_menu
        
        read -p "Select option (1-9): " CHOICE
        
        case $CHOICE in
            1)
                system_info_menu
                ;;
            2)
                system_monitoring_menu
                ;;
            3)
                process_management_menu
                ;;
            4)
                file_management_menu
                ;;
            5)
                log_analysis_menu
                ;;
            6)
                health_check_menu
                ;;
            7)
                generate_report
                ;;
            8)
                view_logs
                ;;
            9)
                exit_dashboard
                ;;
            *)
                echo "Invalid option. Please select 1-9."
                log_action "INVALID_INPUT" "User selected: $CHOICE"
                sleep 2
                ;;
        esac
    done
}

# Start dashboard with logging
log_action "START" "Dashboard initialized by $(whoami)"
main

