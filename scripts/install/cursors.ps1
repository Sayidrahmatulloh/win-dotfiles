[CmdletBinding()]
param(
    [string]$Theme,
    [string]$Destination = (Join-Path $env:LOCALAPPDATA 'win-dotfiles/cursors/Bibata-Modern-Zebar'),
    [switch]$ExtractOnly
)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot '../theme/SetCursor.ps1')
$catalog = Get-ThemeCatalog
if ($Theme) { $null = Get-DesktopTheme -Theme $Theme }
Expand-ThemeCursors -Destination $Destination
if ($ExtractOnly) { return }
if (-not $Theme) {
    # Keep the active Zebar cursor color when setup is run again.
    $active = (Get-Item -LiteralPath 'HKCU:\Control Panel\Cursors').GetValue('')
    $saved = $active -replace '^Bibata Modern Zebar ', ''
    $Theme = if ($saved -in @($catalog.themes.id)) { $saved } else { $catalog.default }
}
Set-ThemeCursor -Theme $Theme -CursorRoot $Destination
Write-Host "Bibata Modern installed from ZIP ($Theme)."
