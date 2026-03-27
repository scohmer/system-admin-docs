> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — Timezone Management

Set the system timezone and hardware clock synchronization on Linux servers.

## Playbook

`playbook.yml`

## Variables (`vars/main.yml`)

| Variable | Description | Default |
|----------|-------------|---------|
| `target_hosts` | Inventory host or group | `all` |
| `system_timezone` | Timezone (from `timedatectl list-timezones`) | `UTC` |
| `hwclock_sync` | Sync hardware clock after timezone change | `true` |

## Usage

```bash
ansible-playbook -i inventory/hosts.ini linux/timezone-management/playbook.yml \
  -e target_hosts=all

# Set a specific timezone
ansible-playbook -i inventory/hosts.ini linux/timezone-management/playbook.yml \
  -e target_hosts=servers \
  -e system_timezone=America/New_York
```

## Notes

- Setting `UTC` is best practice for servers — use application-level timezone handling for user-facing times.
- Valid timezone names: `timedatectl list-timezones`
- The hardware clock (`/etc/adjtime`) is updated after changing the timezone.
