# Backup

This Bash script provides a robust solution for backing up server directories and a MySQL database. It reads configuration settings from an external file (`backup.conf`), performs the backups, logs the process, and securely encrypts the backup files.

## Prerequisites

Before you begin, ensure you have the following installed and configured on your system:
- **Bash Shell**: Available on Linux and UNIX-like operating systems.
- **MySQL Server**: Needed for database backups.
- **OpenSSL**: Required for encrypting the backup files.
- **tar**: Utility for archiving directories.
- **Access Permissions**: Ensure the script has the necessary permissions to access the directories and databases you intend to back up.

## Configuration

Set up your backup configuration by editing the `backup.conf` file. Adjust the file paths, database credentials, and other settings according to your specific needs.

### Configuration File Template

```ini
# Database settings
DB_USER=root
DB_PASSWORD=password
DB_NAME=my_database

# Backup settings
ENCRYPTION_PASSWORD=my_secure_password
BACKUP_ROOT_DIR=/path/to/backup
SOURCE_DIRS=/home/user/data,/home/user/docs

# Log file location
LOG_FILE=/path/to/backup.log
```

## Installation

1. **Download the Script**: Clone this repository or directly download the `backup.sh` and `backup.conf` files to your server.

2. **Set File Permissions**: Secure the script and configuration file:
   ```bash
   chmod 700 backup.sh
   chmod 600 backup.conf
   ```

3. **Configure the `backup.conf` File**: Ensure the configuration file is placed either in the same directory as `backup.sh` or specify its location in the script.

## Usage

Execute the script with the following command:

```bash
./backup.sh
```

### Automate with Cron

To automate the backup process, add a cron job:

```bash
crontab -e
```

Insert the following line to run the backup daily at 2 AM:

```cron
0 2 * * * /path/to/backup.sh > /dev/null 2>&1
```

## Security Considerations

- **Protect Sensitive Data**: Ensure the `backup.conf` is kept secure, as it contains sensitive information.
- **Restrict Access**: Limit access to the script, configuration file, and backup data to trusted users only.
- **Regular Testing**: Frequently test the backup and restore process to confirm the integrity and recoverability of the data.

## Monitoring and Logs

Monitor the backup process through the log file specified in `backup.conf`. Check this file regularly for any errors or confirmations of successful backups:

```bash
cat /path/to/backup.log
```

## Support

For any issues, suggestions, or contributions, please contact the repository maintainer or submit an issue/pull request to the project's GitHub page.
