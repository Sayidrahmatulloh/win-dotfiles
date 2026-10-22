param([string]$RepoRoot = (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent))
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/../support/powershell.ps1"
. "$RepoRoot/lib/zebar/check-assets.ps1"

# A complete fixture exercises the shared validator and the public CI command.
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('desktop-assets-' + [guid]::NewGuid().ToString('N'))
$build = Join-Path $fixture 'widgets/zebar/attaquer-solid-ts/dist'
foreach ($directory in @('lib/setup', 'lib/zebar', 'scripts/theme', 'themes', 'assets/cursors', 'assets/wallpapers')) {
    New-Item -ItemType Directory -Path (Join-Path $fixture $directory) -Force | Out-Null
}
foreach ($file in @('setup.json', 'themes/themes.json', 'scripts/theme/ThemeConfig.ps1',
    'lib/setup/settings.ps1', 'lib/zebar/check-assets.ps1')) {
    Copy-Item -LiteralPath (Join-Path $RepoRoot $file) -Destination (Join-Path $fixture $file)
}
$catalog = Get-Content -LiteralPath "$fixture/themes/themes.json" -Raw | ConvertFrom-Json
$assets = @('assets/cursors/Bibata-Modern-Zebar.zip') + @($catalog.themes.wallpaper | Select-Object -Unique)
foreach ($file in $assets) { Set-Content -LiteralPath (Join-Path $fixture $file) -Value "fixture: $file" }
$files = @('themes/themes.json', 'scripts/theme/ThemeConfig.ps1') + $assets
foreach ($file in $files) {
    $destination = Join-Path $build "desktop/$file"
    New-Item -ItemType Directory -Path (Split-Path $destination -Parent) -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $fixture $file) -Destination $destination
}
Assert-ZebarDesktopAssets -RepoRoot $fixture
& "$RepoRoot/tools/check-desktop-build.ps1" -RepoRoot $fixture -BuildDirectory $build

$wallpaper = $catalog.themes[0].wallpaper
Set-Content -LiteralPath (Join-Path $build "desktop/$wallpaper") -Value 'stale wallpaper'
$threw = $false
try { & "$RepoRoot/tools/check-desktop-build.ps1" -RepoRoot $fixture -BuildDirectory $build }
catch { $threw = $_.Exception.Message -eq "Build contains stale $wallpaper" }
Assert-That $threw 'The CI command accepted a stale desktop asset.'
Copy-Item -LiteralPath (Join-Path $fixture $wallpaper) -Destination (Join-Path $build "desktop/$wallpaper")

Remove-Item -LiteralPath (Join-Path $build 'desktop/assets/cursors/Bibata-Modern-Zebar.zip')
$threw = $false
try { Assert-ZebarDesktopAssets -RepoRoot $fixture -BuildDirectory $build }
catch { $threw = $_.Exception.Message -eq 'Build omitted assets/cursors/Bibata-Modern-Zebar.zip' }
Assert-That $threw 'The shared validator accepted an omitted desktop asset.'
Write-Host 'Shared desktop validation and CI adapter reject stale and missing assets.'
