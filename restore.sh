#!/usr/bin/env bash
set -euo pipefail
[ $# -eq 1 ] || { echo "usage: $0 backups/rustfs-YYYY-MM-DD.tar.gz"; exit 1; }
cd "$(dirname "$(readlink -f "$0")")"
docker compose down
rm -rf data
tar -xzf "$1"
chown -R 10001:10001 data logs
docker compose up -d
