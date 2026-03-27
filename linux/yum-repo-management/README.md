> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — YUM/DNF Repository Management

Add, configure, and manage YUM/DNF repositories on RHEL/CentOS/Rocky Linux systems.

## Playbook

`playbook.yml`

## Variables (`vars/main.yml`)

| Variable | Description | Default |
|----------|-------------|---------|
| `target_hosts` | Inventory host or group | `all` |
| `yum_repos` | List of repositories to add | see vars |
| `yum_repos_disable` | List of repository IDs to disable | `[]` |
| `yum_repos_remove` | List of repository IDs to remove entirely | `[]` |
| `gpg_keys` | GPG keys to import | `[]` |

### Repository definition fields

| Field | Description |
|-------|-------------|
| `name` | Repo ID (used in .repo filename) |
| `description` | Human-readable description |
| `baseurl` | Repository base URL |
| `gpgcheck` | Enable GPG checking (`true`/`false`) |
| `gpgkey` | URL to GPG key |
| `enabled` | Enable the repo |
| `priority` | Repo priority (lower = higher priority) |

## Usage

```bash
ansible-playbook -i inventory/hosts.ini linux/yum-repo-management/playbook.yml \
  -e target_hosts=rhel_servers
```

## Notes

- Playbook fails with error on Debian-family systems (use apt-repo-management instead).
- EPEL repository is a common addition for extra packages.
- For air-gapped environments, set `baseurl` to an internal mirror.
