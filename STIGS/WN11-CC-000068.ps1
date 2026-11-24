$path  = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation'
$name  = 'AllowProtectedCreds'

# Create the policy key if it doesn't exist
if (-not (Test-Path -Path $path)) {
    New-Item -Path $path -Force | Out-Null
}

# 1 = Enabled
New-ItemProperty -Path $path -Name $name -Value 1 -PropertyType DWord -Force | Out-Null

# Verify
Get-ItemProperty -Path $path -Name $name | Select-Object AllowProtectedCreds
