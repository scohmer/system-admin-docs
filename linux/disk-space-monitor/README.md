# Linux Disk Space Monitor

> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

## Overview

Checks disk space across all managed hosts and alerts when usage exceeds configured thresholds. Alert reports are written to the Ansible controller and optionally sent by email. Hosts that breach the ALERT threshold are marked as failed in Ansible output, making it easy to detect in CI/CD or cron job logs.

## Requirements

- Ansible 2.14+
- `community.general` collection (for email alerts)
- `mailutils` on the controller (for email alerts)

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `target_hosts` | `all` | Inventory group or host pattern to check |
| `disk_warn_percent` | `80` | Usage % that triggers a WARN |
| `disk_alert_percent` | `90` | Usage % that triggers an ALERT and fails the play |
| `disk_alert_log_dir` | `/var/log/ansible/disk-alerts` | Controller directory for alert logs |
| `disk_email_alert` | `false` | Send email alerts when ALERT threshold is breached |
| `disk_email_to` | `ops@example.com` | Email recipient for alerts |
| `disk_exclude_types` | tmpfs, devtmpfs, overlay, squashfs | Filesystem types excluded from checks |

## Usage

```bash
# Run an ad-hoc check against all hosts
ansible-playbook -i inventory/hosts.ini linux/disk-space-monitor/playbook.yml

# Check only web servers with a lower warning threshold
ansible-playbook -i inventory/hosts.ini linux/disk-space-monitor/playbook.yml \
  -l webservers \
  -e disk_warn_percent=70 \
  -e disk_alert_percent=85

# Enable email alerts
ansible-playbook -i inventory/hosts.ini linux/disk-space-monitor/playbook.yml \
  -e disk_email_alert=true \
  -e disk_email_to=ops@example.com

# Schedule daily at 6am on the Ansible controller
# 0 6 * * * ansible-playbook -i /etc/ansible/hosts linux/disk-space-monitor/playbook.yml
```

## Alert Behavior

- **WARN**: Logged to controller report file and displayed in Ansible output
- **ALERT**: Logged to report file, optionally emailed, and the play is **failed** for that host so it appears as a failure in cron/CI output
- Report files are written to `{{ disk_alert_log_dir }}/disk-report-<date>.log`

## Notes

- Pairs with `linux/node-exporter/` for continuous Prometheus-based disk monitoring with Grafana alerting
- For immediate notification without waiting for the scheduled run, configure alertmanager rules on a Prometheus stack
