> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — APT Repository Management

Add, configure, and manage APT package repositories on Debian/Ubuntu systems.

## Playbook

`playbook.yml`

## Variables (`vars/main.yml`)

| Variable | Description | Default |
|----------|-------------|---------|
| `target_hosts` | Inventory host or group | `all` |
| `apt_repos` | List of APT repositories to add | see vars |
| `apt_repos_remove` | List of repository lines to remove | `[]` |
| `apt_gpg_keys` | List of GPG keys to import | `[]` |
| `apt_pins` | APT pinning preferences | `[]` |

## Usage

```bash
ansible-playbook -i inventory/hosts.ini linux/apt-repo-management/playbook.yml \
  -e target_hosts=ubuntu_servers
```

## Notes

- Playbook fails with error on RHEL-family systems (use yum-repo-management instead).
- GPG keys should be stored in `/etc/apt/keyrings/` (modern approach, replaces `apt-key`).
- Use APT pinning to prefer packages from a specific repository or hold packages at a version.
