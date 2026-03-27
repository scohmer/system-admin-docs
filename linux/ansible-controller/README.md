> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Ansible Controller — Automated Playbook Scheduling

Set up cron-based automation on an Ansible controller node so that playbooks in this repository run on a schedule without manual intervention.

## Overview

This folder contains:

- `playbook.yml` — Installs Ansible on the controller and configures cron jobs to run playbooks automatically
- `vars/main.yml` — Schedule configuration
- `run-playbook.sh` — Wrapper script used by cron to execute playbooks with logging

## Architecture

```
Ansible Controller (this node)
  ├── cron (scheduled trigger)
  │     └── run-playbook.sh
  │           └── ansible-playbook <task>/playbook.yml -e @<task>/vars/main.yml
  └── SSH keys → Managed Hosts
```

## Variables

Populate `vars/main.yml` before running.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `controller_user` | string | Yes | — | User account on the controller that runs cron jobs |
| `repo_path` | string | Yes | — | Absolute path to this repository on the controller |
| `inventory_path` | string | Yes | — | Path to the Ansible inventory file |
| `log_dir` | string | No | `/var/log/ansible` | Directory for playbook run logs |
| `scheduled_playbooks` | list | No | `[]` | Playbooks to schedule (see structure below) |

### `scheduled_playbooks` item structure

```yaml
scheduled_playbooks:
  - name: "Weekly system patching"
    playbook: "linux/system-patching/playbook.yml"
    vars_file: "linux/system-patching/vars/main.yml"
    extra_vars: {}               # Additional --extra-vars to pass
    limit: ""                    # Ansible -l limit (leave empty for all)
    minute: "0"
    hour: "3"
    weekday: "0"                 # 0=Sunday
    enabled: true
```

## Usage

### 1. Configure `vars/main.yml`

Set `controller_user`, `repo_path`, and `inventory_path` to match your environment. Define the playbooks you want to schedule.

### 2. Run the controller setup playbook (locally)

```bash
ansible-playbook -i localhost, -c local playbook.yml -e @vars/main.yml
```

### 3. Verify cron jobs

```bash
crontab -u <controller_user> -l
```

### 4. Check logs

```bash
ls /var/log/ansible/
tail -f /var/log/ansible/system-patching_<date>.log
```

## Log File Naming

Logs are written to `<log_dir>/<playbook-name>_<YYYY-MM-DD_HH-MM>.log`.

## Notes

- Ensure the `controller_user` has SSH key access to all managed hosts.
- The wrapper script exits with a non-zero code if the playbook fails, which is captured in the log.
- Consider using Ansible AWX or Tower for production environments that need audit trails, RBAC, and a UI-based scheduling interface.
- If using `ansible-vault` for secrets, set `ANSIBLE_VAULT_PASSWORD_FILE` in the wrapper script environment.

## Security Considerations

- The controller's SSH private key must be accessible to `controller_user` only (`chmod 600`).
- Playbook logs may contain sensitive output — ensure `log_dir` has appropriate permissions (`chmod 750`).
- Rotate log files using the [Log Management](../log-management/) playbook.
