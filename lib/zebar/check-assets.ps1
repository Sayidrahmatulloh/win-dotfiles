# Validate desktop assets without publishing or changing the active build.
function Assert-ZebarDesktopAssets {
    param([Parameter(Mandatory)][string]$RepoRoot, [string]$BuildDirectory)
    $ErrorActionPreference = 'Stop'

    . "$repoRoot/lib/setup/settings.ps1"
    . "$repoRoot/scripts/theme/ThemeConfig.ps1"
    $widget = Join-Path $repoRoot (Get-SetupConfig -RepoRoot $repoRoot).zebar.widget
    if (-not $BuildDirectory) { $BuildDirectory = Join-Path $widget 'dist' }
    $files = @('themes/themes.json','assets/cursors/Bibata-Modern-Zebar.zip')
    $files += @(Get-ChildItem "$repoRoot/scripts/theme" -File | ForEach-Object { "scripts/theme/$($_.Name)" })
    $files += @((Get-ThemeCatalog -Root $repoRoot).themes.wallpaper)
    foreach ($file in $files) {
        $source = Join-Path $repoRoot $file
        $built = Join-Path $BuildDirectory "desktop/$file"
        if (-not (Test-Path -LiteralPath $built -PathType Leaf)) { throw "Build omitted $file" }
        if ((Get-FileHash $source).Hash -ne (Get-FileHash $built).Hash) { throw "Build contains stale $file" }
    }
    Write-Host 'Desktop build matches source scripts, theme catalog, cursor ZIP and wallpapers.'
}
