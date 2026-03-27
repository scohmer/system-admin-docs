> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — Certificate Management

Deploy SSL/TLS certificates to Linux servers and manage the system CA trust store.

## Playbook

`playbook.yml`

## Variables (`vars/main.yml`)

| Variable | Description | Default |
|----------|-------------|---------|
| `target_hosts` | Inventory host or group | `all` |
| `certificates` | List of certificates to deploy | `[]` |
| `ca_certificates` | List of CA certs to add to system trust | `[]` |
| `cert_base_dir` | Base directory for deployed certs | `/etc/ssl/certs/custom` |

### Certificate definition fields

| Field | Description |
|-------|-------------|
| `name` | Certificate name (used in filename) |
| `cert_content` | PEM certificate content (or use `cert_src`) |
| `key_content` | PEM private key content (or use `key_src`) |
| `cert_src` | Local path to certificate file |
| `key_src` | Local path to key file |
| `dest_cert` | Full destination path for certificate |
| `dest_key` | Full destination path for private key |

## Usage

```bash
ansible-playbook -i inventory/hosts.ini linux/certificate-management/playbook.yml \
  -e target_hosts=webservers --ask-vault-pass
```

## Notes

- Private keys are deployed with mode `0600`, owned by root.
- Use Ansible Vault to encrypt `key_content` values in `vars/main.yml`.
- CA certificate deployment updates the system-wide trust store (`update-ca-certificates` on Debian, `update-ca-trust` on RHEL).
