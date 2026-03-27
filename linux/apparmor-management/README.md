> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — AppArmor Management

Manage AppArmor profiles: enforce, complain, disable, and audit application security profiles.

## Playbook

`playbook.yml`

## Variables (`vars/main.yml`)

| Variable | Description | Default |
|----------|-------------|---------|
| `target_hosts` | Inventory host or group | `all` |
| `apparmor_profiles_enforce` | List of profile paths to set to enforce mode | `[]` |
| `apparmor_profiles_complain` | List of profile paths to set to complain mode | `[]` |
| `apparmor_profiles_disable` | List of profile paths to disable | `[]` |
| `apparmor_extra_packages` | Additional AppArmor packages to install | `[]` |

## Usage

```bash
# Check and apply AppArmor profile configuration
ansible-playbook -i inventory/hosts.ini linux/apparmor-management/playbook.yml \
  -e target_hosts=webservers

# Set a specific profile to complain mode
ansible-playbook -i inventory/hosts.ini linux/apparmor-management/playbook.yml \
  -e target_hosts=webservers \
  -e '{"apparmor_profiles_complain": ["/usr/sbin/nginx"]}'
```

## Notes

- AppArmor is the default MAC system on Debian/Ubuntu. Use SELinux playbook for RHEL/CentOS.
- Complain mode logs violations but does not block them — useful for developing new profiles.
- Enforce mode blocks policy violations and logs them.
- Profiles are located in `/etc/apparmor.d/`.
