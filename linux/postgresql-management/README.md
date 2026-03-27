> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — PostgreSQL Management

Install and configure PostgreSQL, manage databases, roles (users), and pg_hba authentication.

## Playbook

`playbook.yml`

## Prerequisites

```bash
pip install psycopg2-binary
```

## Variables (`vars/main.yml`)

| Variable | Description | Default |
|----------|-------------|---------|
| `target_hosts` | Inventory host or group | `all` |
| `postgresql_version` | PostgreSQL major version | `15` |
| `postgresql_databases` | List of databases to create | `[]` |
| `postgresql_roles` | List of PostgreSQL roles to create | `[]` |
| `postgresql_hba_entries` | List of pg_hba.conf entries | `[]` |
| `postgresql_listen_addresses` | Listen addresses | `localhost` |

## Usage

```bash
ansible-playbook -i inventory/hosts.ini linux/postgresql-management/playbook.yml \
  -e target_hosts=dbservers --ask-vault-pass
```

## Notes

- Uses the `community.postgresql` collection.
- PostgreSQL roles serve as both users and groups.
- `pg_hba.conf` controls client authentication — changes require a service reload.
- Use Ansible Vault for all passwords.
