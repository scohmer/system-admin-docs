> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — System Patching

Apply security and OS updates across managed hosts using Ansible. Supports Debian/Ubuntu (apt) and RHEL/CentOS/Rocky/Alma (dnf). Handles reboot requirements safely.

## Playbook

`playbook.yml`

## Variables

Populate `vars/main.yml` before running.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `target_hosts` | string | Yes | — | Ansible inventory group or host |
| `update_type` | string | No | `security` | What to update: `security`, `all` |
| `reboot_if_required` | bool | No | `false` | Reboot hosts automatically if kernel or libc was updated |
| `reboot_timeout` | int | No | `300` | Seconds to wait for host to return after reboot |
| `pre_patch_snapshot` | bool | No | `false` | If true, runs a pre-patching script (see notes) |
| `notify_on_complete` | bool | No | `false` | Log a completion message to syslog when done |

## Usage

```bash
# Preview what would be updated (no changes)
ansible-playbook -i /etc/ansible/hosts playbook.yml \
  -e @vars/main.yml --check

# Apply security updates only
ansible-playbook -i /etc/ansible/hosts playbook.yml \
  -e @vars/main.yml

# Apply all updates with automatic reboot if required
ansible-playbook -i /etc/ansible/hosts playbook.yml \
  -e @vars/main.yml \
  -e "update_type=all reboot_if_required=true"

# Target a specific group and limit to one host at a time
ansible-playbook -i /etc/ansible/hosts playbook.yml \
  -e @vars/main.yml -l webservers --forks 1
```

## Patching Strategy Recommendations

| Environment | Recommended Settings |
|-------------|---------------------|
| Development | `update_type=all`, `reboot_if_required=true` |
| Staging | `update_type=all`, `reboot_if_required=true`, `--forks 5` |
| Production | `update_type=security`, `reboot_if_required=false` (reboot in maintenance window) |

## Notes

- Always run with `--check` first on production to preview changes.
- Use `--forks 1` (serial) when patching production to catch issues early before they affect all hosts.
- If `reboot_if_required: false` and a reboot is needed, the playbook will output a warning listing which hosts need a reboot.
- The `/var/run/reboot-required` file (Debian) or `needs-restarting` (RHEL) is used to detect reboot requirements.
