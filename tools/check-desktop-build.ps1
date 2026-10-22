param([string]$RepoRoot = (Split-Path $PSScriptRoot -Parent), [string]$BuildDirectory)
$ErrorActionPreference = 'Stop'
. "$RepoRoot/lib/zebar/check-assets.ps1"
Assert-ZebarDesktopAssets -RepoRoot $RepoRoot -BuildDirectory $BuildDirectory
