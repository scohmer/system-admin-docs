> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — Account Lockout Policy

Configure PAM-based account lockout after repeated failed authentication attempts using `pam_faillock`.

## Playbook

`playbook.yml`

## Variables (`vars/main.yml`)

| Variable | Description | Default |
|----------|-------------|---------|
| `target_hosts` | Inventory host or group | `all` |
| `faillock_deny` | Failed attempts before lockout | `5` |
| `faillock_unlock_time` | Lockout duration in seconds (`0` = until admin unlocks) | `900` |
| `faillock_fail_interval` | Failure counting window in seconds | `900` |
| `faillock_even_deny_root` | Also lock root account | `false` |
| `faillock_root_unlock_time` | Root lockout duration (if enabled) | `60` |

## Usage

```bash
ansible-playbook -i inventory/hosts.ini linux/account-lockout/playbook.yml \
  -e target_hosts=all
```

## Checking and resetting lockouts

```bash
# Check lockout status for a user
faillock --user jdoe

# Reset lockout for a user
faillock --user jdoe --reset

# List all locked accounts
faillock
```

## Notes

- `pam_faillock` replaces the older `pam_tally2` on modern systems (RHEL 8+, Ubuntu 22.04+).
- Failure records are stored in `/var/run/faillock/` by default.
- Setting `faillock_even_deny_root: true` with low `deny` counts can lock out root — use carefully.
