param([string]$RepoRoot = (Split-Path $PSScriptRoot -Parent))
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/helpers.ps1"
. "$RepoRoot/scripts/theme/ThemeConfig.ps1"
$catalog = Get-ThemeCatalog -Root $RepoRoot
Assert-That ($catalog.default -in @($catalog.themes.id)) 'Default theme is missing.'
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('theme-test-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path "$fixture/themes" -Force | Out-Null
function Assert-BadTheme {
    param([scriptblock]$Change)
    $data = Get-Content "$RepoRoot/themes/themes.json" -Raw | ConvertFrom-Json
    & $Change $data
    $data | ConvertTo-Json -Depth 10 | Set-Content "$fixture/themes/themes.json"
    $threw = $false
    try { Get-ThemeCatalog -Root $fixture | Out-Null } catch { $threw = $true }
    Assert-That $threw 'Invalid theme catalog was accepted.'
}
Assert-BadTheme { param($data) $data.default = 'unknown' }
Assert-BadTheme { param($data) $data.themes[1].id = $data.themes[0].id }
Assert-BadTheme { param($data) $data.themes[0].accent = 'red' }
Assert-BadTheme { param($data) $data.themes[0].wallpaper = '../outside.png' }
$manifest = Get-Content "$RepoRoot/widgets/zebar/attaquer-solid-ts/zpack.json" -Raw | ConvertFrom-Json
$rule = $manifest.widgets[0].privileges.shellCommands | Where-Object argsRegex -Like '*ApplyTheme*'
$prefix = '-NoProfile -NonInteractive -ExecutionPolicy Bypass -WindowStyle Hidden -File D:\Repo With Spaces\widgets\zebar\attaquer-solid-ts\dist\desktop\scripts\theme\ApplyTheme.ps1 -Theme '
foreach ($theme in $catalog.themes) {
    Assert-That (($prefix + $theme.id) -match $rule.argsRegex) 'Manifest rejected a configured theme.'
    Assert-That (Test-Path (Join-Path $RepoRoot $theme.wallpaper)) 'Theme wallpaper is missing.'
}
Assert-That (($prefix + 'green -Extra value') -notmatch $rule.argsRegex) 'Manifest allowed additional arguments.'
Assert-That (($prefix + 'unknown') -notmatch $rule.argsRegex) 'Manifest allowed an unknown theme.'
Write-Host 'Theme catalog validation, wallpaper paths and shell privileges passed.'
