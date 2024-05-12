# Automate Ghost Content & Database Backup to Remote Storage via Shell Script

This script automates the backup process for a Ghost blogging platform instance, including content and database backups, and syncing with remote storage. It's designed to be run on a Linux server where the Ghost instance is hosted.

## Usage
1. Clone the repository to your server.
2. Modify the script and replace placeholder values with appropriate paths and credentials.
3. Run `chmod u+x 
4. Run the script using Bash: `bash ghost_backup_script.sh`.

## Prerequisites
- Ghost blogging platform instance running in a Docker container.
- rclone installed and configured for remote storage syncing.
- Docker container name for the MySQL database.
- Slack webhook URL for receiving notifications.

## Contributing
Contributions are welcome! Feel free to fork the repository and submit pull requests with improvements or new features.









This script automates the backup process for a Ghost blogging platform instance. It ensures that both content and database data are securely backed up and synchronized with remote storage. Here's a breakdown of its functionalities:

1. **Setting Variables**: The script defines various variables such as directories for content and database backups, Slack webhook URL for notifications, Docker container name, maximum number of backups to retain, and remote storage destination.

2. **Functions**: 
    - `get_current_time_ist()`: Retrieves the current time in Indian Standard Time (IST).
    - `send_slack_notification()`: Sends notifications to a Slack channel.

3. **Directory Existence Check**: Checks if the specified content and database destination directories exist. If not, it sends a notification and exits the script.

4. **Initial Notification**: Sends a notification to Slack indicating the start of the backup process along with the current date and time in IST.

5. **Content Backup**: Archives the content directory into a tar.gz file with a timestamp in the filename. It notifies about the success or failure of the content backup and deletes old content backups if the maximum number of backups has been exceeded.

6. **Database Backup**: Performs a database backup using `mysqldump` command inside the Docker container. It notifies about the success or failure of the database backup and deletes old database backups if the maximum number of backups has been exceeded.

7. **Sync with Remote Storage**: Initiates a sync with remote storage using rclone. It sends notifications about the start and completion of the sync process.

8. **Final Notification**: Sends a final notification indicating whether both content and database backups were successful or not.

## Example Use Cases

- **Scheduled Backups**: Set up a cron job to run this script regularly to ensure periodic backups of the Ghost instance.
- **Disaster Recovery**: Use the backups created by this script for disaster recovery in case of data loss or server failure.
- **Automated Notifications**: Receive real-time notifications via Slack about the status of the backup process, ensuring timely awareness of any issues or failures.

## Prerequisites

- **Ghost Blogging Platform**: Ensure that you have a Ghost instance running in a Docker container.
- **rclone**: Install and configure rclone for remote storage syncing.
- **Docker Container Name**: Obtain the name of the Docker container running the MySQL database for the Ghost instance.
- **Slack Webhook URL**: Set up a Slack webhook URL to receive notifications.

## Contributing

Contributions are welcome! If you have any improvements or new features to suggest, feel free to fork the repository and submit pull requests.

This detailed explanation provides insights into the script's functionalities, example use cases, prerequisites, and an invitation for contributions. Let me know if you need further clarification or adjustments!
