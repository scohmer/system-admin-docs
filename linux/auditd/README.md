> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — Auditd Configuration

Install and configure the Linux Audit Daemon (`auditd`) with a comprehensive rule set for security compliance.

## Playbook

`playbook.yml`

## Variables (`vars/main.yml`)

| Variable | Description | Default |
|----------|-------------|---------|
| `target_hosts` | Inventory host or group | `all` |
| `auditd_log_file` | Audit log path | `/var/log/audit/audit.log` |
| `auditd_max_log_file` | Max log size in MB | `50` |
| `auditd_max_log_file_action` | Action when log is full | `ROTATE` |
| `auditd_num_logs` | Number of rotated logs to keep | `5` |
| `auditd_space_left_action` | Action when disk space is low | `SYSLOG` |
| `auditd_rules` | List of custom audit rules | see vars |
| `auditd_use_cis_rules` | Enable CIS benchmark baseline rules | `true` |

## Usage

```bash
ansible-playbook -i inventory/hosts.ini linux/auditd/playbook.yml \
  -e target_hosts=all
```

## Notes

- Audit rules are loaded from `/etc/audit/rules.d/` and compiled into `/etc/audit/audit.rules`.
- The CIS baseline rules cover: privilege escalation, sudo, authentication events, network config changes, and file permission changes.
- Rules are immutable (`-e 2`) at the end of the CIS ruleset — a reboot is required to change them.
- View recent audit events: `ausearch -ts recent` or `aureport --summary`.
