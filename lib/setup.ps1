# Post-clone setup actions: PowerShell modules and the Zebar build.
function Install-PSModules {
    $failed = [Collections.Generic.List[string]]::new()
    foreach ($module in (Get-PowerShellModules -RepoRoot $DOTFILES)) {
        if (Get-Module -ListAvailable -Name $module) { Write-Skip "$module already installed"; continue }
        try {
            Install-Module -Name $module -Repository PSGallery -Scope CurrentUser -Force -ErrorAction Stop
            if (-not (Get-Module -ListAvailable -Name $module)) { throw 'Module not found after installation.' }
            Write-Done "installed: $module"
        } catch { $failed.Add($module); Write-Fail "$module : $($_.Exception.Message)" }
    }
    if ($failed.Count) { throw "Modules not installed: $($failed -join ', ')" }
}
function Ensure-ZebarFont {
    param([string]$WidgetDir)
    $zebar = (Get-SetupConfig -RepoRoot $DOTFILES).zebar
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
    $widgetDir = Join-Path $DOTFILES (Get-SetupConfig -RepoRoot $DOTFILES).zebar.widget
    if (-not (Test-Path -LiteralPath "$widgetDir\package.json")) { throw 'Zebar package.json is missing.' }
    if (-not (Get-Command bun -ErrorAction SilentlyContinue)) { throw 'Bun is missing. Retry the Scoop packages stage.' }
    Ensure-ZebarFont -WidgetDir $widgetDir
    & bun install --cwd $widgetDir --frozen-lockfile
    if ($LASTEXITCODE -ne 0) { throw "Zebar dependencies failed (exit $LASTEXITCODE)." }
    & bun run --cwd $widgetDir build
    if ($LASTEXITCODE -ne 0) { throw "Zebar build failed (exit $LASTEXITCODE)." }
    if (-not (Test-Path -LiteralPath "$widgetDir\dist\index.html")) { throw 'Zebar build did not produce dist/index.html.' }
}
