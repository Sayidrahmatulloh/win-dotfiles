param([string]$RepoRoot = (Split-Path $PSScriptRoot -Parent))
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
. "$PSScriptRoot\helpers.ps1"
. "$RepoRoot\lib\settings.ps1"
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('settings-test-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $fixture | Out-Null
function Assert-InvalidManifest {
    param([scriptblock]$Change, [string]$Expected)
    $data = Get-Content (Join-Path $RepoRoot 'setup.json') -Raw | ConvertFrom-Json
    & $Change $data
    $data | ConvertTo-Json -Depth 10 | Set-Content (Join-Path $fixture 'setup.json')
    $message = $null
    try { Get-SetupConfig $fixture | Out-Null } catch { $message = $_.Exception.Message }
    Assert-That ($message -and $message.Contains($Expected)) "Invalid configuration was not rejected: $Expected"
}
Assert-InvalidManifest { param($data) $data.PSObject.Properties.Remove('zebar') } 'Missing required'
Assert-InvalidManifest { param($data) $data.scoop.packages = 'git' } 'JSON array'
Assert-InvalidManifest { param($data) $data.winget = @('App.One','App.One') } 'duplicate'
Assert-InvalidManifest { param($data) $data.links[0].root = 'UNKNOWN_ROOT' } 'Link root'
Assert-InvalidManifest { param($data) $data.links[0].destination = '../outside' } 'relative path'
Assert-InvalidManifest { param($data) $data.zebar.widget = 'C:\outside' } 'relative path'
Assert-InvalidManifest { param($data) $data.requiredCommands = @('') } 'non-empty strings'
$moduleDir = Join-Path $fixture 'config/powershell'
New-Item -ItemType Directory -Path $moduleDir -Force | Out-Null
Set-Content (Join-Path $moduleDir 'modules.json') '["PSFzf"]'
Assert-That (@(Get-PowerShellModules $fixture).Count -eq 1) 'One-item module array was rejected.'
Set-Content (Join-Path $moduleDir 'modules.json') '[]'
Assert-That (@(Get-PowerShellModules $fixture).Count -eq 0) 'Empty module array was rejected.'
Set-Content (Join-Path $moduleDir 'modules.json') '"PSFzf"'
$threw = $false
try { Get-PowerShellModules $fixture | Out-Null } catch { $threw = $true }
Assert-That $threw 'Module string was accepted as an array.'
Write-Host 'Configuration validation tests passed.'