<#
.SYNOPSIS
    This PowerShell script ensures that the maximum size of the Windows Application event log is at least 32768 KB (32 MB).

.NOTES
    Author          : Victor Chibuzor
    LinkedIn        : linkedin.com/in/victorchibuzorifeanyi/
    GitHub          : github.com/Victorchibuzor0
    Date Created    : 2026-11-19
    Last Modified   : 2026-11-19
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-AU-000500
    Documentation   : https://stigaview.com/products/win11/v2r7/WN11-AU-000500/

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\__remediation_template(STIG-ID-WN10-AU-000500).ps1 
#>

$path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Application'

# Create the key if it doesn't exist (New-Item -Force also creates missing parent keys)
if (-not (Test-Path -Path $path)) {
    New-Item -Path $path -Force | Out-Null
}

# 0x00008000 = 32768 KB (32 MB)
New-ItemProperty -Path $path -Name 'MaxSize' -Value 0x8000 -PropertyType DWord -Force | Out-Null
