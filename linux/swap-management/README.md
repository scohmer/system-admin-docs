> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — Swap Management

Create, configure, and manage swap files and swap partitions on Linux servers.

## Playbook

`playbook.yml`

## Variables (`vars/main.yml`)

| Variable | Description | Default |
|----------|-------------|---------|
| `target_hosts` | Inventory host or group | `all` |
| `swap_file_path` | Path to swap file | `/swapfile` |
| `swap_file_size_mb` | Swap file size in MB | `2048` |
| `swap_enabled` | Enable swap (false to disable all swap) | `true` |
| `vm_swappiness` | Kernel swappiness value (0–100) | `10` |
| `vm_vfs_cache_pressure` | VFS cache pressure | `50` |

## Usage

```bash
ansible-playbook -i inventory/hosts.ini linux/swap-management/playbook.yml \
  -e target_hosts=appservers

# Disable swap (e.g., for Kubernetes nodes)
ansible-playbook -i inventory/hosts.ini linux/swap-management/playbook.yml \
  -e target_hosts=k8s_nodes \
  -e swap_enabled=false
```

## Notes

- Kubernetes requires swap to be disabled (`swap_enabled: false`).
- Swap file size recommendation: equal to RAM for servers with <2GB; 1-2x RAM otherwise.
- `vm_swappiness=10` reduces swap usage, keeping hot data in RAM longer — good for database servers.
- `vm_swappiness=0` disables swap entirely at the kernel level even if swap space exists.
