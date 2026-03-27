> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — MySQL / MariaDB Management

Install and configure MySQL or MariaDB, manage databases, users, and privileges.

## Playbook

`playbook.yml`

## Prerequisites

```bash
# Ansible controller needs the PyMySQL library
pip install PyMySQL
```

## Variables (`vars/main.yml`)

| Variable | Description | Default |
|----------|-------------|---------|
| `target_hosts` | Inventory host or group | `all` |
| `mysql_root_password` | MySQL root password (use Vault) | — |
| `mysql_databases` | List of databases to create | `[]` |
| `mysql_users` | List of MySQL users to create | `[]` |
| `mysql_bind_address` | Interface to listen on | `127.0.0.1` |
| `mysql_firewall_manage` | Open MySQL port if bind is not localhost | `false` |

## Usage

```bash
ansible-playbook -i inventory/hosts.ini linux/mysql-management/playbook.yml \
  -e target_hosts=dbservers --ask-vault-pass
```

## Notes

- Passwords should be encrypted with Ansible Vault — never stored in plaintext.
- The root password is set using `mysql_secure_installation` equivalent tasks.
- `mysql_bind_address: 0.0.0.0` allows remote connections — only use with firewall rules restricting access.
