#!/bin/bash

# Set variables
CONTENT_SOURCE_DIR="PLACE_YOUR_CONTENT_SOURCE_DIRECTORY_HERE"
CONTENT_DEST_DIR="PLACE_YOUR_CONTENT_DESTINATION_DIRECTORY_HERE"
DATABASE_DEST_DIR="PLACE_YOUR_DATABASE_DESTINATION_DIRECTORY_HERE"
SLACK_WEBHOOK_URL="PLACE_YOUR_SLACK_WEBHOOK_URL_HERE"
DOCKER_CONTAINER_NAME="PLACE_YOUR_DOCKER_CONTAINER_NAME_HERE"
MAX_BACKUPS=7
REMOTE_STORAGE="PLACE_YOUR_REMOTE_STORAGE_DESTINATION_HERE"
RCLONE_SYNC="PLACE_YOUR_RCLONE_SYNC_DIRECTORY_HERE"

# Function to get current time in IST
get_current_time_ist() {
  local current_time_ist
  current_time_ist=$(TZ="Asia/Kolkata" date +"%Y-%m-%d %H:%M:%S %Z")
  echo "$current_time_ist"
}

# Function to send Slack notification
send_slack_notification() {
  local message=$1
  curl -X POST -H 'Content-type: application/json' --data "{\"text\": \"$message\"}" "$SLACK_WEBHOOK_URL"
}

# Check existence of directories
for dir in "$CONTENT_DEST_DIR" "$DATABASE_DEST_DIR"; do
  if [ ! -d "$dir" ]; then
    echo "❌ Directory $dir does not exist!"
    send_slack_notification "❌ Backup failed: Directory $dir does not exist! ❗"
    exit 1
  fi
done

# Send initial Slack notification with current date and time in IST
send_slack_notification "🚀 Backup process initiated at $(get_current_time_ist) (IST)! ⏰"

# Backup content
echo -e "\n📁 Backing up content..."
CONTENT_BACKUP_NAME="content-$(date +%Y-%m-%d-%H-%M-%S).tar.gz"
echo "ℹ️ New content backup: $CONTENT_BACKUP_NAME at $(get_current_time_ist)"
tar -czpf "${CONTENT_DEST_DIR}/${CONTENT_BACKUP_NAME}" -C "${CONTENT_SOURCE_DIR}" . --preserve-permissions
CONTENT_BACKUP_SUCCESS=$?

if [ $CONTENT_BACKUP_SUCCESS -ne 0 ]; then
  echo "❌ Content backup failed! ❗"
  send_slack_notification "❌ Content backup failed at $(get_current_time_ist)! ⚠️"
  exit 1
fi

echo "✅ Content backup completed successfully at $(get_current_time_ist). 📦"
send_slack_notification "✅ Content backup completed successfully: $CONTENT_BACKUP_NAME at $(get_current_time_ist). ✅"

# Delete old content backups
echo -e "\n🗑 Cleaning up old content backups..."
OLD_CONTENT_BACKUPS=$(ls -t "${CONTENT_DEST_DIR}"/content-*.tar.gz | tail -n +$(($MAX_BACKUPS + 1)))
for backup in $OLD_CONTENT_BACKUPS; do
  echo "❌ Deleting old content backup: $(basename $backup) at $(get_current_time_ist) 🗑"
  rm "$backup"
  send_slack_notification "❌ Deleted old content backup: $(basename $backup) at $(get_current_time_ist) 🗑"
done

# Backup database
echo -e "\n🗄️ Backing up database..."
DATABASE_BACKUP_NAME="ghost-database-$(date +%Y-%m-%d-%H-%M-%S).sql"
echo "ℹ️ New database backup: $DATABASE_BACKUP_NAME at $(get_current_time_ist)"
docker exec "$DOCKER_CONTAINER_NAME" sh -c 'exec mysqldump --all-databases -uroot -p"$MYSQL_ROOT_PASSWORD"' > "${DATABASE_DEST_DIR}/${DATABASE_BACKUP_NAME}"
DATABASE_BACKUP_SUCCESS=$?

if [ $DATABASE_BACKUP_SUCCESS -ne 0 ]; then
  echo "❌ Database backup failed! ❗"
  send_slack_notification "❌ Database backup failed at $(get_current_time_ist)! ⚠️"
  exit 1
fi

echo "✅ Database backup completed successfully at $(get_current_time_ist). 🗄️"
send_slack_notification "✅ Database backup completed successfully: $DATABASE_BACKUP_NAME at $(get_current_time_ist). ✅"

# Delete old database backups
echo -e "\n🗑 Cleaning up old database backups..."
OLD_DATABASE_BACKUPS=$(ls -t "${DATABASE_DEST_DIR}"/ghost-database-*.sql | tail -n +$(($MAX_BACKUPS + 1)))
for backup in $OLD_DATABASE_BACKUPS; do
  echo "❌ Deleting old database backup: $(basename $backup) at $(get_current_time_ist) 🗑"
  rm "$backup"
  send_slack_notification "❌ Deleted old database backup: $(basename $backup) at $(get_current_time_ist) 🗑"
done

# Send Slack notification for starting sync
send_slack_notification "🔄 Syncing with remote storage started at $(get_current_time_ist) (IST)... ⏳"
# Sync with remote storage using rclone
rclone sync "${RCLONE_SYNC}" "${REMOTE_STORAGE}" --progress
# Send Slack notification for finishing sync
send_slack_notification "🔄 Syncing with remote storage completed at $(get_current_time_ist) (IST)! ✅"

# Send final Slack notification indicating whether both backups were successful or not
if [ $CONTENT_BACKUP_SUCCESS -eq 0 ] && [ $DATABASE_BACKUP_SUCCESS -eq 0 ]; then
  send_slack_notification "🚀 Backup process completed successfully at $(get_current_time_ist)! All data backed up and synced! 🎉"
else
  send_slack_notification "❌ Backup process failed at $(get_current_time_ist)! 😞"
fi
