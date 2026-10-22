# Install and optionally update Winget applications from setup.json.
param([switch]$Update)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/../../lib/utils.ps1"
. "$PSScriptRoot/../../lib/setup/winget.ps1"
$configuration = Get-SetupConfig -RepoRoot (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
Install-WingetApps -Apps $configuration.winget -Update:$Update
