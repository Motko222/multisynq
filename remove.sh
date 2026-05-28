#!/bin/bash
set -e

SCRIPTS_DIR="/root/scripts/multisynq"
BACKUP_DIR="/root/backup/scripts/multisynq"
SERVICE="multisynq"
CONTAINER="synchronizer-cli"
INFLUX_SCRIPT="/root/scripts/system/influx-delete-id.sh"

source $SCRIPTS_DIR/env
INFLUX_ID="$SERVICE-$ID"

echo "=== Removing $SERVICE (influx ID: $INFLUX_ID) ==="

echo "--- Stopping service ---"
systemctl stop $SERVICE && echo "stopped"

echo "--- Disabling service ---"
systemctl disable $SERVICE && echo "disabled"

echo "--- Removing service file ---"
rm -f /etc/systemd/system/$SERVICE.service
systemctl daemon-reload && echo "daemon reloaded"

echo "--- Stopping Docker container ---"
docker stop $CONTAINER 2>/dev/null && docker rm $CONTAINER 2>/dev/null && echo "container removed" || echo "container already gone"

echo "--- Backing up scripts (no .git) ---"
mkdir -p "$BACKUP_DIR"
rsync -a --exclude='.git' "$SCRIPTS_DIR/" "$BACKUP_DIR/" && echo "backed up to $BACKUP_DIR"

echo "--- Removing scripts directory ---"
rm -rf "$SCRIPTS_DIR" && echo "removed $SCRIPTS_DIR"

echo "--- Removing from monitoring ---"
bash "$INFLUX_SCRIPT" "$INFLUX_ID" && echo "removed from influx"

echo ""
echo "=== Done. $SERVICE removed. ==="
