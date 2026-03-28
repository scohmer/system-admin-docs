#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Manage SMB file shares and share-level permissions.
.NOTES
    See README.md for usage and notes on share vs NTFS permissions.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('List','Show','Create','Remove','GetConnections')]
    [string]$Action,

    [Parameter()] [string]$ShareName,
    [Parameter()] [string]$Path,
    [Parameter()] [string]$Description = '',
    [Parameter()] [string]$FullAccessUsers,
    [Parameter()] [string]$ReadOnlyUsers
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\..\shared\Write-Log.ps1"
Initialize-Log -ScriptName 'Manage-FileShares'

switch ($Action) {

    'List' {
        Write-Status "SMB shares on $env:COMPUTERNAME:"
        Get-SmbShare | Where-Object { $_.Name -notmatch '\$' } |
            Select-Object Name, Path, Description,
                @{N='CurrentUsers';E={(Get-SmbSession -SharedFolderName $_.Name -ErrorAction SilentlyContinue).Count}} |
            Format-Table -AutoSize
        Write-Host "`n(Admin shares ending in $ are hidden from this list)"
    }

    'Show' {
        if (-not $ShareName) { throw "-ShareName required." }
        $share = Get-SmbShare -Name $ShareName -ErrorAction Stop
        $share | Format-List Name, Path, Description, CurrentUsers, EncryptData
        Write-Host "`nShare-level permissions:"
        Get-SmbShareAccess -Name $ShareName | Select-Object AccountName, AccessControlType, AccessRight | Format-Table -AutoSize
    }

    'Create' {
        if (-not $ShareName) { throw "-ShareName required." }
        if (-not $Path)      { throw "-Path required." }
        if (-not (Test-Path $Path)) {
            New-Item -ItemType Directory -Path $Path -Force | Out-Null
            Write-Status "Created directory: $Path"
        }
        if ($PSCmdlet.ShouldProcess($ShareName, "Create SMB share at $Path")) {
            $shareParams = @{
                Name        = $ShareName
                Path        = $Path
                Description = $Description
                FullAccess  = 'Administrators'  # Always give Administrators full control
            }
            New-SmbShare @shareParams | Out-Null
            # Set additional permissions
            if ($FullAccessUsers) {
                Grant-SmbShareAccess -Name $ShareName -AccountName $FullAccessUsers -AccessRight Full -Force | Out-Null
                Write-Status "Full access granted to: $FullAccessUsers"
            }
            if ($ReadOnlyUsers) {
                Grant-SmbShareAccess -Name $ShareName -AccountName $ReadOnlyUsers -AccessRight Read -Force | Out-Null
                Write-Status "Read access granted to: $ReadOnlyUsers"
            }
            Write-Status "Share '$ShareName' created: \\$env:COMPUTERNAME\$ShareName" 'SUCCESS'
        }
    }

    'Remove' {
        if (-not $ShareName) { throw "-ShareName required." }
        if ($PSCmdlet.ShouldProcess($ShareName, 'Remove SMB share')) {
            Write-Status "Removing share '$ShareName' (folder is NOT deleted)..." 'WARN'
            Remove-SmbShare -Name $ShareName -Force
            Write-Status "Share '$ShareName' removed." 'SUCCESS'
        }
    }

    'GetConnections' {
        if (-not $ShareName) { throw "-ShareName required." }
        Write-Status "Active connections to '$ShareName':"
        $sessions = Get-SmbSession -SharedFolderName $ShareName -ErrorAction SilentlyContinue
        if (-not $sessions) {
            Write-Status "No active connections." 'WARN'
        } else {
            $sessions | Select-Object ClientComputerName, ClientUserName, NumOpens, SecondsExists | Format-Table -AutoSize
        }
    }
}
Close-Log
