<#
.SYNOPSIS
    Get, set, remove, and append Windows environment variables at Machine, User, or Process scope.
.NOTES
    Machine-scope changes require Administrator. See README.md for usage examples.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('List','Get','Set','Remove','Append')]
    [string]$Action,

    [Parameter()] [string]$Name,
    [Parameter()] [string]$Value,
    [Parameter()]
    [ValidateSet('Machine','User','Process')]
    [string]$Scope = 'Machine'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\..\shared\Write-Log.ps1"
Initialize-Log -ScriptName 'Manage-EnvironmentVariables'

# Broadcast environment change to running processes (Windows message)
function Send-EnvRefresh {
    if ($Scope -ne 'Process') {
        Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class WinMsg {
    [DllImport("user32.dll", SetLastError=true)]
    public static extern IntPtr SendMessageTimeout(IntPtr hWnd, int Msg, IntPtr wParam, string lParam, uint fuFlags, uint uTimeout, out IntPtr lpdwResult);
    public static readonly IntPtr HWND_BROADCAST = new IntPtr(0xffff);
}
"@ -ErrorAction SilentlyContinue
        $res = [IntPtr]::Zero
        [WinMsg]::SendMessageTimeout([WinMsg]::HWND_BROADCAST, 0x001A, [IntPtr]::Zero, 'Environment', 2, 5000, [ref]$res) | Out-Null
    }
}

switch ($Action) {

    'List' {
        Write-Status "Environment variables — Scope: $Scope"
        [System.Environment]::GetEnvironmentVariables([System.EnvironmentVariableTarget]::$Scope).GetEnumerator() |
            Sort-Object Name |
            Select-Object @{N='Name';E={$_.Key}}, @{N='Value';E={$_.Value}} |
            Format-Table -AutoSize -Wrap
    }

    'Get' {
        if (-not $Name) { throw "-Name required." }
        $val = [System.Environment]::GetEnvironmentVariable($Name, [System.EnvironmentVariableTarget]::$Scope)
        if ($null -eq $val) {
            Write-Status "Variable '$Name' not found in $Scope scope." 'WARN'
        } else {
            Write-Host "`n  $Name = $val`n"
        }
    }

    'Set' {
        if (-not $Name)  { throw "-Name required." }
        if ($null -eq $Value) { throw "-Value required." }
        if ($PSCmdlet.ShouldProcess("$Name ($Scope)", "Set environment variable to '$Value'")) {
            [System.Environment]::SetEnvironmentVariable($Name, $Value, [System.EnvironmentVariableTarget]::$Scope)
            Send-EnvRefresh
            Write-Status "Set $Scope\$Name = $Value" 'SUCCESS'
        }
    }

    'Append' {
        if (-not $Name)  { throw "-Name required." }
        if (-not $Value) { throw "-Value required." }
        $current = [System.Environment]::GetEnvironmentVariable($Name, [System.EnvironmentVariableTarget]::$Scope) ?? ''
        # Split by semicolon and check for duplicate
        $entries = $current -split ';' | Where-Object { $_ -ne '' }
        if ($entries -contains $Value) {
            Write-Status "'$Value' is already present in $Name. No change." 'WARN'
        } else {
            $newValue = ($entries + $Value) -join ';'
            if ($PSCmdlet.ShouldProcess("$Name ($Scope)", "Append '$Value'")) {
                [System.Environment]::SetEnvironmentVariable($Name, $newValue, [System.EnvironmentVariableTarget]::$Scope)
                Send-EnvRefresh
                Write-Status "Appended '$Value' to $Scope\$Name" 'SUCCESS'
            }
        }
    }

    'Remove' {
        if (-not $Name) { throw "-Name required." }
        $current = [System.Environment]::GetEnvironmentVariable($Name, [System.EnvironmentVariableTarget]::$Scope)
        if ($null -eq $current) {
            Write-Status "Variable '$Name' not found in $Scope scope." 'WARN'
        } elseif ($PSCmdlet.ShouldProcess("$Name ($Scope)", 'Remove environment variable')) {
            [System.Environment]::SetEnvironmentVariable($Name, $null, [System.EnvironmentVariableTarget]::$Scope)
            Send-EnvRefresh
            Write-Status "Removed $Scope\$Name" 'SUCCESS'
        }
    }
}
Close-Log
