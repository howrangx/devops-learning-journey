#!/bin/bash

# Log Analyzer Script
# Analyzes log files for errors, warnings, and generates reports

# Function: Display usage
usage() {
    echo "Usage: ./log-analyzer.sh <logfile>"
    echo "Example: ./log-analyzer.sh app.log"
    exit 1
}

# Check if logfile is provided
if [ $# -eq 0 ]; then
    echo "Error: No log file specified"
    usage
fi

LOG_FILE=$1

# Verify file exists
if [ ! -f "$LOG_FILE" ]; then
    echo "Error: Log file '$LOG_FILE' not found"
    exit 1
fi

# Check if file is readable
if [ ! -r "$LOG_FILE" ]; then
    echo "Error: Log file '$LOG_FILE' is not readable"
    exit 1
fi

# Create output file
OUTPUT_FILE="analysis-report-$(date +%Y%m%d-%H%M%S).txt"

# Start generating report
{
    echo "=========================================="
    echo "LOG ANALYSIS REPORT"
    echo "=========================================="
    echo "Log File: $LOG_FILE"
    echo "Analysis Date: $(date)"
    echo "=========================================="
    echo ""
    
    # Basic statistics
    echo "BASIC STATISTICS"
    echo "=========================================="
    TOTAL_LINES=$(wc -l < "$LOG_FILE")
    ERROR_COUNT=$(grep -c "ERROR" "$LOG_FILE" 2>/dev/null || echo 0)
    WARNING_COUNT=$(grep -c "WARNING" "$LOG_FILE" 2>/dev/null || echo 0)
    INFO_COUNT=$(grep -c "INFO" "$LOG_FILE" 2>/dev/null || echo 0)
    
    echo "Total lines: $TOTAL_LINES"
    echo "Error entries: $ERROR_COUNT"
    echo "Warning entries: $WARNING_COUNT"
    echo "Info entries: $INFO_COUNT"
    echo ""
    
    # Log level breakdown
    echo "LOG LEVEL DISTRIBUTION"
    echo "=========================================="
    awk '{print $3}' "$LOG_FILE" | grep -E "ERROR|WARNING|INFO" | sort | uniq -c
    echo ""
    
    # Error details
    echo "ERROR ENTRIES"
    echo "=========================================="
    if [ $ERROR_COUNT -gt 0 ]; then
        grep -n "ERROR" "$LOG_FILE" | head -10
        if [ $ERROR_COUNT -gt 10 ]; then
            echo "... and $((ERROR_COUNT - 10)) more error entries"
        fi
    else
        echo "No error entries found"
    fi
    echo ""
    
    # Warning details
    echo "WARNING ENTRIES"
    echo "=========================================="
    if [ $WARNING_COUNT -gt 0 ]; then
        grep -n "WARNING" "$LOG_FILE" | head -10
        if [ $WARNING_COUNT -gt 10 ]; then
            echo "... and $((WARNING_COUNT - 10)) more warning entries"
        fi
    else
        echo "No warning entries found"
    fi
    echo ""
    
    # Recent entries
    echo "MOST RECENT 5 ENTRIES"
    echo "=========================================="
    tail -5 "$LOG_FILE"
    echo ""
    
    # Summary
    echo "SUMMARY"
    echo "=========================================="
    if [ $ERROR_COUNT -gt 0 ]; then
        ERROR_PERCENT=$((ERROR_COUNT * 100 / TOTAL_LINES))
        echo "Alert: Found $ERROR_COUNT errors ($ERROR_PERCENT% of total)"
    fi
    
    if [ $WARNING_COUNT -gt 0 ]; then
        WARN_PERCENT=$((WARNING_COUNT * 100 / TOTAL_LINES))
        echo "Notice: Found $WARNING_COUNT warnings ($WARN_PERCENT% of total)"
    fi
    
    if [ $ERROR_COUNT -eq 0 ] && [ $WARNING_COUNT -eq 0 ]; then
        echo "Status: No errors or warnings found"
    fi
    
} > "$OUTPUT_FILE"

# Display report
cat "$OUTPUT_FILE"

# Save location
echo ""
echo "=========================================="
echo "Report saved to: $OUTPUT_FILE"
echo "=========================================="

exit 0
