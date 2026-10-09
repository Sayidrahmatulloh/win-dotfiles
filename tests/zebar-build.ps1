param([string]$RepoRoot = (Split-Path $PSScriptRoot -Parent))
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
. "$PSScriptRoot/helpers.ps1"
. "$RepoRoot/lib/utils.ps1"
. "$RepoRoot/lib/setup.ps1"
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('staged-build-' + [guid]::NewGuid().ToString('N'))
$widget = Join-Path $fixture 'widgets/zebar/attaquer-solid-ts'
New-Item -ItemType Directory -Path "$widget/src/fonts","$widget/dist","$fixture/tools" -Force | Out-Null
Copy-Item "$RepoRoot/setup.json" "$fixture/setup.json"
Set-Content "$widget/package.json" '{}'
Set-Content "$widget/src/fonts/CaskaydiaMonoNerdFont-Regular.ttf" 'fixture font'
Set-Content "$widget/dist/index.html" 'old build'
@'
param($RepoRoot, $BuildDirectory)
$ErrorActionPreference = 'Stop'
if (-not (Test-Path "$BuildDirectory/validated.txt")) { throw 'simulated asset validation failure' }
'@ | Set-Content "$fixture/tools/check-desktop-build.ps1"
$script:buildMode = 'build-failure'
function bun {
    if ($args[0] -eq 'install') { $global:LASTEXITCODE = 0; return }
    $output = $args[([array]::IndexOf($args, '--outDir') + 1)]
    New-Item -ItemType Directory -Path $output -Force | Out-Null
    Set-Content "$output/index.html" 'new build'
    if ($script:buildMode -eq 'build-failure') { $global:LASTEXITCODE = 1; return }
    if ($script:buildMode -ne 'validation-failure') { Set-Content "$output/validated.txt" 'validated' }
    $global:LASTEXITCODE = 0
}
foreach ($mode in @('build-failure','validation-failure')) {
    $script:buildMode = $mode
    $threw = $false
    try { Build-Zebar -RepoRoot $fixture } catch { $threw = $true }
    Assert-That $threw "Build mode $mode did not fail."
    Assert-That ((Get-Content "$widget/dist/index.html" -Raw).Trim() -eq 'old build') "$mode changed the active build."
    Assert-That (@(Get-ChildItem $widget -Directory -Filter '.dist-stage-*').Count -eq 0) "$mode left a staged build."
}
$script:buildMode = 'success'
$script:failActivation = $true
function Move-Item {
    param($LiteralPath, $Destination, $ErrorAction)
    if ($script:failActivation -and (Split-Path $LiteralPath -Leaf) -like '.dist-stage-*') {
        $script:failActivation = $false
        throw 'simulated activation failure'
    }
    Microsoft.PowerShell.Management\Move-Item -LiteralPath $LiteralPath -Destination $Destination -ErrorAction Stop
}
$threw = $false
try { Build-Zebar -RepoRoot $fixture } catch { $threw = $_.Exception.Message -eq 'simulated activation failure' }
Assert-That $threw 'Activation failure was swallowed.'
Assert-That ((Get-Content "$widget/dist/index.html" -Raw).Trim() -eq 'old build') 'Activation failure did not restore the old build.'
Remove-Item Function:\Move-Item
Build-Zebar -RepoRoot $fixture
Assert-That ((Get-Content "$widget/dist/index.html" -Raw).Trim() -eq 'new build') 'Validated build was not activated.'
$backups = @(Get-ChildItem $widget -Directory -Filter '.dist-backup-*')
Assert-That ($backups.Count -eq 1 -and (Get-Content "$($backups[0].FullName)/index.html" -Raw).Trim() -eq 'old build') 'Previous build was not retained.'
Assert-That (@(Get-ChildItem $widget -Directory -Filter '.dist-stage-*').Count -eq 0) 'Success left a staged build.'
Write-Host 'Staged build failure, validation, activation rollback and success tests passed.'
