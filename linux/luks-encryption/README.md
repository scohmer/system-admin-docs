> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Linux — LUKS Encryption

Encrypt block devices with LUKS2, manage crypttab entries, create filesystems, and mount encrypted volumes.

## Playbook

`playbook.yml`

## Variables (`vars/main.yml`)

| Variable | Description | Default |
|----------|-------------|---------|
| `target_hosts` | Inventory host or group | `all` |
| `luks_devices` | List of LUKS device definitions | see below |
| `luks_devices[].device` | Block device path to encrypt (e.g. `/dev/sdb`) | — |
| `luks_devices[].name` | Name for the mapped device under `/dev/mapper/` | — |
| `luks_devices[].passphrase` | LUKS passphrase — use Ansible Vault in production | `changeme` |
| `luks_devices[].filesystem` | Filesystem type to create on the mapped device | `ext4` |
| `luks_devices[].mount_point` | Path where the encrypted volume will be mounted | — |
| `luks_devices[].mount_options` | Mount options passed to `/etc/fstab` | `defaults,noatime` |
| `luks_devices[].crypttab_options` | Options written to `/etc/crypttab` | `luks` |
| `luks_devices[].initialize` | Run `luksFormat` to initialize the device (destructive!) | `false` |
| `luks_keyfile_dir` | Directory for storing LUKS keyfiles | `/etc/luks-keys` |

## Usage

```bash
ansible-playbook -i inventory/hosts.ini linux/luks-encryption/playbook.yml
```

## Important Notes

- **`initialize: true` is destructive.** It will run `luksFormat` on the target device, permanently erasing all existing data. Only set this flag on the very first run when setting up a new device. Set it back to `false` immediately after initialization to prevent data loss on subsequent runs.

- **Store passphrases in Ansible Vault.** Never commit plaintext passphrases to `vars/main.yml`. Encrypt the variable file or individual values with `ansible-vault`:
  ```bash
  ansible-vault encrypt_string 'mysecretpassphrase' --name 'passphrase'
  ```
  Then run the playbook with `--ask-vault-pass` or a vault password file.

- **Automatic unlock on reboot is not configured by default.** The `/etc/crypttab` entry uses `none` as the keyfile, which requires manual passphrase entry at boot. For unattended unlock, either:
  - Place a keyfile in `{{ luks_keyfile_dir }}` and reference it in `crypttab_options`, or
  - Use `clevis` with a TPM2 or Tang server for network-bound disk encryption (NBDE).
