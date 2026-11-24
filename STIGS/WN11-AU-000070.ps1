$dir  = "$env:SystemRoot\System32\GroupPolicy"
$csv  = "$dir\Machine\Microsoft\Windows NT\Audit\audit.csv"
$ini  = "$dir\gpt.ini"
$guid = '{0cce9215-69ae-11d9-bed3-505054503030}'

# Backups
Copy-Item $csv "$csv.bak" -Force
if (Test-Path $ini) { Copy-Item $ini "$ini.bak" -Force }

# 1. Replace any existing Logon row with Failure (Setting Value 2 = Failure)
$lines = Get-Content $csv | Where-Object { $_.Trim() -and $_ -notmatch [regex]::Escape($guid) }
$lines += ",System,Audit Logon,$guid,Failure,,2"
Set-Content -Path $csv -Value $lines -Encoding ASCII

# 2. Bump the policy version in gpt.ini
if (Test-Path $ini) {
    $text = Get-Content $ini -Raw
    if ($text -match 'Version=(\d+)') {
        $text = $text -replace 'Version=\d+', "Version=$([int]$Matches[1] + 1)"
    } else {
        $text = $text.TrimEnd() + "`r`nVersion=1`r`n"
    }
    Set-Content -Path $ini -Value $text -Encoding ASCII
} else {
    Set-Content -Path $ini -Value "[General]`r`nVersion=1" -Encoding ASCII
}

# 3. Apply and verify
gpupdate /force | Out-Null
auditpol /get /subcategory:$guid
Get-Content $csv
