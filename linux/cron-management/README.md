> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — Cron Job Management

Create, update, and remove cron jobs on managed hosts using Ansible.

## Playbook

`playbook.yml`

## Variables

Populate `vars/main.yml` before running.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `target_hosts` | string | Yes | — | Ansible inventory group or host |
| `cron_jobs` | list | No | `[]` | Cron jobs to create or remove (see structure below) |

### `cron_jobs` item structure

```yaml
cron_jobs:
  - name: "Backup data"           # Unique name (used as crontab comment to identify the job)
    user: root                    # User whose crontab to modify (default: root)
    job: "/usr/local/bin/backup.sh >> /var/log/backup.log 2>&1"
    minute: "0"                   # Cron minute field (default: *)
    hour: "2"                     # Cron hour field (default: *)
    day: "*"                      # Day of month (default: *)
    month: "*"                    # Month (default: *)
    weekday: "*"                  # Day of week, 0=Sunday (default: *)
    state: present                # present or absent
    disabled: false               # true to comment out the job (default: false)
```

### Cron field reference

| Field | Valid values |
|-------|-------------|
| `minute` | `0-59`, `*`, `*/5` (every 5 min) |
| `hour` | `0-23`, `*`, `*/6` (every 6 hrs) |
| `day` | `1-31`, `*` |
| `month` | `1-12`, `*` |
| `weekday` | `0-6` (0=Sunday), `*` |

## Usage

```bash
# Preview
ansible-playbook -i /etc/ansible/hosts playbook.yml \
  -e @vars/main.yml --check

# Apply
ansible-playbook -i /etc/ansible/hosts playbook.yml \
  -e @vars/main.yml

# Remove all cron jobs defined in the list (set state: absent in vars)
ansible-playbook -i /etc/ansible/hosts playbook.yml \
  -e @vars/main.yml
```

## Notes

- Cron jobs are identified by their `name` field (stored as a comment in the crontab). Changing the name creates a new job and orphans the old one.
- Redirect both stdout and stderr in your job command (`>> /var/log/job.log 2>&1`) to capture all output, otherwise cron mails output to the local user.
- To suppress all output: append `>/dev/null 2>&1` to the command.
- Always test the script manually as the target user before adding it as a cron job.
