param(
    [Parameter(Mandatory=$true)]
    [string]$Theme,
    [string]$ConfigPath = (Join-Path $env:USERPROFILE '.glzr/glazewm/config.yaml')
)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'ThemeConfig.ps1')
. (Join-Path $PSScriptRoot 'SetWallpaper.ps1')
. (Join-Path $PSScriptRoot 'SetCursor.ps1')
. (Join-Path $PSScriptRoot 'GlazeConfig.ps1')
$mutex = New-Object System.Threading.Mutex($false, 'Local\ZebarGlazeTheme')
$locked = $false
try {
    $locked = $mutex.WaitOne(10000)
    if (-not $locked) { throw 'Another theme update is still running.' }
    $selectedTheme = Get-DesktopTheme -Theme $Theme
    $config = (Resolve-Path -LiteralPath $ConfigPath).Path
    $original = [IO.File]::ReadAllText($config)
    $updated = Set-GlazeBorderColor -Content $original -Accent $selectedTheme.accent
    if ($updated -ceq $original) { Set-ThemeWallpaper -Theme $Theme; Set-ThemeCursor -Theme $Theme; exit 0 }
    $backup = $config + '.bak-theme'
    if (-not (Test-Path -LiteralPath $backup)) { Copy-Item -LiteralPath $config -Destination $backup }
    [IO.File]::WriteAllText($config, $updated, (New-Object System.Text.UTF8Encoding($false)))
    try {
        Reload-GlazeConfig
    } catch {
        [IO.File]::WriteAllText($config, $original, (New-Object System.Text.UTF8Encoding($false)))
        try { Reload-GlazeConfig } catch { }
        throw
    }
    Set-ThemeWallpaper -Theme $Theme
    Set-ThemeCursor -Theme $Theme
} catch {
    [Console]::Error.WriteLine($_.Exception.Message)
    exit 1
} finally {
    if ($locked) { $mutex.ReleaseMutex() }
    $mutex.Dispose()
}
