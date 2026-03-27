> **Verification Status:** ❌ Not Verified
> **Approval Status:** ❌ Not Approved
>
> *Verified by:* —
> *Approved by:* —
> *Last reviewed:* —

# Windows — Software Installation via winget

Install, update, and remove software packages using the Windows Package Manager (`winget`).

## Prerequisites

- Windows 10 1809 or later / Windows 11
- `winget` installed (included by default on Windows 11 and recent Windows 10 builds)
  - To check: `winget --version`
  - To install: Download from the [Microsoft Store (App Installer)](https://apps.microsoft.com/detail/9NBLGGH4NNS1)

## Script

`Install-Software.ps1`

**Must be run as Administrator.**

## Usage

```powershell
# Search for a package
.\Install-Software.ps1 -Action Search -PackageId "Google.Chrome"

# Install a single package
.\Install-Software.ps1 -Action Install -PackageId "Google.Chrome"

# Install a specific version
.\Install-Software.ps1 -Action Install -PackageId "Git.Git" -Version "2.43.0"

# Install multiple packages from a list file
.\Install-Software.ps1 -Action InstallList -PackageListFile ".\packages.txt"

# Update a specific package
.\Install-Software.ps1 -Action Update -PackageId "Google.Chrome"

# Update all installed packages
.\Install-Software.ps1 -Action UpdateAll

# Uninstall a package
.\Install-Software.ps1 -Action Uninstall -PackageId "Google.Chrome"

# List all installed packages
.\Install-Software.ps1 -Action List
```

## Package List File Format

Create a plain text file with one package ID per line. Lines starting with `#` are treated as comments:

```
# Browsers
Google.Chrome
Mozilla.Firefox

# Development
Git.Git
Microsoft.VisualStudioCode
Python.Python.3.12
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-Action` | Yes | One of: `Search`, `Install`, `InstallList`, `Update`, `UpdateAll`, `Uninstall`, `List` |
| `-PackageId` | Yes for most | winget package ID (e.g., `Google.Chrome`, `Git.Git`) |
| `-Version` | No | Specific version to install |
| `-PackageListFile` | Yes for InstallList | Path to a text file with one package ID per line |

## Finding Package IDs

```powershell
# Search winget catalog
winget search "visual studio code"

# Or browse the winget package catalog at: https://winget.run
```

## Notes

- `winget` installations run silently (`--silent`) to avoid interactive prompts.
- Some packages may require a reboot after installation.
- Enterprise environments should evaluate deploying packages via Intune, SCCM, or similar MDM tools instead.
