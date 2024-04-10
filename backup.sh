#!/bin/bash

# ANSI color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Initialize variables
ENCRYPTION_PASSWORD=""
SOURCE_DIRS=""
BACKUP_ROOT_DIR=""
LOG_FILE="$(pwd)/backup.log" # Default log file location

# Print messages with timestamp
log_message() {
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Display usage information and log it with colors
usage() {
    log_message "${RED}Usage: $0 -e <encryption_password> -r <source_dir1,source_dir2,...> -d <backup_root_dir> [-l <log_file>]${NC}"
    log_message "Options:"
    log_message "  ${GREEN}-e    Encryption password for securing backup files.${NC}"
    log_message "  ${GREEN}-r    Comma-separated list of directories or files to backup.${NC}"
    log_message "  ${GREEN}-d    Destination directory for storing backup files.${NC}"
    log_message "  ${YELLOW}-l    Optional: Log file location. Default is ./backup.log.${NC}"
    exit 1
}

# Parse command-line options
while getopts "e:r:d:l:" opt; do
    case "${opt}" in
        e)
            ENCRYPTION_PASSWORD="${OPTARG}"
            ;;
        r)
            IFS=',' read -r -a SOURCE_ARRAY <<< "${OPTARG}"
            ;;
        d)
            BACKUP_ROOT_DIR="${OPTARG}"
            ;;
        l)
            LOG_FILE="${OPTARG}"
            ;;
        *)
            usage
            ;;
    esac
done

# Validate required options and log it
if [ -z "${ENCRYPTION_PASSWORD}" ] || [ -z "${SOURCE_DIRS}" ] || [ -z "${BACKUP_ROOT_DIR}" ]; then
    echo -e "${RED}2024-04-10 03:13:38 - Error: All options -e, -r, and -d are required.${NC}"
    usage
fi

# Configuration for backup
DB_USER="root"
DB_PASSWORD="password"
DB_NAME="maxmind_crm-cim-ori"
DB_BACKUP_DIR="${BACKUP_ROOT_DIR}"
DATE=$(date +%Y-%m-%d-%H%M%S)
SERVER_BACKUP_FILE="${BACKUP_ROOT_DIR}/server-backup-${DATE}.tar.gz.enc"
DATABASE_BACKUP_FILE="${DB_BACKUP_DIR}/db-backup-${DATE}.sql.gz.enc"

# Perform server backup and encrypt
log_message "Starting server data backup..."
if tar -czf - "${SOURCE_ARRAY[@]}" | openssl enc -aes-256-cbc -salt -out "${SERVER_BACKUP_FILE}" -pass pass:"${ENCRYPTION_PASSWORD}"; then
    log_message "Server data backup completed: ${SERVER_BACKUP_FILE}"
else
    log_message "Error during server data backup."
fi

# Perform database backup, compress, and encrypt
log_message "Starting database backup..."
if mysqldump -u "${DB_USER}" -p"${DB_PASSWORD}" "${DB_NAME}" | gzip | openssl enc -aes-256-cbc -salt -out "${DATABASE_BACKUP_FILE}" -pass pass:"${ENCRYPTION_PASSWORD}"; then
    log_message "Database backup completed: ${DATABASE_BACKUP_FILE}"
else
    log_message "Error during database backup."
fi

log_message "Backup process completed successfully."
