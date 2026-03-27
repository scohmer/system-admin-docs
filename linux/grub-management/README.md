> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — GRUB Bootloader Management

Configure GRUB bootloader settings including kernel parameters, timeout, and security settings.

## Playbook

`playbook.yml`

## Variables (`vars/main.yml`)

| Variable | Description | Default |
|----------|-------------|---------|
| `target_hosts` | Inventory host or group | `all` |
| `grub_timeout` | Boot menu timeout in seconds | `5` |
| `grub_default` | Default boot entry | `0` |
| `grub_cmdline_add` | Kernel parameters to add | `[]` |
| `grub_cmdline_remove` | Kernel parameters to remove | `[]` |
| `grub_password_enable` | Enable GRUB password protection | `false` |
| `grub_password_hash` | Hashed GRUB password (from `grub-mkpasswd-pbkdf2`) | `''` |

## Usage

```bash
ansible-playbook -i inventory/hosts.ini linux/grub-management/playbook.yml \
  -e target_hosts=all

# Add a kernel parameter
ansible-playbook -i inventory/hosts.ini linux/grub-management/playbook.yml \
  -e target_hosts=servers \
  -e '{"grub_cmdline_add": ["mitigations=auto"]}'
```

## Notes

- Changes require `update-grub` (Debian) or `grub2-mkconfig` (RHEL) to take effect, then a reboot.
- Generate GRUB password hash on the controller: `grub-mkpasswd-pbkdf2`
- GRUB password protection prevents unauthorized kernel parameter modification but does not encrypt disk.
- **Always test GRUB changes in a non-production environment first** — incorrect parameters can make the system unbootable.
