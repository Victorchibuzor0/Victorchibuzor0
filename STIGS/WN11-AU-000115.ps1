#Requires -RunAsAdministrator
$guid = '{0CCE9228-69AE-11D9-BED3-505054503030}'   # Audit Sensitive Privilege Use
$name = 'Audit Sensitive Privilege Use'

$gpRoot   = Join-Path $env:SystemRoot 'System32\GroupPolicy'
$auditDir = Join-Path $gpRoot 'Machine\Microsoft\Windows NT\Audit'
$csv      = Join-Path $auditDir 'audit.csv'
$ini      = Join-Path $gpRoot 'gpt.ini'

# --- 1. audit.csv: this is what gpedit.msc / secpol.msc read ---
New-Item -ItemType Directory -Path $auditDir -Force | Out-Null

$header = 'Machine Name,Policy Target,Subcategory,Subcategory GUID,Inclusion Setting,Exclusion Setting,Setting Value'
$row    = ",System,$name,$guid,Success,,1"      # Setting Value: 1 = Success, 2 = Failure, 3 = both

$existing = @()
if (Test-Path $csv) {
    $existing = @(Get-Content $csv | Where-Object {
        $_.Trim() -ne '' -and $_ -ne $header -and $_ -notlike "*$guid*"
    })
}
Set-Content -Path $csv -Value (@($header) + $existing + $row) -Encoding ASCII

# --- 2. gpt.ini: register the Audit Policy Configuration extension and bump the version ---
$cse   = '{F3CCC681-B74C-4060-9F26-CD84525DCA2A}'
$tool  = '{0F3F3735-573D-9804-99E4-AB2A69BA5FD4}'
$entry = "[$cse$tool]"

$iniLines = @()
if (Test-Path $ini) { $iniLines = @(Get-Content $ini) }

$out = New-Object System.Collections.Generic.List[string]
$sawExt = $false; $sawVer = $false
foreach ($line in $iniLines) {
    if ($line -match '^gPCMachineExtensionNames\s*=(.*)$') {
        $sawExt = $true
        $groups = [string[]]@([regex]::Matches($Matches[1], '\[[^\]]+\]') | ForEach-Object { $_.Value })
        if (-not ($groups | Where-Object { $_.StartsWith("[$cse") })) { $groups += $entry }
        [Array]::Sort($groups, [StringComparer]::Ordinal)
        $out.Add('gPCMachineExtensionNames=' + ($groups -join ''))
    }
    elseif ($line -match '^Version\s*=\s*(\d+)') {
        $sawVer = $true
        $out.Add("Version=$([int]$Matches[1] + 1)")
    }
    else { $out.Add($line) }
}
if ($out.IndexOf('[General]') -lt 0) { $out.Insert(0, '[General]') }
$at = $out.IndexOf('[General]') + 1
if (-not $sawVer) { $out.Insert($at, 'Version=1') }
if (-not $sawExt) { $out.Insert($at, "gPCMachineExtensionNames=$entry") }
Set-Content -Path $ini -Value $out -Encoding ASCII

# --- 3. Apply now ---
gpupdate.exe /target:computer /force | Out-Null
auditpol.exe /set /subcategory:$guid /success:enable /failure:disable | Out-Null

# --- 4. Verify the effective setting ---
auditpol.exe /get /subcategory:$guid /r | ConvertFrom-Csv |
    Select-Object 'Subcategory', 'Inclusion Setting'
