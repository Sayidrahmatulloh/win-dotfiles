# Resolve AutoHotkey from PATH or the actual Scoop installation, preserving spaces in paths.
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('ResolveAutoHotkey')]
    [string]$Action
)
$ErrorActionPreference = 'Stop'

function Resolve-AutoHotkeyPath {
    $command = Get-Command AutoHotkey64.exe -CommandType Application -ErrorAction SilentlyContinue
    if ($command) { return $command.Source }
    $roots = @($env:SCOOP)
    $scoop = Get-Command scoop -ErrorAction SilentlyContinue
    if ($scoop -and $scoop.Source) { $roots += Split-Path (Split-Path $scoop.Source -Parent) -Parent }
    $roots += @((Join-Path $env:USERPROFILE 'scoop'), (Join-Path $env:ProgramData 'scoop'))
    foreach ($root in $roots | Where-Object { $_ } | Select-Object -Unique) {
        foreach ($relative in @('apps\autohotkey\current\v2\AutoHotkey64.exe', 'apps\autohotkey\current\AutoHotkey64.exe')) {
            $candidate = Join-Path $root $relative
            if (Test-Path -LiteralPath $candidate -PathType Leaf) { return $candidate }
        }
    }
    throw 'AutoHotkey v2 was not found. Install the Scoop autohotkey package and restart Zebar.'
}

try { @{ executable = (Resolve-AutoHotkeyPath) } | ConvertTo-Json -Compress }
catch { [Console]::Error.WriteLine($_.Exception.Message); exit 1 }
