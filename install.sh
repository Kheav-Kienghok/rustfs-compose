#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"
DIR=$(pwd)
mkdir -p data logs backups
chown -R 10001:10001 data logs
chmod 600 .env
chmod 700 backup.sh restore.sh
docker compose up -d
echo "0 2 * * 0 root $DIR/backup.sh >> /var/log/rustfs-backup.log 2>&1" > /etc/cron.d/rustfs-backup
chmod 644 /etc/cron.d/rustfs-backup
