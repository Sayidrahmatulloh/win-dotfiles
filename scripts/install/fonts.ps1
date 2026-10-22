# Install Scoop fonts and optional local ZIP fonts.
param([switch]$Update)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/../../lib/utils.ps1"
. "$PSScriptRoot/../../lib/setup/fonts.ps1"
$repoRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$configuration = Get-SetupConfig -RepoRoot $repoRoot
$scoopRoot = Get-ScoopRoot
if (-not $scoopRoot) { throw 'Scoop root was not found. Run install.ps1 first.' }
$results = Merge-Results `
    (Install-ScoopFonts -Fonts $configuration.scoop.fonts -ScoopRoot $scoopRoot -Update:$Update) `
    (Install-ZipFonts -FilesDir (Join-Path $repoRoot 'assets/fonts') -TempDir (Join-Path $env:TEMP 'dotfiles-fonts'))
Complete-InstallResults -Name 'Fonts' -Results $results
