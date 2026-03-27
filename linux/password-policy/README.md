> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — Password Policy

Configure password complexity, aging, and history requirements via PAM and `/etc/login.defs`.

## Playbook

`playbook.yml`

## Variables (`vars/main.yml`)

| Variable | Description | Default |
|----------|-------------|---------|
| `target_hosts` | Inventory host or group | `all` |
| `password_min_length` | Minimum password length | `12` |
| `password_max_age` | Maximum password age in days | `90` |
| `password_min_age` | Minimum days between password changes | `1` |
| `password_warn_age` | Days before expiry to warn | `14` |
| `password_remember` | Number of previous passwords to remember | `5` |
| `password_min_class` | Minimum character classes required | `3` |
| `password_min_upper` | Minimum uppercase letters | `1` |
| `password_min_lower` | Minimum lowercase letters | `1` |
| `password_min_digit` | Minimum digit characters | `1` |
| `password_min_special` | Minimum special characters | `1` |

## Usage

```bash
ansible-playbook -i inventory/hosts.ini linux/password-policy/playbook.yml \
  -e target_hosts=all
```

## Notes

- Uses `pam_pwquality` (RHEL) or `pam_cracklib` (older Debian) for complexity enforcement.
- `login.defs` settings apply to new accounts created with `useradd`/`adduser`.
- Changes do not retroactively expire existing passwords — use `chage` or `passwd --expire` on individual accounts.
- Requires `libpam-pwquality` on Debian/Ubuntu.
