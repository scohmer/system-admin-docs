> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — ulimits (Resource Limits)

Configure system and per-user resource limits via `/etc/security/limits.conf` and `/etc/systemd/system.conf`.

## Playbook

`playbook.yml`

## Variables (`vars/main.yml`)

| Variable | Description | Default |
|----------|-------------|---------|
| `target_hosts` | Inventory host or group | `all` |
| `ulimits` | List of limit entries for limits.conf | see vars |
| `systemd_default_limits` | Systemd unit default limits | `{}` |

### Ulimit entry fields

| Field | Description |
|-------|-------------|
| `domain` | User, group (`@group`), or `*` for all |
| `type` | `soft`, `hard`, or `-` (both) |
| `item` | Limit type (`nofile`, `nproc`, `memlock`, etc.) |
| `value` | Limit value (or `unlimited`) |

## Usage

```bash
ansible-playbook -i inventory/hosts.ini linux/ulimits/playbook.yml \
  -e target_hosts=dbservers
```

## Notes

- `/etc/security/limits.conf` applies to PAM-authenticated sessions (SSH, sudo, etc.).
- Systemd-started services use their own limits defined in unit files or `/etc/systemd/system.conf`.
- Changes to `limits.conf` take effect on next login — existing sessions are not affected.
- Common items: `nofile` (open files), `nproc` (processes), `memlock` (locked memory), `stack` (stack size).
