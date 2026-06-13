#!/bin/bash

LOG_DIR = "$1"
BACKUP_DIR = "$2"
LOCK_FILE = "/tmp/backup.lock"

# Check arguments
if [ "$#" -ne 2 ] || [ ! -d "$LOG_DIR" ] || [ ! -d "$BACKUP_DIR" ]; then
	echo "Usage: ./backup.sh <log_dir><backup_dir>"
	exit 1
fi

# Check lock file
if [ -f "$LOCK_FILE" ]; then
	echo "Backup already running"
	exit 1
fi

# Create lock file
touch "$LOCK_FILE"

# Remove lock file when script finished
trap 'rm -f "$LOCK_FILE"' EXIT

# Create archive name with date and time
DATE = $(date + "%Y-%m-%d_%H-%M")
ARCHIVE_NAME = "logs_backup_${DATE}.tar.gz"
ARCHIVE_PATH= "$(realpath "$BACKUP_DIR")/$ARCHIVE_NAME"

# Create backup archive
tar -czf "$ARCHIVE_PATH" -C "$LOG_DIR" .

# Check result

if [ "$?" -ne 0 ]; then
	echo "Backup failed"
	exit 2
fi

echo "Backup created: $ARCHIVE_PATH"





