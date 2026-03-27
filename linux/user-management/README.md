> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — User Management

Create, modify, and remove Linux user accounts and groups across managed hosts using Ansible.

## Playbook

`playbook.yml`

## Variables

Populate `vars/main.yml` before running. All variables are documented below.

| Variable | Type | Required | Description |
|----------|------|----------|-------------|
| `target_hosts` | string | Yes | Ansible inventory group or host to target (e.g., `all`, `webservers`, `db01`) |
| `users_to_create` | list | No | List of users to create (see structure below) |
| `users_to_remove` | list | No | List of usernames to remove |
| `groups_to_create` | list | No | List of group names to create |

### `users_to_create` item structure

```yaml
users_to_create:
  - username: jdoe
    full_name: Jane Doe
    groups:                  # Secondary groups (must exist)
      - sudo
      - developers
    shell: /bin/bash         # Default: /bin/bash
    create_home: true        # Default: true
    ssh_public_key: |        # Optional: adds key to ~/.ssh/authorized_keys
      ssh-ed25519 AAAA...
    password_lock: false     # Set true to lock password login (key auth only)
    state: present           # present or absent
```

### `users_to_remove` structure

```yaml
users_to_remove:
  - username: olduser
    remove_home: true        # Also delete home directory (default: false)
```

## Usage

```bash
# Dry run
ansible-playbook -i /etc/ansible/hosts playbook.yml \
  -e @vars/main.yml --check

# Apply
ansible-playbook -i /etc/ansible/hosts playbook.yml \
  -e @vars/main.yml

# Target a specific host
ansible-playbook -i /etc/ansible/hosts playbook.yml \
  -e @vars/main.yml -l db01
```

## Notes

- The playbook is idempotent: running it multiple times with the same vars produces the same result.
- SSH public keys are added without removing existing keys (`exclusive: false`).
- To grant passwordless sudo, add the user to the `sudo` (Debian/Ubuntu) or `wheel` (RHEL/CentOS) group.
- Password hashes should be used instead of plain text passwords. Generate with:
  ```bash
  python3 -c "import crypt; print(crypt.crypt('YourPassword', crypt.mksalt(crypt.METHOD_SHA512)))"
  ```
