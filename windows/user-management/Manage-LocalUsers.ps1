#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Manage local Windows user accounts.

.DESCRIPTION
    Create, modify, disable, enable, reset passwords, remove local users,
    and manage local group membership.

.NOTES
    Requires Administrator privileges.
    See README.md for usage examples and full parameter documentation.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Create','Disable','Enable','ResetPassword','AddToGroup','RemoveFromGroup','Remove','List')]
    [string]$Action,

    [Parameter()]
    [string]$Username,

    [Parameter()]
    [string]$FullName = '',

    [Parameter()]
    [string]$Description = '',

    [Parameter()]
    [string]$GroupName
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\..\shared\Write-Log.ps1"
Initialize-Log -ScriptName 'Manage-LocalUsers'

function Assert-Username {
    if (-not $Username) {
        throw "Parameter -Username is required for action '$Action'."
    }
}

switch ($Action) {

    'Create' {
        Assert-Username
        Write-Status "Creating local user '$Username'..."
        $password = Read-Host -Prompt "Enter password for '$Username'" -AsSecureString
        $params = @{
            Name        = $Username
            Password    = $password
            FullName    = $FullName
            Description = $Description
            AccountNeverExpires = $true
            PasswordNeverExpires = $false
        }
        if ($PSCmdlet.ShouldProcess($Username, 'Create local user')) {
            New-LocalUser @params | Out-Null
            Write-Status "User '$Username' created successfully." 'SUCCESS'
        }
    }

    'Disable' {
        Assert-Username
        Write-Status "Disabling local user '$Username'..."
        if ($PSCmdlet.ShouldProcess($Username, 'Disable local user')) {
            Disable-LocalUser -Name $Username
            Write-Status "User '$Username' disabled." 'SUCCESS'
        }
    }

    'Enable' {
        Assert-Username
        Write-Status "Enabling local user '$Username'..."
        if ($PSCmdlet.ShouldProcess($Username, 'Enable local user')) {
            Enable-LocalUser -Name $Username
            Write-Status "User '$Username' enabled." 'SUCCESS'
        }
    }

    'ResetPassword' {
        Assert-Username
        Write-Status "Resetting password for '$Username'..."
        $password = Read-Host -Prompt "Enter new password for '$Username'" -AsSecureString
        if ($PSCmdlet.ShouldProcess($Username, 'Reset local user password')) {
            Set-LocalUser -Name $Username -Password $password
            Write-Status "Password for '$Username' reset successfully." 'SUCCESS'
        }
    }

    'AddToGroup' {
        Assert-Username
        if (-not $GroupName) { throw "Parameter -GroupName is required for action 'AddToGroup'." }
        Write-Status "Adding '$Username' to group '$GroupName'..."
        if ($PSCmdlet.ShouldProcess($Username, "Add to group '$GroupName'")) {
            Add-LocalGroupMember -Group $GroupName -Member $Username
            Write-Status "User '$Username' added to '$GroupName'." 'SUCCESS'
        }
    }

    'RemoveFromGroup' {
        Assert-Username
        if (-not $GroupName) { throw "Parameter -GroupName is required for action 'RemoveFromGroup'." }
        Write-Status "Removing '$Username' from group '$GroupName'..."
        if ($PSCmdlet.ShouldProcess($Username, "Remove from group '$GroupName'")) {
            Remove-LocalGroupMember -Group $GroupName -Member $Username
            Write-Status "User '$Username' removed from '$GroupName'." 'SUCCESS'
        }
    }

    'Remove' {
        Assert-Username
        Write-Status "Removing local user '$Username'..." 'WARN'
        Write-Host "WARNING: This action is irreversible." -ForegroundColor Red
        $confirm = Read-Host "Type the username '$Username' to confirm removal"
        if ($confirm -ne $Username) {
            Write-Status "Confirmation did not match. Aborting." 'WARN'
            exit 1
        }
        if ($PSCmdlet.ShouldProcess($Username, 'Remove local user')) {
            Remove-LocalUser -Name $Username
            Write-Status "User '$Username' removed." 'SUCCESS'
        }
    }

    'List' {
        Write-Status "Listing all local users..."
        Get-LocalUser | Select-Object Name, FullName, Enabled, LastLogon, Description |
            Format-Table -AutoSize
    }
}
Close-Log
