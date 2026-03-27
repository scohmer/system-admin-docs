> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — Log Management

Configure rsyslog remote forwarding and logrotate policies across managed hosts using Ansible.

## Playbook

`playbook.yml`

## Variables

Populate `vars/main.yml` before running.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `target_hosts` | string | Yes | — | Ansible inventory group or host |
| `rsyslog_forward_enabled` | bool | No | `false` | Forward logs to a remote syslog server |
| `rsyslog_remote_host` | string | No | — | Remote syslog server hostname or IP |
| `rsyslog_remote_port` | int | No | `514` | Remote syslog port |
| `rsyslog_remote_protocol` | string | No | `udp` | `tcp` or `udp` |
| `logrotate_configs` | list | No | `[]` | Custom logrotate configurations (see structure below) |

### `logrotate_configs` item structure

```yaml
logrotate_configs:
  - name: myapp                   # Config file name (written to /etc/logrotate.d/myapp)
    path: /var/log/myapp/*.log    # Glob pattern for log files
    frequency: daily              # daily, weekly, monthly
    rotate: 14                    # Number of rotated files to keep
    compress: true                # Compress rotated files with gzip
    delaycompress: true           # Compress previous rotation, not current
    missingok: true               # Don't error if log file is missing
    notifempty: true              # Don't rotate if empty
    create: "0640 root adm"       # Permissions for new log file (optional)
    postrotate: |                 # Commands to run after rotation (optional)
      systemctl reload myapp
```

## Usage

```bash
# Preview
ansible-playbook -i /etc/ansible/hosts playbook.yml \
  -e @vars/main.yml --check

# Apply
ansible-playbook -i /etc/ansible/hosts playbook.yml \
  -e @vars/main.yml
```

## Notes

- rsyslog forwarding sends copies of log messages — original local logs are retained.
- Use TCP (`rsyslog_remote_protocol: tcp`) for reliable log delivery to a SIEM or central log server.
- Logrotate runs daily via cron (`/etc/cron.daily/logrotate`) by default on most distributions.
- The `postrotate` script runs after rotation. Use it to signal the application to re-open its log file handle.
- Journal logs (journald) are separate from rsyslog. To forward journald to a remote host, configure `journald.conf` with `ForwardToSyslog=yes`.
