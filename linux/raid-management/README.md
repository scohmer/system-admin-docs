> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — Software RAID Management

Monitor and manage Linux Software RAID (mdadm) arrays.

## Playbook

`playbook.yml`

## Variables (`vars/main.yml`)

| Variable | Description | Default |
|----------|-------------|---------|
| `target_hosts` | Inventory host or group | `all` |
| `raid_arrays` | List of RAID array definitions to create | `[]` |
| `raid_monitor_email` | Email for mdadm failure alerts | `root` |
| `raid_check_schedule` | Cron schedule for array check | weekly on Sunday |

## Usage

```bash
# Monitor existing arrays
ansible-playbook -i inventory/hosts.ini linux/raid-management/playbook.yml \
  -e target_hosts=servers

# Create new arrays (set raid_arrays in vars)
ansible-playbook -i inventory/hosts.ini linux/raid-management/playbook.yml \
  -e target_hosts=servers \
  -e raid_action=create
```

## Notes

- This playbook focuses on monitoring, alerting, and mdadm configuration.
- Array creation from Ansible is complex and risky — consider doing initial RAID setup manually and using this playbook for ongoing management.
- Check RAID status: `cat /proc/mdstat` or `mdadm --detail /dev/md0`
- mdadm sends email alerts via the system MTA (postfix, sendmail, etc.).
