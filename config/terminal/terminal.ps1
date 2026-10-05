[CmdletBinding()]
param(
    [ValidateSet('Restore', 'Export')][string]$Mode = 'Restore',
    [string]$SettingsPath
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-TerminalSettingsPath {
    param([string]$LocalAppData)
    $packaged = Join-Path $LocalAppData 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'
    $unpackaged = Join-Path $LocalAppData 'Microsoft\Windows Terminal\settings.json'
    if (Test-Path -LiteralPath $packaged) { return $packaged }
    if (Test-Path -LiteralPath $unpackaged) { return $unpackaged }
    return $packaged
}

function Copy-TerminalSettings {
    param([string]$Source, [string]$Destination)
    if (-not (Test-Path -LiteralPath $Source -PathType Leaf)) { throw "Terminal settings not found: $Source" }
    $content = Get-Content -LiteralPath $Source -Raw
    $null = $content | ConvertFrom-Json -ErrorAction Stop
    if (Test-Path -LiteralPath $Destination) {
        if ((Get-Content -LiteralPath $Destination -Raw) -ceq $content) {
            Write-Host "Terminal settings already match: $Destination"
            return
        }
        $backup = $Destination + '.bak_' + [guid]::NewGuid().ToString('N')
        Copy-Item -LiteralPath $Destination -Destination $backup -ErrorAction Stop
        Write-Host "Terminal settings backup: $backup"
    }
    New-Item -ItemType Directory -Path (Split-Path $Destination -Parent) -Force | Out-Null
    Copy-Item -LiteralPath $Source -Destination $Destination -Force -ErrorAction Stop
    Write-Host "Terminal settings saved: $Destination"
}

$repoSettings = Join-Path $PSScriptRoot 'settings.json'
if (-not $SettingsPath) { $SettingsPath = Get-TerminalSettingsPath -LocalAppData $env:LOCALAPPDATA }
if ($Mode -eq 'Export') { Copy-TerminalSettings -Source $SettingsPath -Destination $repoSettings }
else { Copy-TerminalSettings -Source $repoSettings -Destination $SettingsPath }