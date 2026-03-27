> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — Package Management

Install, update, and remove software packages across managed hosts using Ansible. Supports apt (Debian/Ubuntu) and dnf/yum (RHEL/CentOS/Rocky/AlmaLinux) automatically.

## Playbook

`playbook.yml`

## Variables

Populate `vars/main.yml` before running.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `target_hosts` | string | Yes | — | Ansible inventory group or host |
| `packages_to_install` | list | No | `[]` | Package names to install |
| `packages_to_remove` | list | No | `[]` | Package names to remove |
| `update_cache` | bool | No | `true` | Refresh package cache before operations |
| `upgrade_all` | bool | No | `false` | Upgrade all installed packages |
| `autoremove` | bool | No | `false` | Remove unused dependency packages after changes |

### Example `vars/main.yml`

```yaml
target_hosts: webservers

packages_to_install:
  - nginx
  - curl
  - htop
  - unzip

packages_to_remove:
  - telnet

update_cache: true
upgrade_all: false
autoremove: true
```

## Usage

```bash
# Dry run
ansible-playbook -i /etc/ansible/hosts playbook.yml \
  -e @vars/main.yml --check

# Apply
ansible-playbook -i /etc/ansible/hosts playbook.yml \
  -e @vars/main.yml

# Override target at runtime
ansible-playbook -i /etc/ansible/hosts playbook.yml \
  -e @vars/main.yml -e "target_hosts=db01"
```

## Notes

- The playbook detects the OS family automatically using `ansible_os_family` and uses the appropriate package manager.
- Supported families: `Debian` (apt), `RedHat` (dnf/yum).
- Setting `upgrade_all: true` on production systems should only be done during a scheduled maintenance window.
- Use `--check` mode first on production hosts to preview changes without applying them.
