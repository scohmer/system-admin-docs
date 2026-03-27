> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — Rsync Backup

Configure automated rsync-based backups of directories to a local or remote destination.

## Playbook

`playbook.yml`

## Variables (`vars/main.yml`)

| Variable | Description | Default |
|----------|-------------|---------|
| `target_hosts` | Inventory host or group | `all` |
| `rsync_backup_jobs` | List of backup job definitions | see vars |
| `rsync_log_dir` | Directory for backup logs | `/var/log/rsync-backup` |

### Backup job fields

| Field | Description |
|-------|-------------|
| `name` | Job name (used in script and cron entry) |
| `src` | Source path to back up |
| `dest` | Destination path (local or `user@host:/path` for remote) |
| `options` | rsync options (default: `-avz --delete`) |
| `schedule` | Cron schedule (default: daily at 2am) |
| `ssh_key` | Path to SSH key for remote backups |
| `exclude` | List of patterns to exclude |

## Usage

```bash
ansible-playbook -i inventory/hosts.ini linux/rsync-backup/playbook.yml \
  -e target_hosts=all
```

## Notes

- Remote backups require SSH key-based authentication to the backup destination.
- `--delete` removes files from the destination that no longer exist in the source.
- For incremental/versioned backups, use `--link-dest` with dated subdirectories (shown in vars example).
- Backup logs are rotated automatically via logrotate.
