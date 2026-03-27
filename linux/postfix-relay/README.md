> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — Postfix Email Relay

Configure Postfix as a mail relay (smarthost) for sending system alerts and application emails through a relay server or SMTP service.

## Playbook

`playbook.yml`

## Variables (`vars/main.yml`)

| Variable | Description | Default |
|----------|-------------|---------|
| `target_hosts` | Inventory host or group | `all` |
| `postfix_myhostname` | FQDN of this mail server | `ansible_fqdn` |
| `postfix_mydomain` | Domain for this server | `corp.local` |
| `postfix_relayhost` | SMTP relay server `[host]:port` | `''` |
| `postfix_relay_user` | SASL username for relay authentication | `''` |
| `postfix_relay_password` | SASL password (use Vault) | `''` |
| `postfix_inet_interfaces` | Interfaces to listen on | `loopback-only` |
| `postfix_root_alias` | Email address for root mail | `''` |

## Usage

```bash
ansible-playbook -i inventory/hosts.ini linux/postfix-relay/playbook.yml \
  -e target_hosts=all --ask-vault-pass

# Test after deployment:
# echo "Test email body" | mail -s "Test subject" admin@corp.local
```

## Notes

- `loopback-only` interface setting restricts Postfix to accepting mail from localhost only — appropriate for a relay-only configuration.
- SASL credentials are stored in `/etc/postfix/sasl_passwd` and converted to a Berkeley DB map with `postmap`.
- For sending through Gmail, use `[smtp.gmail.com]:587` as relayhost and an App Password.
- TLS is enabled by default with `may` — use `encrypt` to require TLS.
