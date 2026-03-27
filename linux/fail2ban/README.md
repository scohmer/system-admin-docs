> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — Fail2ban

Install and configure Fail2ban to automatically ban IPs with repeated authentication failures.

## Playbook

`playbook.yml`

## Variables (`vars/main.yml`)

| Variable | Description | Default |
|----------|-------------|---------|
| `target_hosts` | Inventory host or group | `all` |
| `fail2ban_bantime` | Ban duration in seconds (`-1` = permanent) | `3600` |
| `fail2ban_findtime` | Time window for failures in seconds | `600` |
| `fail2ban_maxretry` | Max failures before ban | `5` |
| `fail2ban_ignoreips` | IPs/CIDRs never to ban | `127.0.0.1/8` |
| `fail2ban_jails` | List of jail configurations | SSH jail enabled |
| `fail2ban_email` | Email address for notifications | `''` |

## Usage

```bash
ansible-playbook -i inventory/hosts.ini linux/fail2ban/playbook.yml \
  -e target_hosts=all
```

## Notes

- Jails are configured in `/etc/fail2ban/jail.d/` to avoid overwriting distribution defaults.
- Check jail status: `fail2ban-client status sshd`
- Unban an IP: `fail2ban-client set sshd unbanip <IP>`
- Logs are written to `/var/log/fail2ban.log`.
