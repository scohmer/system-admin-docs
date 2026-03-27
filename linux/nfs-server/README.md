> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — NFS Server

Install and configure an NFS server with exported shares and client access controls.

## Playbook

`playbook.yml`

## Variables (`vars/main.yml`)

| Variable | Description | Default |
|----------|-------------|---------|
| `target_hosts` | Inventory host or group | `all` |
| `nfs_exports` | List of NFS export definitions | see vars |
| `nfs_firewall_manage` | Open NFS ports in firewall | `true` |

### Export definition fields

| Field | Description |
|-------|-------------|
| `path` | Directory to export |
| `clients` | Client spec with options (e.g., `192.168.1.0/24(rw,sync,no_subtree_check)`) |

## Usage

```bash
ansible-playbook -i inventory/hosts.ini linux/nfs-server/playbook.yml \
  -e target_hosts=storage_servers
```

## Notes

- NFS v4 is used by default on modern Linux. NFSv3 can be enabled via `/etc/nfs.conf`.
- `no_root_squash` should only be used for trusted admin clients — it allows root on the client to act as root on the server.
- Use `sync` for data integrity (slower) or `async` for performance (risk of data loss on server crash).
- Exported directories must exist before running the playbook.
