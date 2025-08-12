#!/bin/bash
# Backup all infrastructure projects

BACKUP_DIR="/backup/infrastructure"
DATE=$(date +%Y%m%d_%H%M%S)

echo "Starting infrastructure backup: $DATE"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Backup each project
for project in proxmox-management lxc-templates cloudflare-tunnels; do
    echo "Backing up $project..."
    tar -czf "$BACKUP_DIR/${project}_${DATE}.tar.gz" -C .. "$project"
done

echo "Backup complete!"
echo "Backups saved to: $BACKUP_DIR"
