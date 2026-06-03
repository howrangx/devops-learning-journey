#!/bin/bash

# Deployment Checker Script
# Validates system readiness for deployment
# Checks disk space, services, directories, permissions

# Configuration
REQUIRED_DISK_PERCENT=20  # Minimum free disk space percentage
REQUIRED_DIRS=("/var/log" "/tmp" "/home")
SERVICE_NAME="${1:-nginx}"  # Service to check (default: nginx)
LOG_FILE="deployment-check-$(date +%Y%m%d-%H%M%S).log"

# Color codes (for terminal output)
PASS="PASS"
FAIL="FAIL"
WARN="WARN"

# Function: Log message
log_message() {
    local STATUS=$1
    local MESSAGE=$2
    local TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$TIMESTAMP] [$STATUS] $MESSAGE" | tee -a "$LOG_FILE"
}

# Function: Check disk space
check_disk_space() {
    echo ""
    echo "=== DISK SPACE CHECK ==="
    
    DISK_PERCENT=$(df / | tail -1 | awk '{print 100 - $5}')
    
    if [ "$DISK_PERCENT" -ge "$REQUIRED_DISK_PERCENT" ]; then
        log_message "$PASS" "Disk free: ${DISK_PERCENT}% (Required: ${REQUIRED_DISK_PERCENT}%)"
        return 0
    else
        log_message "$FAIL" "Disk free: ${DISK_PERCENT}% (Required: ${REQUIRED_DISK_PERCENT}%)"
        return 1
    fi
}

# Function: Check required directories
check_directories() {
    echo ""
    echo "=== DIRECTORY CHECK ==="
    
    local FAIL_COUNT=0
    
    for DIR in "${REQUIRED_DIRS[@]}"
    do
        if [ -d "$DIR" ]; then
            if [ -w "$DIR" ]; then
                log_message "$PASS" "Directory exists and writable: $DIR"
            else
                log_message "$WARN" "Directory exists but not writable: $DIR"
                FAIL_COUNT=$((FAIL_COUNT + 1))
            fi
        else
            log_message "$FAIL" "Directory not found: $DIR"
            FAIL_COUNT=$((FAIL_COUNT + 1))
        fi
    done
    
    if [ $FAIL_COUNT -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

# Function: Check system resources
check_system_resources() {
    echo ""
    echo "=== SYSTEM RESOURCES CHECK ==="
    
    # Memory check
    MEM_PERCENT=$(free | grep Mem | awk '{printf "%d", ($3/$2)*100}')
    
    if [ "$MEM_PERCENT" -lt 80 ]; then
        log_message "$PASS" "Memory usage: ${MEM_PERCENT}%"
    else
        log_message "$WARN" "Memory usage: ${MEM_PERCENT}% (Above 80%)"
    fi
    
    # Load check
    LOAD=$(uptime | awk -F'load average:' '{print $2}' | cut -d, -f1 | xargs)
    log_message "$PASS" "Load average: $LOAD"
    
    return 0
}

# Function: Check service status
check_service() {
    echo ""
    echo "=== SERVICE CHECK ==="
    
    if command -v systemctl &> /dev/null; then
        if systemctl is-active --quiet "$SERVICE_NAME"; then
            log_message "$PASS" "Service '$SERVICE_NAME' is running"
            return 0
        else
            log_message "$FAIL" "Service '$SERVICE_NAME' is not running"
            return 1
        fi
    else
        log_message "$WARN" "systemctl not available, cannot check service"
        return 2
    fi
}

# Function: Check ports
check_ports() {
    echo ""
    echo "=== NETWORK PORTS CHECK ==="
    
    LISTENING_PORTS=$(ss -tn | grep LISTEN | wc -l)
    
    if [ "$LISTENING_PORTS" -gt 0 ]; then
        log_message "$PASS" "Listening ports: $LISTENING_PORTS"
        echo "Recent listening ports:"
        ss -tn | grep LISTEN | head -3 | tee -a "$LOG_FILE"
    else
        log_message "$WARN" "No listening ports found"
    fi
    
    return 0
}

# Function: Generate summary
generate_summary() {
    echo ""
    echo "=========================================="
    echo "DEPLOYMENT CHECK SUMMARY"
    echo "=========================================="
    
    PASS_COUNT=$(grep -c "PASS" "$LOG_FILE")
    FAIL_COUNT=$(grep -c "FAIL" "$LOG_FILE")
    WARN_COUNT=$(grep -c "WARN" "$LOG_FILE")
    
    echo "Passed: $PASS_COUNT"
    echo "Failed: $FAIL_COUNT"
    echo "Warnings: $WARN_COUNT"
    echo ""
    
    if [ "$FAIL_COUNT" -eq 0 ]; then
        echo "Status: READY FOR DEPLOYMENT"
        return 0
    else
        echo "Status: NOT READY - Fix failures before deployment"
        return 1
    fi
}

# Main execution
main() {
    echo "=========================================="
    echo "DEPLOYMENT CHECKER"
    echo "=========================================="
    echo "Service to check: $SERVICE_NAME"
    echo "Log file: $LOG_FILE"
    echo ""
    
    # Run all checks
    check_disk_space
    DISK_RESULT=$?
    
    check_directories
    DIR_RESULT=$?
    
    check_system_resources
    
    check_service
    SERVICE_RESULT=$?
    
    check_ports
    
    # Generate summary
    echo ""
    generate_summary
    SUMMARY_RESULT=$?
    
    # Determine overall exit code
    if [ $DISK_RESULT -ne 0 ] || [ $DIR_RESULT -ne 0 ] || [ $SERVICE_RESULT -eq 1 ]; then
        exit 1
    fi
    
    exit 0
}

# Run main
main

