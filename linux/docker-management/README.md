> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — Docker Management

Install Docker Engine, configure the daemon, manage Docker users, and optionally deploy containers via Docker Compose.

## Playbook

`playbook.yml`

## Variables (`vars/main.yml`)

| Variable | Description | Default |
|----------|-------------|---------|
| `target_hosts` | Inventory host or group | `all` |
| `docker_users` | Linux users to add to the `docker` group | `[]` |
| `docker_daemon_config` | Docker daemon JSON config options | `{}` |
| `docker_compose_projects` | Docker Compose projects to deploy | `[]` |
| `docker_install_compose` | Install Docker Compose v2 plugin | `true` |

## Usage

```bash
ansible-playbook -i inventory/hosts.ini linux/docker-management/playbook.yml \
  -e target_hosts=containerservers
```

## Notes

- Installs Docker from the official Docker apt/dnf repository (not distro packages).
- Adding a user to the `docker` group grants root-equivalent access — restrict to trusted admins.
- `docker_daemon_config` keys map directly to `/etc/docker/daemon.json` settings.
- Docker Compose v2 is installed as a Docker CLI plugin (`docker compose`).
