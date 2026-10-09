param([string]$RepoRoot = (Split-Path $PSScriptRoot -Parent))
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
. "$PSScriptRoot\helpers.ps1"
Invoke-Expression (Read-Functions 'widgets/zebar/attaquer-solid-ts/public/assets/scripts/InvokeWidgetAction.ps1')
$script:commandPath = $null
$script:scoopCommand = $null
$script:existingPaths = @()
function Get-Command {
    param($Name, $CommandType, $ErrorAction)
    if ($Name -eq 'AutoHotkey64.exe' -and $script:commandPath) { return [pscustomobject]@{Source=$script:commandPath} }
    if ($Name -eq 'scoop' -and $script:scoopCommand) { return [pscustomobject]@{Source=$script:scoopCommand} }
}
function Test-Path { param($LiteralPath, $PathType) return $LiteralPath -in $script:existingPaths }
$env:SCOOP = 'D:\Custom Scoop'
$custom = Join-Path $env:SCOOP 'apps\autohotkey\current\v2\AutoHotkey64.exe'
$script:existingPaths = @($custom)
Assert-That ((Resolve-AutoHotkeyPath) -eq $custom) 'Custom Scoop path was not resolved.'
$script:commandPath = 'D:\Portable AHK\AutoHotkey64.exe'
Assert-That ((Resolve-AutoHotkeyPath) -eq $script:commandPath) 'PATH executable was not preferred.'
$script:commandPath = $null
$env:SCOOP = ''
$script:scoopCommand = 'D:\Another Scoop\shims\scoop.ps1'
$discovered = 'D:\Another Scoop\apps\autohotkey\current\AutoHotkey64.exe'
$script:existingPaths = @($discovered)
Assert-That ((Resolve-AutoHotkeyPath) -eq $discovered) 'Scoop command root was not resolved.'
$script:existingPaths = @()
$threw = $false
try { Resolve-AutoHotkeyPath } catch { $threw = $true }
Assert-That $threw 'Missing AutoHotkey was accepted.'
$manifest = Get-Content (Join-Path $RepoRoot 'widgets/zebar/attaquer-solid-ts/zpack.json') -Raw | ConvertFrom-Json
$rule = $manifest.widgets[0].privileges.shellCommands | Where-Object argsRegex -Like '*InvokeWidgetAction*'
$prefix = '-NoProfile -NonInteractive -ExecutionPolicy Bypass -WindowStyle Hidden -File D:\Widget With Spaces\attaquer-solid-ts\dist\assets\scripts\InvokeWidgetAction.ps1 -Action '
Assert-That (($prefix + 'ResolveAutoHotkey') -match $rule.argsRegex) 'Manifest rejected startup path resolution with spaces.'
Assert-That (($prefix + 'OpenStartMenu') -notmatch $rule.argsRegex) 'Manifest allowed PowerShell to launch a click action.'
Assert-That (($prefix + 'ResolveAutoHotkey -Extra anything') -notmatch $rule.argsRegex) 'Manifest allowed extra arguments.'
Write-Host 'Widget path resolution and privilege tests passed.'
