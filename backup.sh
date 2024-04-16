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

# Initialize variables
ENCRYPTION_PASSWORD=""
SOURCE_DIRS=""
BACKUP_ROOT_DIR=""
LOG_FILE="$(pwd)/backup.log" # Default log file location

# Enhanced logging functions
log_info() {
    echo -e "${GREEN}$(date '+%Y-%m-%d %H:%M:%S') - INFO - $1${NC}" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}$(date '+%Y-%m-%d %H:%M:%S') - ERROR - $1${NC}" | tee -a "$LOG_FILE"
    exit 1
}

# Display usage information and exit
usage() {
    log_info "${RED}Usage: $0 -e <encryption_password> -r <source_dir1,source_dir2,...> -d <backup_root_dir> [-l <log_file>]${NC}"
    log_info "Options:"
    log_info "  ${GREEN}-e    Encryption password for securing backup files.${NC}"
    log_info "  ${GREEN}-r    Comma-separated list of directories or files to backup.${NC}"
    log_info "  ${GREEN}-d    Destination directory for storing backup files.${NC}"
    log_info "  ${YELLOW}-l    Optional: Log file location. Default is ./backup.log.${NC}"
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

# Validate required options
[ -z "${ENCRYPTION_PASSWORD}" ] && log_error "Encryption password not set."
[ -z "${SOURCE_DIRS}" ] || [ -z "${BACKUP_ROOT_DIR}" ] && log_error "Source directories or backup root directory not set."

# Validate environment
for dir in "${SOURCE_ARRAY[@]}"; do
    [ ! -d "$dir" ] && log_error "Directory $dir does not exist."
    [ ! -r "$dir" ] && log_error "Directory $dir is not readable."
done
[ ! -w "${BACKUP_ROOT_DIR}" ] && log_error "Backup root directory is not writable."

# Configuration for backup
DB_USER="root"
DB_PASSWORD="password"
DB_NAME="maxmind_crm-cim-ori"
DB_BACKUP_DIR="${BACKUP_ROOT_DIR}"
DATE=$(date +%Y-%m-%d-%H%M%S)
SERVER_BACKUP_FILE="${BACKUP_ROOT_DIR}/server-backup-${DATE}.tar.gz.enc"
DATABASE_BACKUP_FILE="${DB_BACKUP_DIR}/db-backup-${DATE}.sql.gz.enc"

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
