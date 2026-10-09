# Validate a staged build before replacing the active dist directory.
[CmdletBinding()]
param([string]$RepoRoot = (Split-Path $PSScriptRoot -Parent))
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. "$RepoRoot/lib/utils.ps1"
. "$RepoRoot/lib/setup.ps1"
Assert-ZebarConfiguration -RepoRoot $RepoRoot
Build-Zebar -RepoRoot $RepoRoot
