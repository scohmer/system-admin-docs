> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — SSH Hardening

Apply SSH daemon hardening best practices across managed hosts using Ansible.

## Playbook

`playbook.yml`

## Variables

Populate `vars/main.yml` before running.

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `target_hosts` | string | Yes | — | Ansible inventory group or host |
| `ssh_port` | int | No | `22` | SSH listening port |
| `ssh_permit_root_login` | string | No | `no` | `yes`, `no`, `prohibit-password`, `forced-commands-only` |
| `ssh_password_authentication` | string | No | `no` | `yes` or `no` |
| `ssh_pubkey_authentication` | string | No | `yes` | `yes` or `no` |
| `ssh_max_auth_tries` | int | No | `3` | Maximum authentication attempts per connection |
| `ssh_client_alive_interval` | int | No | `300` | Seconds between keepalive messages |
| `ssh_client_alive_count_max` | int | No | `2` | Keepalives before disconnecting idle sessions |
| `ssh_allow_users` | list | No | `[]` | If set, only these users can SSH in (leave empty to allow all) |
| `ssh_allow_groups` | list | No | `[]` | If set, only these groups can SSH in |
| `ssh_banner_message` | string | No | `""` | Logon banner text (written to `/etc/issue.net`) |

## Usage

```bash
# IMPORTANT: Test in check mode first to verify you won't lose SSH access
ansible-playbook -i /etc/ansible/hosts playbook.yml \
  -e @vars/main.yml --check

# Apply
ansible-playbook -i /etc/ansible/hosts playbook.yml \
  -e @vars/main.yml
```

## Hardening Applied

| Setting | Hardened Value | Reason |
|---------|---------------|--------|
| `PermitRootLogin` | `no` | Prevents direct root access |
| `PasswordAuthentication` | `no` | Requires key-based authentication |
| `X11Forwarding` | `no` | Reduces attack surface |
| `MaxAuthTries` | `3` | Limits brute-force attempts |
| `Protocol` | `2` | Disables insecure SSHv1 |
| `PermitEmptyPasswords` | `no` | Blocks empty password logins |
| `ClientAliveInterval` | `300` | Disconnects idle sessions |
| `AllowAgentForwarding` | `no` | Prevents agent hijacking |
| `AllowTcpForwarding` | `no` | Prevents tunneling abuse |

## CRITICAL Notes

- **Ensure key-based auth works before setting `PasswordAuthentication no`** — you will be locked out if your key is not in place.
- **Ensure your user is in `ssh_allow_users` or `ssh_allow_groups`** before setting these restrictions.
- **Ensure port 22 (or `ssh_port`) is open in the firewall** before restarting sshd.
- The sshd service is validated with `sshd -t` before restarting to prevent a broken config from cutting off access.
