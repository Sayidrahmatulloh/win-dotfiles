# CI only: download the upstream Nerd Fonts archive, never install system fonts.
param([string]$FontDirectory)
$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path $PSScriptRoot -Parent
. "$repoRoot/lib/setup/settings.ps1"
$config = Get-SetupConfig -RepoRoot $repoRoot
$widget = Join-Path $repoRoot $config.zebar.widget
if (-not $FontDirectory) { $FontDirectory = Join-Path $widget 'src/fonts' }
$target = Join-Path $FontDirectory $config.zebar.fontFile
if (Test-Path -LiteralPath $target -PathType Leaf) { return }
$work = Join-Path ([IO.Path]::GetTempPath()) ('zebar-ci-font-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $work | Out-Null
$release = Invoke-RestMethod 'https://api.github.com/repos/ryanoasis/nerd-fonts/releases/tags/v3.4.0'
$asset = $release.assets | Where-Object name -EQ 'CascadiaMono.zip'
if (-not $asset) { throw 'Upstream CascadiaMono font archive is missing.' }
Invoke-WebRequest -Uri $asset.browser_download_url -OutFile "$work/font.zip"
Expand-Archive -LiteralPath "$work/font.zip" -DestinationPath "$work/extracted"
$font = Get-ChildItem "$work/extracted" -Recurse -File -Filter $config.zebar.fontFile | Select-Object -First 1
if (-not $font) { throw 'Upstream archive does not contain the configured font.' }
New-Item -ItemType Directory -Path (Split-Path $target) -Force | Out-Null
Copy-Item -LiteralPath $font.FullName -Destination $target
