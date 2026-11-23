#Requires -RunAsAdministrator

$path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging'

# Create the policy key if it doesn't exist
if (-not (Test-Path -Path $path)) {
    New-Item -Path $path -Force | Out-Null
}

# Enable Script Block Logging
New-ItemProperty -Path $path -Name 'EnableScriptBlockLogging' -Value 1 -PropertyType DWord -Force | Out-Null

# Verify
Get-ItemProperty -Path $path -Name 'EnableScriptBlockLogging' |
    Select-Object PSPath, EnableScriptBlockLogging
