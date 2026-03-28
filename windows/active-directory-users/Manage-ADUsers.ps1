#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Manage Active Directory user accounts.

.DESCRIPTION
    Create, disable, enable, unlock, reset passwords, move, assign managers,
    list, and search Active Directory user objects. Requires the RSAT
    ActiveDirectory PowerShell module and appropriate AD permissions.

.PARAMETER Action
    The operation to perform.

.PARAMETER Username
    SAMAccountName of the target user.

.PARAMETER OU
    Distinguished name of the target Organizational Unit.

.PARAMETER DisplayName
    Display name for a new user account.

.PARAMETER Manager
    SAMAccountName of the manager to assign.

.PARAMETER SearchFilter
    LDAP-style filter string for the Search action.

.EXAMPLE
    .\Manage-ADUsers.ps1 -Action List
    .\Manage-ADUsers.ps1 -Action Create -Username jsmith -DisplayName "John Smith" -OU "OU=Users,DC=corp,DC=local"
    .\Manage-ADUsers.ps1 -Action Disable -Username jsmith
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Create', 'Disable', 'Enable', 'Unlock', 'ResetPassword', 'Move', 'SetManager', 'List', 'Search')]
    [string]$Action,

    [string]$Username,
    [string]$OU,
    [string]$DisplayName,
    [string]$Manager,
    [string]$SearchFilter = '*'
)

$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\..\shared\Write-Log.ps1"
Initialize-Log -ScriptName 'Manage-ADUsers'

# ─── Ensure ActiveDirectory module is available ──────────────────────────────
function Assert-ADModule {
    if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
        Write-Status "ActiveDirectory module not found. Install RSAT." 'ERROR'
        Write-Status "Run: Add-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0" 'WARN'
        exit 1
    }
    Import-Module ActiveDirectory -ErrorAction Stop
    Write-Status "ActiveDirectory module loaded." 'SUCCESS'
}

# ─── Helper: require a parameter ────────────────────────────────────────────
function Assert-Param {
    param([string]$Value, [string]$ParamName)
    if ([string]::IsNullOrWhiteSpace($Value)) {
        Write-Status "-$ParamName is required for this action." 'ERROR'
        exit 1
    }
}

# ─── Generate a random compliant password ────────────────────────────────────
function New-RandomPassword {
    $chars = 'abcdefghijklmnopqrstuvwxyz'
    $upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    $digits = '0123456789'
    $special = '!@#$%^&*'
    $all = $chars + $upper + $digits + $special
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    $bytes = New-Object byte[] 16
    $rng.GetBytes($bytes)
    $pw = ($bytes | ForEach-Object { $all[$_ % $all.Length] }) -join ''
    # Ensure at least one of each required character type
    $pw = $pw.Substring(0, 12) + $upper[(Get-Random -Maximum $upper.Length)] +
           $digits[(Get-Random -Maximum $digits.Length)] +
           $special[(Get-Random -Maximum $special.Length)] +
           $chars[(Get-Random -Maximum $chars.Length)]
    return $pw
}

Assert-ADModule

switch ($Action) {

    'List' {
        # Retrieve all enabled user accounts with key attributes
        Write-Status "Listing all AD users..."
        Get-ADUser -Filter * -Properties DisplayName, Department, Title, Enabled, LastLogonDate |
            Select-Object SamAccountName, DisplayName, Department, Title, Enabled, LastLogonDate |
            Sort-Object SamAccountName |
            Format-Table -AutoSize
    }

    'Search' {
        # Search using an LDAP filter expression
        Write-Status "Searching AD users with filter: $SearchFilter"
        try {
            $results = Get-ADUser -Filter $SearchFilter -Properties DisplayName, Department, Enabled, LastLogonDate
            if ($results.Count -eq 0) { Write-Status "No users matched the filter." 'WARN'; return }
            $results | Select-Object SamAccountName, DisplayName, Department, Enabled, LastLogonDate | Format-Table -AutoSize
        }
        catch {
            Write-Status "Filter error: $_" 'ERROR'
        }
    }

    'Create' {
        Assert-Param $Username 'Username'
        Assert-Param $OU 'OU'
        $dn = $DisplayName ? $DisplayName : $Username
        $plainPw = New-RandomPassword
        $securePw = ConvertTo-SecureString $plainPw -AsPlainText -Force

        if ($PSCmdlet.ShouldProcess($Username, 'Create AD User')) {
            New-ADUser `
                -Name $dn `
                -SamAccountName $Username `
                -UserPrincipalName "$Username@$((Get-ADDomain).DNSRoot)" `
                -DisplayName $dn `
                -Path $OU `
                -AccountPassword $securePw `
                -ChangePasswordAtLogon $true `
                -Enabled $true

            Write-Status "User '$Username' created in '$OU'." 'SUCCESS'
            Write-Status "Temporary password: $plainPw" 'WARN'
            Write-Status "User must change password at next logon." 'INFO'
        }
    }

    'Disable' {
        Assert-Param $Username 'Username'
        if ($PSCmdlet.ShouldProcess($Username, 'Disable AD User')) {
            Disable-ADAccount -Identity $Username
            Write-Status "User '$Username' disabled." 'SUCCESS'
        }
    }

    'Enable' {
        Assert-Param $Username 'Username'
        if ($PSCmdlet.ShouldProcess($Username, 'Enable AD User')) {
            Enable-ADAccount -Identity $Username
            Write-Status "User '$Username' enabled." 'SUCCESS'
        }
    }

    'Unlock' {
        Assert-Param $Username 'Username'
        if ($PSCmdlet.ShouldProcess($Username, 'Unlock AD User')) {
            Unlock-ADAccount -Identity $Username
            Write-Status "User '$Username' unlocked." 'SUCCESS'
        }
    }

    'ResetPassword' {
        Assert-Param $Username 'Username'
        # Prompt for new password securely so it never appears in shell history
        $newPw = Read-Host "Enter new password for '$Username'" -AsSecureString
        if ($PSCmdlet.ShouldProcess($Username, 'Reset AD User Password')) {
            Set-ADAccountPassword -Identity $Username -NewPassword $newPw -Reset
            Set-ADUser -Identity $Username -ChangePasswordAtLogon $true
            Write-Status "Password for '$Username' has been reset. User must change at next logon." 'SUCCESS'
        }
    }

    'Move' {
        Assert-Param $Username 'Username'
        Assert-Param $OU 'OU'
        $user = Get-ADUser -Identity $Username
        if ($PSCmdlet.ShouldProcess($Username, "Move to $OU")) {
            Move-ADObject -Identity $user.DistinguishedName -TargetPath $OU
            Write-Status "User '$Username' moved to '$OU'." 'SUCCESS'
        }
    }

    'SetManager' {
        Assert-Param $Username 'Username'
        Assert-Param $Manager 'Manager'
        $managerDN = (Get-ADUser -Identity $Manager).DistinguishedName
        if ($PSCmdlet.ShouldProcess($Username, "Set manager to $Manager")) {
            Set-ADUser -Identity $Username -Manager $managerDN
            Write-Status "Manager for '$Username' set to '$Manager'." 'SUCCESS'
        }
    }
}
Close-Log
