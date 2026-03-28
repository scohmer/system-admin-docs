# Linux Service Health Check

> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

## Overview

Verifies that required services are running across all managed hosts. Optionally restarts failed services. Alert reports are written to the Ansible controller and optionally emailed. Hosts with services still down after restart attempts are marked as failed in Ansible output.

## Requirements

- Ansible 2.14+
- `community.general` collection (for email alerts)

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `target_hosts` | `all` | Inventory group or host pattern |
| `required_services` | `[]` | List of services to monitor (see structure below) |
| `service_alert_log_dir` | `/var/log/ansible/service-alerts` | Controller directory for alert logs |
| `service_email_alert` | `false` | Send email on service failure |
| `service_email_to` | `ops@example.com` | Email recipient |

### `required_services` Structure

```yaml
required_services:
  - name: nginx                    # systemd service name (required)
    display_name: "Nginx Web Server"  # friendly name for alerts (optional)
    restart_on_failure: true       # attempt restart if stopped (default: false)
  - name: sshd
    restart_on_failure: false
```

## Usage

```bash
# Check services defined in vars/main.yml
ansible-playbook -i inventory/hosts.ini linux/service-health-check/playbook.yml

# Override services inline (useful for ad-hoc checks)
ansible-playbook -i inventory/hosts.ini linux/service-health-check/playbook.yml \
  -e '{"required_services":[{"name":"nginx","restart_on_failure":true},{"name":"sshd"}]}'

# Check only web servers
ansible-playbook -i inventory/hosts.ini linux/service-health-check/playbook.yml \
  -l webservers

# Schedule every 15 minutes on the Ansible controller
# */15 * * * * ansible-playbook -i /etc/ansible/hosts linux/service-health-check/playbook.yml
```

## Alert Behavior

- **Stopped service found**: Displays ALERT in Ansible output and writes to controller log
- **`restart_on_failure: true`**: Ansible attempts `systemctl restart <service>` and verifies recovery
- **Service still down after restart (or restart disabled)**: Play is **failed** for that host
- **Email**: Sent when `service_email_alert: true` and at least one service is down

## Notes

- Pairs with `linux/systemd-unit/` to ensure custom services are properly configured
- For real-time alerting, configure systemd service failure notifications or use Prometheus Alertmanager with `node_exporter` service state metrics
