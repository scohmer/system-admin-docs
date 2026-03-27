> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — Apache Management

Install and configure Apache HTTP Server with virtual hosts, SSL, and module management.

## Playbook

`playbook.yml`

## Variables (`vars/main.yml`)

| Variable | Description | Default |
|----------|-------------|---------|
| `target_hosts` | Inventory host or group | `all` |
| `apache_vhosts` | List of virtual host configurations | see vars |
| `apache_modules_enable` | Modules to enable (Debian: `a2enmod`) | `[]` |
| `apache_modules_disable` | Modules to disable | `[]` |
| `apache_remove_default` | Remove default welcome page | `true` |
| `apache_firewall_manage` | Open HTTP/HTTPS in firewall | `true` |

## Usage

```bash
ansible-playbook -i inventory/hosts.ini linux/apache-management/playbook.yml \
  -e target_hosts=webservers
```

## Notes

- Service name is `apache2` on Debian/Ubuntu and `httpd` on RHEL/CentOS.
- Configurations are validated with `apachectl configtest` before reloading.
- Module management (`a2enmod`/`a2dismod`) is Debian-specific. On RHEL, modules are enabled via `LoadModule` directives in conf files.
