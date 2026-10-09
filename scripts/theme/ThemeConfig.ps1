# Repo and dist/desktop share the same relative layout.
function Get-DesktopRoot { [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..')) }

function Get-ThemeCatalog {
    param([string]$Root = (Get-DesktopRoot))
    $catalog = Get-Content -LiteralPath (Join-Path $Root 'themes/themes.json') -Raw | ConvertFrom-Json
    if ($catalog.themes -isnot [array] -or -not $catalog.themes.Count) { throw 'themes must be a non-empty array.' }
    $ids = @()
    foreach ($theme in $catalog.themes) {
        if ($theme.id -notmatch '^[a-z][a-z0-9-]*$' -or $theme.id -in $ids) { throw 'Invalid or duplicate theme ID.' }
        $ids += $theme.id
        if ([string]::IsNullOrWhiteSpace($theme.label) -or $theme.accent -notmatch '^#[0-9a-fA-F]{6}$' -or $theme.surface -notmatch '^#[0-9a-fA-F]{8}$') { throw "Invalid theme colors or label: $($theme.id)" }
        if ([IO.Path]::IsPathRooted($theme.wallpaper) -or ($theme.wallpaper -split '[/\\]') -contains '..' -or $theme.wallpaper -notmatch '^assets/wallpapers/[^/\\]+$') { throw 'Invalid wallpaper path.' }
        if ($theme.cursor -notmatch '^[a-z][a-z0-9-]*$') { throw 'Invalid cursor directory.' }
    }
    if ($catalog.default -notin $ids) { throw 'Default theme does not exist.' }
    return $catalog
}

function Get-DesktopTheme {
    param([Parameter(Mandatory=$true)][string]$Theme)
    $entry = (Get-ThemeCatalog).themes | Where-Object id -CEQ $Theme
    if (-not $entry) { throw "Unknown theme: $Theme" }
    return $entry
}
