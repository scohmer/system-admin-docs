> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — Locale Management

Configure system locale, character encoding, and keyboard layout on Linux servers.

## Playbook

`playbook.yml`

## Variables (`vars/main.yml`)

| Variable | Description | Default |
|----------|-------------|---------|
| `target_hosts` | Inventory host or group | `all` |
| `system_locale` | System locale | `en_US.UTF-8` |
| `system_language` | LANG environment variable | same as locale |
| `locale_keyboard` | Console keyboard layout | `us` |
| `locale_generate` | Locales to generate | `['en_US.UTF-8 UTF-8']` |

## Usage

```bash
ansible-playbook -i inventory/hosts.ini linux/locale-management/playbook.yml \
  -e target_hosts=all
```

## Notes

- Locale changes take effect for new login sessions.
- `en_US.UTF-8` is the recommended locale for servers — it provides UTF-8 encoding which handles all character sets.
- Check current locale: `localectl status`
- List available locales: `localectl list-locales`
