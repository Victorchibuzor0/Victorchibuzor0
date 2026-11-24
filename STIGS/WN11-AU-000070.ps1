#Requires -RunAsAdministrator

# Subcategory: Logon/Logoff >> Audit Logon
$logonGuid = '{0CCE9215-69AE-11D9-BED3-505054503030}'

# Failure only: success disabled, failure enabled
auditpol.exe /set /subcategory:$logonGuid /success:disable /failure:enable
if ($LASTEXITCODE -ne 0) { throw "auditpol failed with exit code $LASTEXITCODE" }

# Verify
$result = auditpol.exe /get /subcategory:$logonGuid /r |
    Where-Object { $_ } | ConvertFrom-Csv

if ($result.'Inclusion Setting' -eq 'Failure') {
    Write-Host "Audit Logon is set to: Failure" -ForegroundColor Green
} else {
    Write-Warning "Audit Logon is currently: $($result.'Inclusion Setting')"
}
