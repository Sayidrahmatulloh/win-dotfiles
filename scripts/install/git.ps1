[CmdletBinding()]
param([string]$GlobalConfigPath)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/../../lib/setup/git.ps1"

. "$PSScriptRoot\..\..\lib\core\files.ps1"

if (-not $GlobalConfigPath) {
    $GlobalConfigPath = if ($env:GIT_CONFIG_GLOBAL) { $env:GIT_CONFIG_GLOBAL } else { Join-Path $env:USERPROFILE '.gitconfig' }
}
Install-GitConfig -Source (Join-Path $PSScriptRoot '../../config/git/gitconfig') -Destination ([IO.Path]::GetFullPath($GlobalConfigPath))
