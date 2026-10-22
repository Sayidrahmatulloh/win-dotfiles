# Install and optionally update Scoop packages from setup.json.
param([switch]$Update)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/../../lib/utils.ps1"
$configuration = Get-SetupConfig -RepoRoot (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
Install-ScoopPackages -Buckets $configuration.scoop.buckets -Tools $configuration.scoop.packages -Update:$Update
