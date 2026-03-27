> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — Hostname Management

Set the system FQDN, update `/etc/hostname` and `/etc/hosts` to reflect the new name.

## Playbook

`playbook.yml`

## Variables (`vars/main.yml`)

| Variable | Description | Default |
|----------|-------------|---------|
| `target_hosts` | Inventory host or group | `all` |
| `hostname_fqdn` | Fully qualified domain name to set | `{{ inventory_hostname }}` |
| `hostname_short` | Short hostname (derived from FQDN) | `{{ hostname_fqdn.split('.')[0] }}` |
| `hostname_update_hosts_file` | Update `/etc/hosts` with the new hostname | `true` |
| `hostname_ip` | IP address to use in `/etc/hosts` | `{{ ansible_default_ipv4.address \| default('127.0.1.1') }}` |
| `hostname_restart_logind` | Restart `systemd-logind` after hostname change | `true` |

## Usage

```bash
# Set hostname from inventory_hostname (default)
ansible-playbook -i inventory/hosts.ini linux/hostname-management/playbook.yml

# Override hostname for a specific host
ansible-playbook -i inventory/hosts.ini linux/hostname-management/playbook.yml \
  -l server01 -e hostname_fqdn=server01.corp.local
```

## Notes

- Use `host_vars/<hostname>/vars.yml` to set `hostname_fqdn` per host for bulk operations
- The playbook does not update DNS — update your DNS server separately or use the `bind-dns` playbook
- A reconnection may be required after hostname change if using hostname-based SSH config
