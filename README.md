# RustFS

S3-compatible object storage ([rustfs/rustfs](https://github.com/rustfs/rustfs)) on Docker Compose with a weekly backup cron.

| Port | Service |
|------|---------|
| 9000 | S3 API |
| 9001 | Web console |

## Install

Extract on the data disk so `data/`, `logs/` and `backups/` stay off the OS disk:

```bash
sudo unzip rustfs.zip -d /mnt/data && cd /mnt/data/rustfs && sudo ./install.sh
```

Creates `data/` and `logs/` owned by `10001:10001` (the container user), starts the stack, and installs `/etc/cron.d/rustfs-backup`.

Log in at `http://<host>:9001` with `RUSTFS_ACCESS_KEY` / `RUSTFS_SECRET_KEY` from `.env`.

## Config (`.env`)

| Variable | Default | Purpose |
|----------|---------|---------|
| `RUSTFS_ACCESS_KEY` | `admin` | Username |
| `RUSTFS_SECRET_KEY` | generated | Password |
| `RUSTFS_VERSION` | `latest` | Image tag, pin it once stable |
| `BACKUP_KEEP_DAYS` | `28` | Backup retention |

After changing values: `docker compose up -d`.

## Backup

`backup.sh` runs every Sunday 02:00. It stops the container, writes `backups/rustfs-YYYY-MM-DD.tar.gz` (data, `.env`, compose file), starts the container again, and prunes old archives. Expect a short downtime. Log: `/var/log/rustfs-backup.log`.

Run manually:

```bash
sudo ./backup.sh
```

Backups sit on the same disk as the data. Copy `backups/` to another host or bucket for disk-loss protection.

## Restore

```bash
sudo ./restore.sh backups/rustfs-YYYY-MM-DD.tar.gz
```

## Domain / reverse proxy

`examples/nginx.conf.example` is a reference only (S3 API and console on two hostnames). Copy it to your proxy host, replace `s3.example.com`, `console.example.com` and `RUSTFS_HOST`, then add TLS (certbot or your existing certs).

Keep `client_max_body_size 0` and `proxy_request_buffering off` for large uploads, and `Host $http_host` so S3 signatures stay valid. Allow ports 9000 and 9001 only from the proxy host (firewall).

## Notes

- Backups share the data disk: keep room for the data plus about two archives, and lower `BACKUP_KEEP_DAYS` if space is tight.
- Backups contain `.env` (credentials). Keep `backups/` private.
- Put TLS in front (nginx or similar) before exposing outside the LAN.
