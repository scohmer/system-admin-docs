> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# SELinux Management

Manages SELinux state, policy booleans, and file contexts on RedHat-family Linux systems. This playbook uses the `ansible.posix` and `community.general` collections to configure SELinux in a consistent, idempotent manner.

## Playbook

**File:** `playbook.yml`

This playbook:
- Sets the SELinux enforcement mode (`enforcing`, `permissive`, or `disabled`)
- Configures SELinux policy type (`targeted` or `mls`)
- Manages SELinux booleans persistently
- Manages file contexts and runs `restorecon` to apply them
- Reports the current SELinux state after changes

## Variables

| Variable | Type | Required | Default | Description |
|---|---|---|---|---|
| `target_hosts` | string | Yes | `all` | Ansible host pattern to target |
| `selinux_state` | string | Yes | `enforcing` | SELinux mode: `enforcing`, `permissive`, or `disabled` |
| `selinux_policy` | string | No | `targeted` | SELinux policy: `targeted` or `mls` |
| `selinux_booleans` | list | No | `[]` | List of SELinux booleans to configure |
| `selinux_fcontexts` | list | No | `[]` | List of file contexts to manage |

### `selinux_booleans` entry structure

| Field | Type | Required | Default | Description |
|---|---|---|---|---|
| `name` | string | Yes | — | Boolean name (e.g., `httpd_can_network_connect`) |
| `state` | string | Yes | — | `on` or `off` |
| `persistent` | bool | No | `true` | Persist across reboots |

### `selinux_fcontexts` entry structure

| Field | Type | Required | Default | Description |
|---|---|---|---|---|
| `target` | string | Yes | — | Path or regex (e.g., `/srv/www(/.*)?`) |
| `setype` | string | Yes | — | SELinux type (e.g., `httpd_sys_content_t`) |
| `state` | string | No | `present` | `present` or `absent` |

## Usage

```bash
# Apply SELinux configuration
ansible-playbook -i inventory/hosts.yml linux/selinux-management/playbook.yml

# Set SELinux to permissive mode
ansible-playbook -i inventory/hosts.yml linux/selinux-management/playbook.yml \
  -e "selinux_state=permissive"

# Target specific hosts
ansible-playbook -i inventory/hosts.yml linux/selinux-management/playbook.yml \
  -e "target_hosts=rhel_servers"

# Dry run
ansible-playbook -i inventory/hosts.yml linux/selinux-management/playbook.yml \
  --check --diff
```

## Notes

- **Switching to or from `disabled` requires a system reboot.** The playbook will notify you, but it does not reboot automatically — schedule the reboot separately.
- Switching between `enforcing` and `permissive` does **not** require a reboot and takes effect immediately.
- This playbook is designed for **RedHat-family systems** only. SELinux is not natively supported on Debian/Ubuntu (use AppArmor instead).
- Required collections:
  - `ansible.posix` — for `ansible.posix.selinux` and `ansible.posix.seboolean`
  - `community.general` — for `community.general.sefcontext`
  - Install with: `ansible-galaxy collection install ansible.posix community.general`
- The `selinux-policy-targeted` (or `selinux-policy-mls`) package must be installed. This playbook installs it if missing.
- File context changes require `restorecon` to take effect. This playbook runs `restorecon -Rv <path>` after each context change.
