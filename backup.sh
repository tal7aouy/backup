#!/bin/bash

# Bash options for safety
set -o errexit
set -o nounset
set -o pipefail

# ANSI color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Load configuration from the backup.conf file
CONFIG_FILE="backup.conf"
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}Configuration file not found!${NC}"
    exit 1
fi
source "$CONFIG_FILE"

# Enhanced logging functions
log_info() {
    echo -e "${GREEN}$(date '+%Y-%m-%d %H:%M:%S') - INFO - $1${NC}" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}$(date '+%Y-%m-%d %H:%M:%S') - ERROR - $1${NC}" | tee -a "$LOG_FILE"
    exit 1
}

# Validate environment and input
IFS=',' read -r -a SOURCE_ARRAY <<< "$SOURCE_DIRS"
for dir in "${SOURCE_ARRAY[@]}"; do
    [ ! -d "$dir" ] && log_error "Directory $dir does not exist."
    [ ! -r "$dir" ] && log_error "Directory $dir is not readable."
done
[ ! -w "$BACKUP_ROOT_DIR" ] && log_error "Backup root directory is not writable."

# Backup file naming
DATE=$(date +%Y-%m-%d-%H%M%S)
SERVER_BACKUP_FILE="${BACKUP_ROOT_DIR}/server-backup-${DATE}.tar.gz.enc"
DATABASE_BACKUP_FILE="${BACKUP_ROOT_DIR}/db-backup-${DATE}.sql.gz.enc"

# Perform server backup and encrypt
log_info "Starting server data backup..."
if tar -czf - "${SOURCE_ARRAY[@]}" | openssl enc -aes-256-cbc -salt -out "${SERVER_BACKUP_FILE}" -pass pass:"${ENCRYPTION_PASSWORD}"; then
    log_info "Server data backup completed: ${SERVER_BACKUP_FILE}"
else
    log_error "Error during server data backup."
fi

# Perform database backup, compress, and encrypt
log_info "Starting database backup..."
if mysqldump -u "${DB_USER}" -p"${DB_PASSWORD}" "${DB_NAME}" | gzip | openssl enc -aes-256-cbc -salt -out "${DATABASE_BACKUP_FILE}" -pass pass:"${ENCRYPTION_PASSWORD}"; then
    log_info "Database backup completed: ${DATABASE_BACKUP_FILE}"
else
    log_error "Error during database backup."
fi

log_info "Backup process completed successfully."
