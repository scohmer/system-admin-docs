#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Create, modify, and list local groups and their memberships.
.NOTES
    See README.md for usage. Requires Microsoft.PowerShell.LocalAccounts module (built-in PS 5.1+).
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('List','GetMembers','Create','AddMember','RemoveMember','Delete','Rename')]
    [string]$Action,

    [Parameter()] [string]$GroupName,
    [Parameter()] [string]$MemberName,
    [Parameter()] [string]$Description = '',
    [Parameter()] [string]$NewName
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\..\shared\Write-Log.ps1"
Initialize-Log -ScriptName 'Manage-LocalGroups'

function Get-Group {
    $grp = Get-LocalGroup -Name $GroupName -ErrorAction SilentlyContinue
    if (-not $grp) { throw "Group '$GroupName' not found." }
    return $grp
}

switch ($Action) {

    'List' {
        Write-Status "Local groups on $env:COMPUTERNAME:"
        Get-LocalGroup | Select-Object Name, Description, SID | Sort-Object Name | Format-Table -AutoSize
    }

    'GetMembers' {
        if (-not $GroupName) { throw "-GroupName required." }
        Get-Group | Out-Null
        Write-Status "Members of group '$GroupName':"
        $members = Get-LocalGroupMember -Group $GroupName -ErrorAction SilentlyContinue
        if (-not $members) {
            Write-Status "Group '$GroupName' has no members." 'WARN'
        } else {
            $members | Select-Object Name, ObjectClass, PrincipalSource | Format-Table -AutoSize
        }
    }

    'Create' {
        if (-not $GroupName) { throw "-GroupName required." }
        $existing = Get-LocalGroup -Name $GroupName -ErrorAction SilentlyContinue
        if ($existing) { Write-Status "Group '$GroupName' already exists." 'WARN'; return }
        if ($PSCmdlet.ShouldProcess($GroupName, 'Create local group')) {
            $params = @{ Name = $GroupName }
            if ($Description) { $params['Description'] = $Description }
            New-LocalGroup @params | Out-Null
            Write-Status "Group '$GroupName' created." 'SUCCESS'
        }
    }

    'AddMember' {
        if (-not $GroupName)  { throw "-GroupName required." }
        if (-not $MemberName) { throw "-MemberName required." }
        Get-Group | Out-Null
        if ($PSCmdlet.ShouldProcess($GroupName, "Add member '$MemberName'")) {
            Add-LocalGroupMember -Group $GroupName -Member $MemberName
            Write-Status "'$MemberName' added to group '$GroupName'." 'SUCCESS'
        }
    }

    'RemoveMember' {
        if (-not $GroupName)  { throw "-GroupName required." }
        if (-not $MemberName) { throw "-MemberName required." }
        Get-Group | Out-Null
        if ($PSCmdlet.ShouldProcess($GroupName, "Remove member '$MemberName'")) {
            Remove-LocalGroupMember -Group $GroupName -Member $MemberName
            Write-Status "'$MemberName' removed from group '$GroupName'." 'SUCCESS'
        }
    }

    'Delete' {
        if (-not $GroupName) { throw "-GroupName required." }
        Get-Group | Out-Null
        Write-Status "Deleting group '$GroupName'." 'WARN'
        if ($PSCmdlet.ShouldProcess($GroupName, 'Delete local group')) {
            Remove-LocalGroup -Name $GroupName
            Write-Status "Group '$GroupName' deleted." 'SUCCESS'
        }
    }

    'Rename' {
        if (-not $GroupName) { throw "-GroupName required." }
        if (-not $NewName)   { throw "-NewName required." }
        Get-Group | Out-Null
        if ($PSCmdlet.ShouldProcess($GroupName, "Rename to '$NewName'")) {
            Rename-LocalGroup -Name $GroupName -NewName $NewName
            Write-Status "Group '$GroupName' renamed to '$NewName'." 'SUCCESS'
        }
    }
}
Close-Log
