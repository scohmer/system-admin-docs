> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — Hosts File Management

Manage `/etc/hosts` entries across Linux servers for internal DNS overrides and service discovery.

## Playbook

`playbook.yml`

## Variables (`vars/main.yml`)

| Variable | Description | Default |
|----------|-------------|---------|
| `target_hosts` | Inventory host or group | `all` |
| `hosts_entries` | List of host entries to add | `[]` |
| `hosts_entries_remove` | List of hostnames/IPs to remove | `[]` |
| `hosts_preserve_existing` | Keep existing entries not managed here | `true` |

## Usage

```bash
ansible-playbook -i inventory/hosts.ini linux/hosts-file/playbook.yml \
  -e target_hosts=all
```

## Notes

- Uses `ansible.builtin.lineinfile` to idempotently add/remove entries without replacing the whole file.
- Existing entries (including `127.0.0.1 localhost`) are preserved unless `hosts_preserve_existing` is false.
- For larger environments, prefer a proper internal DNS server over hosts file management.
