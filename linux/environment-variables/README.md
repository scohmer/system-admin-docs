> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — Environment Variables

Manage system-wide and per-user environment variables on Linux servers.

## Playbook

`playbook.yml`

## Variables (`vars/main.yml`)

| Variable | Description | Default |
|----------|-------------|---------|
| `target_hosts` | Inventory host or group | `all` |
| `env_system_vars` | System-wide variables in `/etc/environment` | `{}` |
| `env_profile_vars` | Variables in `/etc/profile.d/ansible-env.sh` | `{}` |
| `env_remove_keys` | List of variable names to remove | `[]` |

## Usage

```bash
ansible-playbook -i inventory/hosts.ini linux/environment-variables/playbook.yml \
  -e target_hosts=appservers
```

## Notes

- `/etc/environment` is a simple key=value file (no shell syntax) read by PAM and most login mechanisms.
- `/etc/profile.d/ansible-env.sh` is a shell script sourced for interactive login shells — supports export, PATH manipulation, and conditionals.
- Changes take effect for new login sessions — existing shells are not affected.
- For service-specific environment variables, use systemd unit `Environment=` directives instead.
