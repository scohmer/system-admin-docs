# Centralized Syslog Configuration

> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

## Overview

Configures rsyslog on managed hosts to forward logs to a central syslog server. Optionally configures the receiver host to accept, store, and rotate incoming logs. Logs are organised per-host in `{{ syslog_server_log_dir }}/<hostname>/<program>.log`.

## Requirements

- Ansible 2.14+
- `ansible.posix` collection (firewalld)
- `community.general` collection (UFW)

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `target_hosts` | `all` | Inventory group or host pattern |
| `syslog_server` | `192.168.1.100` | Central syslog server IP or hostname |
| `syslog_port` | `514` | Syslog listener port |
| `syslog_protocol` | `udp` | `udp` (faster) or `tcp` (reliable, ordered) |
| `syslog_forward_rules` | `*.warn`, auth, kern, cron | rsyslog facility.severity selectors to forward |
| `syslog_configure_server` | `false` | Set `true` on the receiver host |
| `syslog_server_log_dir` | `/var/log/remote` | Root directory for incoming logs on the server |
| `syslog_retention_days` | `90` | Days to retain remote log files (logrotate) |
| `syslog_firewall_manage` | `true` | Open syslog port in firewall on the server |

## Usage

```bash
# Step 1 — Configure the syslog server (receiver)
ansible-playbook -i inventory/hosts.ini linux/centralized-syslog/playbook.yml \
  -l syslog-server \
  -e syslog_configure_server=true

# Step 2 — Configure all other hosts to forward logs
ansible-playbook -i inventory/hosts.ini linux/centralized-syslog/playbook.yml

# Use TCP for reliable delivery (recommended for production)
ansible-playbook -i inventory/hosts.ini linux/centralized-syslog/playbook.yml \
  -e syslog_protocol=tcp
```

## Log Storage Layout on the Server

```
/var/log/remote/
├── web01.corp.local/
│   ├── nginx.log
│   ├── sshd.log
│   └── sudo.log
├── db01.corp.local/
│   ├── postgresql.log
│   └── sshd.log
└── ...
```

## Forwarding Rules

Edit `syslog_forward_rules` in `vars/main.yml` to control what is forwarded:

```yaml
syslog_forward_rules:
  - "*.warn"           # All facilities, warning and above
  - "auth,authpriv.*"  # All auth messages (login, sudo, su)
  - "kern.*"           # Kernel messages
  - "*.*"              # Everything (verbose — use with care)
```

## Protocol Recommendation

| Protocol | Use case |
|----------|----------|
| UDP | Low-overhead, fire-and-forget. Acceptable for non-critical logs. |
| TCP | Ordered delivery, no dropped messages. Recommended for audit and auth logs. |

## Notes

- Pairs with `linux/fail2ban/` to centrally monitor auth failures across all hosts
- Pairs with `linux/auditd/` for forwarding audit records to the central server
- For encrypted log shipping, consider `rsyslog` with TLS (`imtcp` with `gtls` driver) or `filebeat` → Elasticsearch
