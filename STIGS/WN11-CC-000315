$path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer'
$name = 'AlwaysInstallElevated'

# Create the policy key if it doesn't exist
if (-not (Test-Path -Path $path)) {
    New-Item -Path $path -Force | Out-Null
}

# 0 = Disabled
New-ItemProperty -Path $path -Name $name -Value 0 -PropertyType DWord -Force | Out-Null

# Verify
$value = (Get-ItemProperty -Path $path -Name $name).$name
if ($value -eq 0) {
    Write-Output "Success: $name is set to 0 (Disabled) under $path"
} else {
    Write-Error "Failed: $name is $value, expected 0"
}
