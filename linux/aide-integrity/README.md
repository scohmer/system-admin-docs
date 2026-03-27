> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — AIDE File Integrity Monitoring

Deploy AIDE (Advanced Intrusion Detection Environment) for file integrity monitoring to detect unauthorized changes to system files.

## Playbook

`playbook.yml`

## Variables (`vars/main.yml`)

| Variable | Description | Default |
|----------|-------------|---------|
| `target_hosts` | Inventory host or group | `all` |
| `aide_db_path` | Path to the active AIDE database | `/var/lib/aide/aide.db` |
| `aide_db_new_path` | Path to the newly generated database before promotion | `/var/lib/aide/aide.db.new` |
| `aide_config_path` | Default config path reference (overridden per OS) | `/etc/aide/aide.conf` |
| `aide_report_path` | Path where AIDE writes check reports | `/var/log/aide/aide.log` |
| `aide_extra_include` | Additional directories to monitor beyond defaults | `[]` |
| `aide_extra_exclude` | Directories to exclude from monitoring | see vars |
| `aide_schedule_method` | How to schedule daily checks: `cron` or `systemd` | `cron` |
| `aide_cron_hour` | Hour for the scheduled AIDE check | `3` |
| `aide_cron_minute` | Minute for the scheduled AIDE check | `0` |
| `aide_email_enable` | Send email alert when changes are detected | `false` |
| `aide_email_to` | Email address for change alerts | `root@localhost` |
| `aide_reinitialize` | Overwrite the existing baseline database (destructive) | `false` |

## Usage

```bash
ansible-playbook -i inventory/hosts.ini linux/aide-integrity/playbook.yml \
  -e target_hosts=all
```

Re-initialize the baseline after intentional system changes:

```bash
ansible-playbook -i inventory/hosts.ini linux/aide-integrity/playbook.yml \
  -e target_hosts=all \
  -e aide_reinitialize=true
```

## Notes

- First run initializes the baseline database — subsequent runs check against it without reinitializing.
- `aide_reinitialize: true` overwrites the existing baseline — only use this after intentional system changes such as software upgrades or configuration updates.
- AIDE initialization and checks can take 1–5 minutes on busy systems; the playbook uses `async`/`poll` to accommodate this.
- Review check reports in `{{ aide_report_path }}` (default: `/var/log/aide/aide.log`).
- The OS-specific config path is set automatically: `/etc/aide/aide.conf` on Debian-family systems and `/etc/aide.conf` on RedHat-family systems.
- When using `aide_schedule_method: systemd`, a one-shot service and a persistent timer are created under `/etc/systemd/system/`.
