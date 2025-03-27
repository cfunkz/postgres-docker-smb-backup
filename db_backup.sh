#!/bin/bash

# Docker container and PostgreSQL details
CONTAINER_NAME="docker_container_id"
PG_USER="postgres_user" 
PG_DB="postgres_database"
PG_PORT=5432
BACKUP_FILE="/tmp/backup_$(date +'%Y%m%d%H%M').sql"

# NAS SMB details
NAS_SHARE="//192.168.1.5/Database_Backup"  # Point to the Network Access Storage point
NAS_USER="smb_user" 
NAS_PASSWORD="smb_password"

# Step 1: Create the backup
echo "Creating PostgreSQL backup from Docker..."
docker exec -t $CONTAINER_NAME pg_dump -U $PG_USER -h localhost -p $PG_PORT $PG_DB > $BACKUP_FILE

# Check if the backup was created
if [ ! -f "$BACKUP_FILE" ]; then
    echo "Backup failed!"
    exit 1
fi

# Step 2: Upload the backup to NAS using smbclient
echo "Uploading backup to NAS..."
echo "Accessing Database..."
echo $NAS_PASSWORD | smbclient $NAS_SHARE -U $NAS_USER -c "put $BACKUP_FILE $(basename $BACKUP_FILE)"

# Check if upload was successful
if [ $? -eq 0 ]; then
    echo "Backup uploaded successfully to NAS."
else
    echo "Failed to upload to NAS."
    exit 1
fi

# Clean up local backup file
rm -f $BACKUP_FILE

echo "Backup process completed."
