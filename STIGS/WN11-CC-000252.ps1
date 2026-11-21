#Requires -Version 5.1
#Requires -RunAsAdministrator

$path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR'
$name = 'AllowGameDVR'

# Create the policy key if it doesn't exist
if (-not (Test-Path -Path $path)) {
    New-Item -Path $path -Force | Out-Null
}

# 0 = Disabled
New-ItemProperty -Path $path -Name $name -PropertyType DWord -Value 0 -Force | Out-Null

# Verify
$value = (Get-ItemProperty -Path $path -Name $name).$name
if ($value -eq 0) {
    Write-Host "AllowGameDVR is set to 0 (Disabled)." -ForegroundColor Green
} else {
    Write-Error "Verification failed. AllowGameDVR is $value."
}
