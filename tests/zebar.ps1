param([string]$RepoRoot = (Split-Path $PSScriptRoot -Parent))
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
. "$PSScriptRoot/helpers.ps1"
. "$RepoRoot/lib/settings.ps1"
. "$RepoRoot/lib/files.ps1"
. "$RepoRoot/lib/setup.ps1"
. "$RepoRoot/lib/output.ps1"
Assert-ZebarConfiguration -RepoRoot $RepoRoot
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('zebar-selection-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path "$fixture/config/glzr/zebar","$fixture/widgets/zebar/attaquer-solid-ts" -Force | Out-Null
Copy-Item "$RepoRoot/setup.json" "$fixture/setup.json"
Copy-Item "$RepoRoot/config/glzr/zebar/settings.json" "$fixture/config/glzr/zebar/settings.json"
Copy-Item "$RepoRoot/widgets/zebar/attaquer-solid-ts/zpack.json" "$fixture/widgets/zebar/attaquer-solid-ts/zpack.json"
foreach ($field in @('pack','widget','preset')) {
    $settings = Get-Content "$RepoRoot/config/glzr/zebar/settings.json" -Raw | ConvertFrom-Json
    $settings.startupConfigs[0].$field = 'missing'
    $settings | ConvertTo-Json -Depth 20 | Set-Content "$fixture/config/glzr/zebar/settings.json"
    $threw = $false
    try { Assert-ZebarConfiguration -RepoRoot $fixture } catch { $threw = $true }
    Assert-That $threw "Mismatched Zebar $field was accepted."
}
$config = Get-SetupConfig -RepoRoot $RepoRoot
$config.links = @($config.links | Where-Object source -ne $config.zebar.widget)
$threw = $false
try { Assert-ZebarConfiguration -RepoRoot $RepoRoot -Configuration $config } catch { $threw = $true }
Assert-That $threw 'Missing selected-widget runtime link was accepted.'
$runtime = Join-Path $fixture 'runtime'
$old = Join-Path $fixture 'old-runtime'
New-Item -ItemType Directory -Path $old | Out-Null
Set-Content "$old/keep.txt" 'keep'
New-Item -ItemType Junction -Path $runtime -Target $old | Out-Null
Initialize-ZebarRuntime -RepoRoot $RepoRoot -Destination $runtime
Assert-That (-not (Get-Item $runtime).LinkType) 'Old whole-folder link was not migrated.'
Assert-That (Test-Path "$old/keep.txt") 'Migration changed the old link target.'
Assert-That ((Get-FileHash "$runtime/settings.json").Hash -eq (Get-FileHash "$RepoRoot/config/glzr/zebar/settings.json").Hash) 'Runtime settings were not deployed.'
Initialize-ZebarRuntime -RepoRoot $RepoRoot -Destination $runtime
Assert-That (@(Get-ChildItem $runtime -Filter '*.bak_*').Count -eq 0) 'Rerun backed up unchanged runtime files.'
Write-Host 'Zebar selection and runtime migration tests passed.'

# A copy failure must restore the old whole-directory junction.
$copyRuntime = Join-Path $fixture 'copy-failure'
New-Item -ItemType Junction -Path $copyRuntime -Target $old | Out-Null
function Copy-Item {
    param($LiteralPath, $Destination, [switch]$Force, $ErrorAction)
    if ($Destination -like '*normalize.css') { throw 'simulated copy failure' }
    Microsoft.PowerShell.Management\Copy-Item -LiteralPath $LiteralPath -Destination $Destination -Force:$Force -ErrorAction Stop
}
$threw = $false
try { Initialize-ZebarRuntime -RepoRoot $RepoRoot -Destination $copyRuntime } catch { $threw = $_.Exception.Message -eq 'simulated copy failure' }
Assert-That $threw 'Copy failure was swallowed.'
Assert-That (Test-ConfigLink -Source $old -Destination $copyRuntime) 'Copy failure did not restore the original parent junction.'
Assert-That (Test-Path "$old/keep.txt") 'Copy rollback touched the old link target.'
Remove-Item Function:\Copy-Item

# Failure after the first widget link restores files and existing child links.
$childRuntime = Join-Path $fixture 'child-failure'
New-Item -ItemType Directory -Path $childRuntime | Out-Null
Set-Content "$childRuntime/settings.json" '{"original":true}'
Set-Content "$childRuntime/normalize.css" 'original css'
New-Item -ItemType Junction -Path "$childRuntime/attaquer-buildless" -Target $old | Out-Null
function New-Item {
    param($ItemType, $Path, $Target, [switch]$Force, $ErrorAction)
    if ($ItemType -in @('SymbolicLink','Junction') -and $Path -like '*child-failure*attaquer-solid-ts') { throw 'simulated child link failure' }
    if ($Target) { Microsoft.PowerShell.Management\New-Item -ItemType $ItemType -Path $Path -Target $Target -Force:$Force -ErrorAction Stop }
    else { Microsoft.PowerShell.Management\New-Item -ItemType $ItemType -Path $Path -Force:$Force -ErrorAction Stop }
}
$threw = $false
try { Initialize-ZebarRuntime -RepoRoot $RepoRoot -Destination $childRuntime } catch { $threw = $_.Exception.Message -eq 'simulated child link failure' }
Assert-That $threw 'Child link failure was swallowed.'
Assert-That ((Get-Content "$childRuntime/settings.json" -Raw).Trim() -eq '{"original":true}') 'Child link failure did not restore original settings.'
Assert-That ((Get-Content "$childRuntime/normalize.css" -Raw).Trim() -eq 'original css') 'Child link failure did not restore original stylesheet.'
Assert-That (Test-ConfigLink -Source $old -Destination "$childRuntime/attaquer-buildless") 'Child link failure did not restore the earlier replaced junction.'
Assert-That (-not (Test-Path "$childRuntime/attaquer-solid-ts")) 'Child link failure left a new destination active.'
Remove-Item Function:\New-Item
Write-Host 'Runtime copy and child-link failure rollbacks passed.'
