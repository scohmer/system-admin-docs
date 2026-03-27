> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — Systemd Unit File Management

Deploy and manage custom systemd service units for application daemons.

## Playbook

`playbook.yml`

## Variables (`vars/main.yml`)

| Variable | Description | Default |
|----------|-------------|---------|
| `target_hosts` | Inventory host or group | `all` |
| `systemd_units` | List of systemd unit definitions | see vars |

### Unit definition fields

| Field | Description |
|-------|-------------|
| `name` | Unit name (without `.service`) |
| `description` | Service description |
| `exec_start` | Command to start the service |
| `exec_stop` | Command to stop the service (optional) |
| `user` | User to run service as |
| `group` | Group to run service as |
| `working_dir` | Working directory |
| `restart` | Restart policy (`always`, `on-failure`, `no`) |
| `restart_sec` | Seconds before restarting |
| `environment` | Key-value environment variables |
| `after` | Unit dependencies (After=) |
| `wanted_by` | Install target |
| `state` | `started`, `stopped`, `restarted` |
| `enabled` | Enable at boot |

## Usage

```bash
ansible-playbook -i inventory/hosts.ini linux/systemd-unit/playbook.yml \
  -e target_hosts=appservers
```

## Notes

- Unit files are deployed to `/etc/systemd/system/`.
- `daemon_reload: true` is called automatically after deploying unit files.
- The `journalctl -u <unit-name>` command shows logs for any unit.
