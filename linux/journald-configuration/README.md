> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — Journald Configuration

Configure systemd-journald for log retention, compression, and persistent storage.

## Playbook

`playbook.yml`

## Variables (`vars/main.yml`)

| Variable | Description | Default |
|----------|-------------|---------|
| `target_hosts` | Inventory host or group | `all` |
| `journald_storage` | Storage mode: `auto`, `persistent`, `volatile`, `none` | `persistent` |
| `journald_compress` | Compress log objects larger than 512 bytes | `true` |
| `journald_system_max_use` | Max disk space for logs | `500M` |
| `journald_system_keep_free` | Min free disk space to keep | `1G` |
| `journald_max_file_size` | Max individual journal file size | `50M` |
| `journald_max_retention_sec` | Max log retention time | `0` (unlimited) |
| `journald_forward_to_syslog` | Forward messages to syslog | `false` |
| `journald_rate_limit_interval` | Rate limiting window | `30s` |
| `journald_rate_limit_burst` | Messages per rate limit interval | `10000` |

## Usage

```bash
ansible-playbook -i inventory/hosts.ini linux/journald-configuration/playbook.yml \
  -e target_hosts=all
```

## Notes

- `persistent` storage writes logs to `/var/log/journal/` which survives reboots.
- `volatile` stores logs in memory (`/run/log/journal/`) only — lost on reboot.
- `auto` uses persistent if `/var/log/journal/` exists, otherwise volatile.
- Useful commands: `journalctl --disk-usage`, `journalctl --vacuum-size=500M`, `journalctl -f` (follow)
