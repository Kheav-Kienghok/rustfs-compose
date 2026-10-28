#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"
set -a; . ./.env; set +a
trap 'docker compose start rustfs' EXIT
docker compose stop rustfs
tar -czf "backups/rustfs-$(date +%F).tar.gz" data .env docker-compose.yml
find backups -name 'rustfs-*.tar.gz' -mtime +"${BACKUP_KEEP_DAYS:-28}" -delete
