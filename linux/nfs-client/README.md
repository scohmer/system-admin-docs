> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — NFS Client

Install the NFS client and configure persistent NFS mounts via `/etc/fstab`.

## Playbook

`playbook.yml`

## Variables (`vars/main.yml`)

| Variable | Description | Default |
|----------|-------------|---------|
| `target_hosts` | Inventory host or group | `all` |
| `nfs_mounts` | List of NFS mounts to configure | see vars |

### Mount definition fields

| Field | Description |
|-------|-------------|
| `src` | NFS source (e.g., `192.168.1.10:/exports/data`) |
| `path` | Local mount point (will be created) |
| `opts` | Mount options (default: `defaults,_netdev`) |
| `state` | `mounted`, `unmounted`, `absent` |

## Usage

```bash
ansible-playbook -i inventory/hosts.ini linux/nfs-client/playbook.yml \
  -e target_hosts=appservers
```

## Notes

- `_netdev` mount option ensures NFS mounts happen after network is available at boot.
- `nfsvers=4` can be added to options to force NFSv4.
- `soft` vs `hard` mount: `hard` retries indefinitely (default, safer for critical data); `soft` fails after timeout.
