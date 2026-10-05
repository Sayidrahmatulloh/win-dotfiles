# Exercise the install entry point with stubbed stages; no real installer runs.
param([string]$RepoRoot = (Split-Path $PSScriptRoot -Parent))
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
. "$PSScriptRoot\helpers.ps1"
. "$RepoRoot\lib\settings.ps1"
Invoke-Expression (Read-Functions 'install.ps1')
$principal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
if ($principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host 'Install control-flow tests skipped in elevated process.'
    exit 0
}
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('install-test-' + [guid]::NewGuid().ToString('N'))
$DOTFILES = Join-Path $fixture 'repo'
$library = Join-Path $DOTFILES 'lib'
New-Item -ItemType Directory -Path $library -Force | Out-Null
Copy-Item -LiteralPath (Join-Path $RepoRoot 'setup.json') -Destination (Join-Path $DOTFILES 'setup.json')
$moduleDir = Join-Path $DOTFILES 'config/powershell'
New-Item -ItemType Directory -Path $moduleDir -Force | Out-Null
Copy-Item -LiteralPath (Join-Path $RepoRoot 'config/powershell/modules.json') -Destination (Join-Path $moduleDir 'modules.json')
$fakeHelpers = @(
    'function Write-Banner {}'
    'function Invoke-Step { param($Name, $Block); $script:stageNames += $Name; [pscustomobject]@{ Name=$Name; Success=($Name -ne $script:failingStage); Message="stubbed stage" } }'
) -join "`n"
[IO.File]::WriteAllText((Join-Path $library 'utils.ps1'), $fakeHelpers)
Copy-Item -LiteralPath (Join-Path $RepoRoot 'lib/setup.ps1') -Destination (Join-Path $library 'setup.ps1')
function Install-Scoop {}
function Sync-Repo {}
function Refresh-SetupEnvironment {}
function Start-Transcript { param($Path) }
function Stop-Transcript {}
$previousLocalAppData = $env:LOCALAPPDATA
try {
    $env:LOCALAPPDATA = $fixture
    $script:stageNames = @()
    $script:failingStage = ''
    $exitCode = Main
    $expected = @('Scoop packages','Winget apps','Fonts','PS modules','Symlinks','Git config','Windows Terminal','Build Zebar widget')
    Assert-That ($exitCode -eq 0) 'Successful setup did not return 0.'
    Assert-That (($script:stageNames -join ',') -eq ($expected -join ',')) 'Setup stage order changed.'
    $script:stageNames = @()
    $script:failingStage = 'Fonts'
    $exitCode = Main
    Assert-That ($exitCode -eq 1) 'Failed setup did not return 1.'
    Assert-That (($script:stageNames -join ',') -eq ($expected -join ',')) 'Failed stage prevented later stages.'
} finally { $env:LOCALAPPDATA = $previousLocalAppData }
Write-Host 'Install entry-point tests passed.'
