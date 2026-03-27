> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — Nginx Management

Install and configure Nginx web server with virtual hosts, SSL, and security headers.

## Playbook

`playbook.yml`

## Variables (`vars/main.yml`)

| Variable | Description | Default |
|----------|-------------|---------|
| `target_hosts` | Inventory host or group | `all` |
| `nginx_vhosts` | List of virtual host configurations | see vars |
| `nginx_remove_default` | Remove the default site | `true` |
| `nginx_firewall_manage` | Open HTTP/HTTPS in firewall | `true` |
| `nginx_worker_processes` | Worker processes (`auto` or number) | `auto` |

## Usage

```bash
ansible-playbook -i inventory/hosts.ini linux/nginx-management/playbook.yml \
  -e target_hosts=webservers
```

## Notes

- Configuration files are validated with `nginx -t` before service reload.
- Virtual host configs are placed in `/etc/nginx/sites-available/` (Debian) or `/etc/nginx/conf.d/` (RedHat).
- SSL certificate paths must exist on the target — use `certificate-management` playbook first.
