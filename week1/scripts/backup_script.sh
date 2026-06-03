#!/bin/bash

# Backup Script
# Creates compressed backups of directories
# Keeps only last 5 backups

# Configuration
SOURCE_DIR="${1:?Error: Source directory required}"
BACKUP_BASE_DIR="${HOME}/backups"
BACKUP_DIR="${BACKUP_BASE_DIR}/week1"
MAX_BACKUPS=5
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="backup_${DATE}.tar.gz"

# Function: Display usage
usage() {
    echo "Usage: $0 <source_directory>"
    echo "Example: $0 ~/devops-learning"
    exit 1
}

# Function: Check if source exists
check_source() {
    if [ ! -d "$SOURCE_DIR" ]; then
        echo "Error: Source directory '$SOURCE_DIR' not found"
        return 1
    fi
    
    if [ ! -r "$SOURCE_DIR" ]; then
        echo "Error: Source directory '$SOURCE_DIR' is not readable"
        return 1
    fi
    
    return 0
}

# Function: Create backup directory
create_backup_dir() {
    if [ ! -d "$BACKUP_DIR" ]; then
        echo "Creating backup directory: $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
        
        if [ $? -ne 0 ]; then
            echo "Error: Failed to create backup directory"
            return 1
        fi
    fi
    return 0
}

# Function: Create backup
create_backup() {
    echo "Starting backup..."
    echo "Source: $SOURCE_DIR"
    echo "Destination: ${BACKUP_DIR}/${BACKUP_FILE}"
    
    tar -czf "${BACKUP_DIR}/${BACKUP_FILE}" "$SOURCE_DIR" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo "Backup successful"
        return 0
    else
        echo "Error: Backup failed"
        return 1
    fi
}

# Function: Get backup size
get_backup_size() {
    du -h "${BACKUP_DIR}/${BACKUP_FILE}" | awk '{print $1}'
}

# Function: Remove old backups
cleanup_old_backups() {
    echo "Cleaning up old backups (keeping last $MAX_BACKUPS)..."
    
    cd "$BACKUP_DIR"
    
    BACKUP_COUNT=$(ls -1 backup_*.tar.gz 2>/dev/null | wc -l)
    
    if [ $BACKUP_COUNT -gt $MAX_BACKUPS ]; then
        REMOVE_COUNT=$((BACKUP_COUNT - MAX_BACKUPS))
        ls -1t backup_*.tar.gz | tail -n $REMOVE_COUNT | while read old_backup
        do
            echo "Removing: $old_backup"
            rm -f "$old_backup"
        done
    fi
}

# Function: Display backup info
display_info() {
    echo ""
    echo "=========================================="
    echo "BACKUP SUMMARY"
    echo "=========================================="
    echo "Backup File: $BACKUP_FILE"
    echo "Backup Size: $(get_backup_size)"
    echo "Location: ${BACKUP_DIR}/${BACKUP_FILE}"
    echo "Timestamp: $(date)"
    echo ""
    echo "Recent Backups:"
    ls -1t "${BACKUP_DIR}"/backup_*.tar.gz 2>/dev/null | head -5
    echo "=========================================="
}

# Main script execution
main() {
    echo "=========================================="
    echo "BACKUP SCRIPT"
    echo "=========================================="
    echo ""
    
    # Check source directory
    if ! check_source; then
        exit 1
    fi
    
    # Create backup directory
    if ! create_backup_dir; then
        exit 1
    fi
    
    # Create backup
    if ! create_backup; then
        exit 1
    fi
    
    # Cleanup old backups
    cleanup_old_backups
    
    # Display summary
    display_info
    
    exit 0
}

# Run main function
main

