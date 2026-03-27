#Requires -RunAsAdministrator
<#
.SYNOPSIS
    View, add, and remove NTFS access control entries on files and folders.
.NOTES
    See README.md for usage examples and important notes on Deny ACEs.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Get','Add','Remove','DisableInheritance','EnableInheritance')]
    [string]$Action,

    [Parameter(Mandatory)]
    [string]$Path,

    [Parameter()]
    [string]$Identity,

    [Parameter()]
    [ValidateSet('FullControl','Modify','ReadAndExecute','Read','Write','ListDirectory')]
    [string]$Rights = 'ReadAndExecute',

    [Parameter()]
    [ValidateSet('Allow','Deny')]
    [string]$AccessType = 'Allow',

    [Parameter()]
    [switch]$Recurse
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Status {
    param([string]$Message, [string]$Level = 'INFO')
    $color = switch ($Level) { 'SUCCESS' { 'Green' }; 'WARN' { 'Yellow' }; 'ERROR' { 'Red' }; default { 'Cyan' } }
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')][$Level] $Message" -ForegroundColor $color
}

if (-not (Test-Path $Path)) { throw "Path not found: $Path" }

function Apply-ACL {
    param([string]$TargetPath, [System.Security.AccessControl.FileSystemSecurity]$NewACL)
    Set-Acl -Path $TargetPath -AclObject $NewACL
}

switch ($Action) {

    'Get' {
        Write-Status "NTFS permissions on: $Path"
        $acl = Get-Acl -Path $Path
        Write-Host "`n  Owner: $($acl.Owner)"
        Write-Host "  Inheritance: $(if ($acl.AreAccessRulesProtected) { 'Disabled (explicit)' } else { 'Enabled (inherited from parent)' })`n"
        $acl.Access | Select-Object @{N='Identity';E={$_.IdentityReference}},
            FileSystemRights, AccessControlType,
            @{N='Inherited';E={$_.IsInherited}} |
            Format-Table -AutoSize
    }

    'Add' {
        if (-not $Identity) { throw "-Identity required." }
        $targets = if ($Recurse) {
            @($Path) + (Get-ChildItem $Path -Recurse -Force | Select-Object -ExpandProperty FullName)
        } else { @($Path) }

        foreach ($target in $targets) {
            if ($PSCmdlet.ShouldProcess($target, "Add $AccessType '$Rights' for $Identity")) {
                $acl = Get-Acl -Path $target
                $rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
                    $Identity, $Rights,
                    'ContainerInherit,ObjectInherit',
                    'None',
                    $AccessType
                )
                $acl.AddAccessRule($rule)
                Set-Acl -Path $target -AclObject $acl
            }
        }
        Write-Status "Added $AccessType '$Rights' for '$Identity' on $Path$(if ($Recurse) { ' (recursive)' })" 'SUCCESS'
    }

    'Remove' {
        if (-not $Identity) { throw "-Identity required." }
        $targets = if ($Recurse) {
            @($Path) + (Get-ChildItem $Path -Recurse -Force | Select-Object -ExpandProperty FullName)
        } else { @($Path) }

        foreach ($target in $targets) {
            if ($PSCmdlet.ShouldProcess($target, "Remove permissions for $Identity")) {
                $acl = Get-Acl -Path $target
                $acl.Access | Where-Object { $_.IdentityReference -like "*$Identity*" } |
                    ForEach-Object { $acl.RemoveAccessRule($_) | Out-Null }
                Set-Acl -Path $target -AclObject $acl
            }
        }
        Write-Status "Removed all ACEs for '$Identity' on $Path" 'SUCCESS'
    }

    'DisableInheritance' {
        if ($PSCmdlet.ShouldProcess($Path, 'Disable NTFS inheritance (copy existing ACEs)')) {
            $acl = Get-Acl -Path $Path
            # $true = preserve inherited rules as explicit; $false = remove them
            $acl.SetAccessRuleProtection($true, $true)
            Set-Acl -Path $Path -AclObject $acl
            Write-Status "Inheritance disabled on '$Path'. Existing inherited ACEs copied as explicit." 'SUCCESS'
        }
    }

    'EnableInheritance' {
        if ($PSCmdlet.ShouldProcess($Path, 'Enable NTFS inheritance')) {
            $acl = Get-Acl -Path $Path
            $acl.SetAccessRuleProtection($false, $false)
            Set-Acl -Path $Path -AclObject $acl
            Write-Status "Inheritance enabled on '$Path'." 'SUCCESS'
        }
    }
}
