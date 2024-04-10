# Backup

This script provides a flexible and secure way to backup server data and databases, with features including encryption, logging, and customizable backup sources and destinations.

## Features

- **Encryption**: Secure your backups with AES-256 encryption using OpenSSL.
- **Logging**: Detailed logging for each backup process, including timestamps and success or failure statuses.
- **Customization**: Easily specify backup sources, destinations, and log file locations through command-line options.

## Requirements

- OpenSSL for encryption.
- `mysqldump` for database backups (typically comes with MySQL).
- Access to the server and database with sufficient permissions to perform backups.

## Usage

```bash
./backup.sh -e <encryption_password> -r <source_dir1,source_dir2,...> -d <backup_root_dir> [-l <log_file>]
```

### Options

- `-e`: Encryption password for securing backup files. **Required**
- `-r`: Comma-separated list of directories or files to backup. **Required**
- `-d`: Destination directory for storing backup files. **Required**
- `-l`: Optional log file location. Default is `./backup.log`.

### Examples

Backup `/var/www/html` and `/home/user/data` to `/path/to/backup`, with encryption and custom log file:

```bash
./backup.sh -e myStrongPassword -r /var/www/html,/home/user/data -d /path/to/backup -l /path/to/mylog.log
```

## Logging

The script generates detailed logs for each backup operation, including errors. By default, logs are stored in `./backup.log` in the current directory, but you can specify a different location using the `-l` option.

## Encryption

Backups are encrypted using AES-256-CBC via OpenSSL. Ensure you keep the encryption password safe; without it, you cannot decrypt your backups.

## Troubleshooting

- Ensure you have the necessary permissions to access and read the source directories and write to the backup destination.
- For database backups, verify that `mysqldump` is installed and that the provided database user credentials have sufficient rights.
- If logs show `Error during encryption`, check that OpenSSL is installed and that the encryption password is correctly entered.

## Contributing

Contributions to this script are welcome. Please fork the repository, make your changes, and submit a pull request.

