[CmdletBinding()]
param(
    [ValidateSet('Restore', 'Export')][string]$Mode = 'Restore',
    [string]$SettingsPath
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/../../lib/setup/terminal.ps1"

. "$PSScriptRoot\..\..\lib\core\files.ps1"

$repoSettings = Join-Path $PSScriptRoot '../../config/terminal/settings.json'
if (-not $SettingsPath) { $SettingsPath = Get-TerminalSettingsPath -LocalAppData $env:LOCALAPPDATA }
if ($Mode -eq 'Export') { Copy-TerminalSettings -Source $SettingsPath -Destination $repoSettings }
else { Copy-TerminalSettings -Source $repoSettings -Destination $SettingsPath }
