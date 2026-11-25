#Requires -RunAsAdministrator

$path  = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services'
$name  = 'fPromptForPassword'
$value = 1   # 1 = Enabled, 0 = Disabled

# Create the policy key if it doesn't exist
if (-not (Test-Path -Path $path)) {
    New-Item -Path $path -Force | Out-Null
}

# Set the policy value
New-ItemProperty -Path $path -Name $name -Value $value -PropertyType DWord -Force | Out-Null

# Verify
$current = (Get-ItemProperty -Path $path -Name $name).$name
if ($current -eq $value) {
    Write-Output "SUCCESS: $name is set to $current (Enabled)."
} else {
    Write-Error "FAILED: $name is $current, expected $value."
    exit 1
}
