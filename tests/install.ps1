# Exercise the install entry point with stubbed stages; no real installer runs.
param([string]$RepoRoot = (Split-Path $PSScriptRoot -Parent))
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
. "$PSScriptRoot\helpers.ps1"
. "$RepoRoot\lib\settings.ps1"
Invoke-Expression (Read-Functions 'install.ps1')
$Only=@(); $Skip=@()
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
$themeScripts = Join-Path $DOTFILES 'scripts/theme'
New-Item -ItemType Directory -Path $themeScripts -Force | Out-Null
Copy-Item -LiteralPath (Join-Path $RepoRoot 'scripts/theme/ThemeConfig.ps1') -Destination $themeScripts
Copy-Item -LiteralPath (Join-Path $RepoRoot 'themes') -Destination $DOTFILES -Recurse
$zebarSettings = Join-Path $DOTFILES 'config/glzr/zebar'
$widgetManifest = Join-Path $DOTFILES (Get-SetupConfig -RepoRoot $RepoRoot).zebar.widget
New-Item -ItemType Directory -Path $zebarSettings,$widgetManifest -Force | Out-Null
Copy-Item "$RepoRoot/config/glzr/zebar/settings.json" $zebarSettings
Copy-Item (Join-Path $RepoRoot ((Get-SetupConfig -RepoRoot $RepoRoot).zebar.widget + '/zpack.json')) $widgetManifest
function Install-Scoop { $script:scoopBootstrapCalls++ }
function Sync-Repo {}
function Refresh-SetupEnvironment {}
function Start-Transcript { param($Path) }
function Stop-Transcript {}
$previousLocalAppData = $env:LOCALAPPDATA
try {
    $env:LOCALAPPDATA = $fixture
    $script:scoopBootstrapCalls = 0
    $script:stageNames = @()
    $script:failingStage = ''
    $exitCode = Main
    $expected = @('Scoop packages','Winget apps','Fonts','Bibata cursors','PS modules','Symlinks','Git config','Windows Terminal','Build Zebar widget')
    Assert-That ($exitCode -eq 0) 'Successful setup did not return 0.'
    Assert-That (($script:stageNames -join ',') -eq ($expected -join ',')) 'Setup stage order changed.'
    $script:scoopBootstrapCalls = 0
    $script:stageNames = @()
    $script:failingStage = 'Bibata cursors'
    $exitCode = Main
    Assert-That ($exitCode -eq 1) 'Failed setup did not return 1.'
    Assert-That (($script:stageNames -join ',') -eq ($expected -join ',')) 'Failed stage prevented later stages.'
    $Only = @('Zebar,Terminal'); $Skip = @()
    $script:stageNames = @(); $script:failingStage = ''; $script:scoopBootstrapCalls = 0
    $exitCode = Main
    Assert-That ($exitCode -eq 0 -and ($script:stageNames -join ',') -eq 'Windows Terminal,Build Zebar widget') 'Only did not preserve setup order or exclude other stages.'
    Assert-That ($script:scoopBootstrapCalls -eq 0) 'Only Zebar/Terminal unexpectedly bootstrapped Scoop.'
    $Only = @(); $Skip = @('Winget')
    $script:stageNames = @(); $script:failingStage = ''
    $exitCode = Main
    Assert-That ($exitCode -eq 0 -and $script:stageNames.Count -eq 8 -and 'Winget apps' -notin $script:stageNames) 'Skip did not exclude the selected stage.'
    # Unrelated theme/modules data must not block a Terminal-only run.
    $Only = @('Terminal'); $Skip = @()
    Set-Content (Join-Path $moduleDir 'modules.json') 'invalid JSON'
    Set-Content (Join-Path $DOTFILES 'themes/themes.json') 'invalid JSON'
    $script:stageNames = @()
    $exitCode = Main
    Assert-That ($exitCode -eq 0 -and ($script:stageNames -join ',') -eq 'Windows Terminal') 'Terminal-only setup validated unrelated modules or themes.'
    $Only = @('Unknown'); $script:stageNames = @(); $script:scoopBootstrapCalls = 0
    $threw = $false
    try { Main } catch { $threw = $_.Exception.Message -like 'Unknown setup stage*' }
    Assert-That ($threw -and $script:stageNames.Count -eq 0 -and $script:scoopBootstrapCalls -eq 0) 'Invalid stage selection performed setup work.'
} finally { $env:LOCALAPPDATA = $previousLocalAppData }
Write-Host 'Install entry-point tests passed.'
