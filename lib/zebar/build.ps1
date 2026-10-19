# Validate and publish staged builds; retain the previous build for recovery.
function Ensure-ZebarFont {
    param([Parameter(Mandatory)][string]$RepoRoot, [string]$WidgetDir)
    $zebar = (Get-SetupConfig -RepoRoot $RepoRoot).zebar
    $fontName = $zebar.fontFile
    $target = Join-Path $WidgetDir "src\fonts\$fontName"
    if (Test-Path -LiteralPath $target -PathType Leaf) { return }
    $scoopRoot = Get-ScoopRoot
    if (-not $scoopRoot) { throw 'Cannot locate Scoop to restore the Zebar font.' }
    $fontDir = Join-Path $scoopRoot "apps\$($zebar.fontPackage)\current"
    $source = if (Test-Path -LiteralPath $fontDir) {
        Get-ChildItem -LiteralPath $fontDir -Filter $fontName -File -Recurse | Select-Object -First 1
    }
    if (-not $source) { throw 'Zebar font is missing. Install CascadiaMono-NF through the Fonts stage and retry.' }
    New-Item -ItemType Directory -Path (Split-Path $target -Parent) -Force | Out-Null
    Copy-Item -LiteralPath $source.FullName -Destination $target
}
function Build-Zebar {
    param([Parameter(Mandatory)][string]$RepoRoot)
    $widgetDir = [IO.Path]::GetFullPath((Join-Path $RepoRoot (Get-SetupConfig -RepoRoot $RepoRoot).zebar.widget))
    if (-not (Test-Path -LiteralPath "$widgetDir/package.json")) { throw 'Zebar package.json is missing.' }
    if (-not (Get-Command bun -ErrorAction SilentlyContinue)) { throw 'Bun is missing. Retry the Scoop packages stage.' }
    Ensure-ZebarFont -RepoRoot $RepoRoot -WidgetDir $widgetDir
    & bun install --cwd $widgetDir --frozen-lockfile
    if ($LASTEXITCODE -ne 0) { throw "Zebar dependencies failed (exit $LASTEXITCODE)." }
    $stage = Join-Path $widgetDir ('.dist-stage-' + [guid]::NewGuid().ToString('N'))
    $dist = Join-Path $widgetDir 'dist'
    $backup = Join-Path $widgetDir ('.dist-backup-' + [guid]::NewGuid().ToString('N'))
    try {
        & bun run --cwd $widgetDir build:raw --outDir $stage --emptyOutDir
        if ($LASTEXITCODE -ne 0) { throw "Zebar build failed (exit $LASTEXITCODE)." }
        if (-not (Test-Path -LiteralPath "$stage/index.html" -PathType Leaf)) { throw 'Zebar build did not produce staged index.html.' }
        & "$RepoRoot/tools/check-desktop-build.ps1" -RepoRoot $RepoRoot -BuildDirectory $stage
        Publish-ZebarBuild -Stage $stage -Destination $dist -Backup $backup
    } finally {
        # Only remove the generated sibling directory, never the active build or a link.
        if (Test-Path -LiteralPath $stage) {
            $resolved = [IO.Path]::GetFullPath($stage)
            if ((Split-Path $resolved -Parent) -ne $widgetDir -or (Split-Path $resolved -Leaf) -notlike '.dist-stage-*') { throw 'Unsafe staged build cleanup path.' }
            if ((Get-Item -LiteralPath $resolved -Force).LinkType -or @(Get-ChildItem -LiteralPath $resolved -Recurse -Force | Where-Object LinkType).Count) { throw "Staged build contains links; retained at $resolved" }
            Remove-Item -LiteralPath $resolved -Recurse -Force
        }
    }
}

function Publish-ZebarBuild {
    param([string]$Stage, [string]$Destination, [string]$Backup)
    $oldMoved = $false
    try {
        if (Get-Item -LiteralPath $Destination -Force -ErrorAction SilentlyContinue) {
            Move-Item -LiteralPath $Destination -Destination $Backup -ErrorAction Stop
            $oldMoved = $true
        }
        Move-Item -LiteralPath $Stage -Destination $Destination -ErrorAction Stop
    } catch {
        $failure = $_
        if ($oldMoved) {
            try {
                if (Get-Item -LiteralPath $Destination -Force -ErrorAction SilentlyContinue) { throw 'Destination is occupied; cannot safely restore the old build.' }
                Move-Item -LiteralPath $Backup -Destination $Destination -ErrorAction Stop
            } catch { throw "Build activation failed: $($failure.Exception.Message). Rollback failed: $($_.Exception.Message). Previous build: $Backup" }
        }
        throw $failure
    }
    if ($oldMoved) { Write-Host "Previous Zebar build retained: $Backup" }
}
