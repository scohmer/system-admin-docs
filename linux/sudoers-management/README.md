> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Sudoers Management

Manages sudo access for users and groups by writing drop-in files to `/etc/sudoers.d/`. This playbook never modifies `/etc/sudoers` directly. Each user and group receives its own validated drop-in file, ensuring that a syntax error in one entry does not corrupt the entire sudo configuration.

## Playbook

**File:** `playbook.yml`

This playbook:
- Ensures `sudo` is installed on all target hosts
- Writes per-user and per-group sudoers drop-in files to `/etc/sudoers.d/`
- Validates each file with `visudo -c -f` before leaving it in place
- Sets correct permissions (`0440`) on all drop-in files
- Supports both `NOPASSWD` entries and command-restricted sudo

## Variables

| Variable | Type | Required | Default | Description |
|---|---|---|---|---|
| `target_hosts` | string | Yes | `all` | Ansible host pattern to target |
| `sudo_users` | list | No | `[]` | List of user sudo entries (see structure below) |
| `sudo_groups` | list | No | `[]` | List of group sudo entries (see structure below) |
| `sudoers_validate` | bool | No | `true` | Run `visudo -c` validation before applying |

### `sudo_users` entry structure

| Field | Type | Required | Default | Description |
|---|---|---|---|---|
| `username` | string | Yes | — | Linux username to grant sudo access |
| `nopasswd` | bool | No | `false` | If `true`, no password is required |
| `commands` | string | No | `ALL` | Comma-separated commands or `ALL` |

### `sudo_groups` entry structure

| Field | Type | Required | Default | Description |
|---|---|---|---|---|
| `groupname` | string | Yes | — | Linux group name to grant sudo access |
| `nopasswd` | bool | No | `false` | If `true`, no password is required |
| `commands` | string | No | `ALL` | Comma-separated commands or `ALL` |

## Usage

```bash
# Run with default inventory
ansible-playbook -i inventory/hosts.yml linux/sudoers-management/playbook.yml

# Target specific hosts
ansible-playbook -i inventory/hosts.yml linux/sudoers-management/playbook.yml \
  -e "target_hosts=webservers"

# Override variables inline
ansible-playbook -i inventory/hosts.yml linux/sudoers-management/playbook.yml \
  -e "@vars/main.yml"

# Dry run
ansible-playbook -i inventory/hosts.yml linux/sudoers-management/playbook.yml \
  --check --diff
```

## Notes

- **Never edit `/etc/sudoers` directly.** This playbook uses drop-in files under `/etc/sudoers.d/` for safety and modularity.
- Each drop-in file is validated with `visudo -c -f <file>` before it is written with correct permissions. If validation fails, the file is removed and the play fails with an error.
- Drop-in files use the naming convention `10-ansible-<username>` or `10-ansible-group-<groupname>`.
- File permissions must be exactly `0440` (readable by root and sudo group only). World-readable sudoers files are rejected by sudo.
- Switching `nopasswd: false` to `nopasswd: true` (or vice versa) will update the drop-in file and take effect immediately — no service restart is required.
- Removing a user or group from `sudo_users`/`sudo_groups` does **not** automatically remove their drop-in file. Set a separate cleanup task if you need to revoke access.
