> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — Disk Management

Check disk usage, report on filesystem utilization, and manage LVM logical volumes across managed hosts using Ansible.

## Playbook

`playbook.yml`

## Variables

Populate `vars/main.yml` before running.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `target_hosts` | string | Yes | — | Ansible inventory group or host |
| `disk_warning_threshold_pct` | int | No | `80` | Warn when filesystem usage exceeds this % |
| `disk_critical_threshold_pct` | int | No | `90` | Error when filesystem usage exceeds this % |
| `lvm_volumes` | list | No | `[]` | LVM logical volumes to create or resize (see structure below) |

### `lvm_volumes` item structure

```yaml
lvm_volumes:
  - vg: data_vg           # Volume group name (must exist)
    lv: app_lv            # Logical volume name
    size: 20g             # Size: e.g., 10g, +5g (extend by 5g), 100%FREE
    filesystem: ext4      # Filesystem type: ext4, xfs
    mount_point: /data/app
    mount_opts: defaults  # Mount options (default: defaults)
    state: present        # present or absent
```

## Usage

```bash
# Report disk usage only (read-only, safe for production)
ansible-playbook -i /etc/ansible/hosts playbook.yml \
  -e @vars/main.yml -e "lvm_volumes=[]"

# Preview LVM changes
ansible-playbook -i /etc/ansible/hosts playbook.yml \
  -e @vars/main.yml --check

# Apply
ansible-playbook -i /etc/ansible/hosts playbook.yml \
  -e @vars/main.yml
```

## Notes

- LVM management requires that the `lvm2` package is installed on target hosts.
- The `vg` (volume group) must already exist on the target host. This playbook does not create volume groups or manage physical volumes.
- Extending a volume (`+5g`) is non-destructive; shrinking is not supported and must be done manually.
- XFS filesystems cannot be shrunk. Only ext4 supports shrinking (and it still requires careful handling).
- Disk usage warnings are reported via Ansible debug output. Integrate with alerting as needed.
