> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — LVM Snapshot Management

Create, list, and remove LVM snapshots for point-in-time recovery and pre-change backups.

## Playbook

`playbook.yml`

## Variables (`vars/main.yml`)

| Variable | Description | Default |
|----------|-------------|---------|
| `target_hosts` | Inventory host or group | `all` |
| `lvm_snapshot_action` | `create`, `remove`, `list` | `list` |
| `lvm_snapshots` | List of snapshot definitions | `[]` |

### Snapshot definition fields

| Field | Description |
|-------|-------------|
| `origin_lv` | Source LV path (e.g., `/dev/vg0/root`) |
| `snapshot_name` | Snapshot LV name |
| `size` | Snapshot size (e.g., `5G`) |
| `mount_point` | Mount point to mount snapshot (optional) |

## Usage

```bash
# Create snapshots
ansible-playbook -i inventory/hosts.ini linux/lvm-snapshot/playbook.yml \
  -e target_hosts=servers \
  -e lvm_snapshot_action=create

# List snapshots
ansible-playbook -i inventory/hosts.ini linux/lvm-snapshot/playbook.yml \
  -e target_hosts=servers \
  -e lvm_snapshot_action=list

# Remove snapshots
ansible-playbook -i inventory/hosts.ini linux/lvm-snapshot/playbook.yml \
  -e target_hosts=servers \
  -e lvm_snapshot_action=remove
```

## Notes

- Snapshot size should be at least 20% of the origin LV size for active volumes.
- Snapshots fill up if changes exceed the snapshot size — the snapshot becomes invalid.
- Snapshots are stored in the same Volume Group as the origin LV.
- Use as pre-change safety net before patches, not as a long-term backup solution.
