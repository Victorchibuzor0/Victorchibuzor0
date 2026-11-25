#Requires -Version 5.1
#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Sets "Network security: Minimum session security for NTLM SSP based
    (including secure RPC) servers" to:
      - Require NTLMv2 session security
      - Require 128-bit encryption

.NOTES
    Policy path: Computer Configuration > Windows Settings > Security Settings >
                 Local Policies > Security Options
    Registry:    HKLM\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0 : NtlmMinServerSec (REG_DWORD)
    Value:       0x20080000 (537395200) = 0x00080000 (NTLMv2 session security)
                                        + 0x20000000 (128-bit encryption)
    Works in Windows PowerShell 5.1 (native to Windows 11).
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$regPath   = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0'
$valueName = 'NtlmMinServerSec'

$NTLMv2Session = 0x00080000
$Require128Bit = 0x20000000
$desired       = $NTLMv2Session -bor $Require128Bit   # 0x20080000 = 537395200

# Ensure the key exists (it normally does)
if (-not (Test-Path -Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}

$current = (Get-ItemProperty -Path $regPath -Name $valueName -ErrorAction SilentlyContinue).$valueName
if ($null -eq $current) {
    Write-Host "Current value: <not configured>"
} else {
    Write-Host ("Current value: 0x{0:X8} ({0})" -f [int]$current)
}

Set-ItemProperty -Path $regPath -Name $valueName -Value ([int]$desired) -Type DWord

# Verify
$new = (Get-ItemProperty -Path $regPath -Name $valueName).$valueName
if ([int]$new -eq [int]$desired) {
    Write-Host ("SUCCESS: {0} set to 0x{1:X8} ({1})" -f $valueName, [int]$new) -ForegroundColor Green
    Write-Host "  [x] Require NTLMv2 session security"
    Write-Host "  [x] Require 128-bit encryption"
} else {
    Write-Error ("Verification failed. Expected 0x{0:X8}, found 0x{1:X8}." -f [int]$desired, [int]$new)
}
