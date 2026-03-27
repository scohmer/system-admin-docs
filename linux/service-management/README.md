> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — Service Management

Start, stop, restart, enable, and disable systemd services across managed hosts using Ansible.

## Playbook

`playbook.yml`

## Variables

Populate `vars/main.yml` before running.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `target_hosts` | string | Yes | — | Ansible inventory group or host |
| `services` | list | Yes | — | List of service definitions (see structure below) |

### `services` item structure

```yaml
services:
  - name: nginx           # systemd service name (without .service)
    state: started        # started, stopped, restarted, reloaded
    enabled: true         # Enable to start at boot (true/false)
    daemon_reload: false  # Run systemctl daemon-reload before managing (default: false)
```

### Valid `state` values

| Value | Description |
|-------|-------------|
| `started` | Ensure the service is running (starts it if stopped) |
| `stopped` | Ensure the service is stopped |
| `restarted` | Always restart the service |
| `reloaded` | Reload the service configuration (sends SIGHUP) |

## Usage

```bash
# Preview changes
ansible-playbook -i /etc/ansible/hosts playbook.yml \
  -e @vars/main.yml --check

# Apply
ansible-playbook -i /etc/ansible/hosts playbook.yml \
  -e @vars/main.yml

# Target specific hosts
ansible-playbook -i /etc/ansible/hosts playbook.yml \
  -e @vars/main.yml -l webservers
```

## Notes

- The playbook checks whether each service exists before attempting to manage it, and reports a warning for unknown services rather than failing.
- Enabling a service (`enabled: true`) does not start it immediately — use `state: started` to also ensure it's running.
- `restarted` will restart the service **every time** the playbook runs. Use it only when you want a guaranteed restart (e.g., after a config change).
