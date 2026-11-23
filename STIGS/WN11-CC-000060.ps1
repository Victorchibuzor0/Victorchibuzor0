#Requires -RunAsAdministrator

$path  = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WcmSvc\GroupPolicy'
$name  = 'fBlockNonDomain'
$value = 1   # 1 = Enabled

# Create the key if it doesn't exist
if (-not (Test-Path -Path $path)) {
    New-Item -Path $path -Force | Out-Null
}

# Set the policy value
New-ItemProperty -Path $path -Name $name -Value $value -PropertyType DWord -Force | Out-Null

# Verify
$current = (Get-ItemProperty -Path $path -Name $name).$name
if ($current -eq $value) {
    Write-Host "$name is set to $current (Enabled)." -ForegroundColor Green
} else {
    Write-Error "Failed to set $name. Current value: $current"
}
