# Post-clone setup actions: PowerShell modules and the Zebar build.
function Install-PSModules {
    param([Parameter(Mandatory)][string]$RepoRoot)
    $failed = [Collections.Generic.List[string]]::new()
    foreach ($module in (Get-PowerShellModules -RepoRoot $RepoRoot)) {
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

function Initialize-ZebarRuntime {
    param([Parameter(Mandatory)][string]$RepoRoot, [Parameter(Mandatory)][string]$Destination)
    $Destination = [IO.Path]::GetFullPath($Destination)
    $configuration = Get-SetupConfig -RepoRoot $RepoRoot
    $links = @($configuration.links | Where-Object destination -Like '.glzr/zebar/*')
    $files = @(@('config/glzr/zebar/settings.json','settings.json'), @('widgets/zebar/normalize.css','normalize.css'))
    # Validate every source before changing the existing runtime directory.
    foreach ($pair in $files) {
        if (-not (Test-Path -LiteralPath (Join-Path $RepoRoot $pair[0]) -PathType Leaf)) { throw "Runtime source is missing: $($pair[0])" }
    }
    foreach ($link in $links) {
        if (-not (Test-Path -LiteralPath (Join-Path $RepoRoot $link.source) -PathType Container)) { throw "Widget source is missing: $($link.source)" }
        if (($link.destination -replace '\\','/') -ne ('.glzr/zebar/' + (Split-Path $link.destination -Leaf))) { throw 'Widget runtime links must be direct children of the Zebar directory.' }
    }
    $existing = Get-Item -LiteralPath $Destination -Force -ErrorAction SilentlyContinue
    $parentBackup = $null
    $newParent = -not $existing
    $changes = [Collections.Generic.List[object]]::new()
    try {
        if ($existing -and $existing.LinkType -in @('Junction','SymbolicLink')) {
            $parentBackup = $Destination + '.bak_' + [guid]::NewGuid().ToString('N')
            Move-Item -LiteralPath $Destination -Destination $parentBackup -ErrorAction Stop
            $newParent = $true
        }
        New-Item -ItemType Directory -Path $Destination -Force | Out-Null
        foreach ($pair in $files) {
            $source = Join-Path $RepoRoot $pair[0]
            $target = Join-Path $Destination $pair[1]
            if ((Test-Path -LiteralPath $target -PathType Leaf) -and (Get-FileHash $source).Hash -eq (Get-FileHash $target).Hash) { continue }
            $change = [pscustomobject]@{Target=$target; Backup=$null}
            if (Get-Item -LiteralPath $target -Force -ErrorAction SilentlyContinue) {
                $backup = $target + '.bak_' + [guid]::NewGuid().ToString('N')
                Move-Item -LiteralPath $target -Destination $backup -ErrorAction Stop
                $change.Backup = $backup
            }
            $changes.Add($change)
            Copy-Item -LiteralPath $source -Destination $target -Force -ErrorAction Stop
        }
        foreach ($link in $links) {
            $source = Join-Path $RepoRoot $link.source
            $target = Join-Path $Destination (Split-Path $link.destination -Leaf)
            if (Test-ConfigLink -Source $source -Destination $target) { continue }
            $change = [pscustomobject]@{Target=$target; Backup=$null}
            if (Get-Item -LiteralPath $target -Force -ErrorAction SilentlyContinue) {
                $backup = $target + '.bak_' + [guid]::NewGuid().ToString('N')
                Move-Item -LiteralPath $target -Destination $backup -ErrorAction Stop
                $change.Backup = $backup
            }
            $changes.Add($change)
            try { New-Item -ItemType SymbolicLink -Path $target -Target $source -ErrorAction Stop | Out-Null }
            catch {
                $partial = Get-Item -LiteralPath $target -Force -ErrorAction SilentlyContinue
                if ($partial) {
                    if ($partial.LinkType -notin @('Junction','SymbolicLink')) { throw 'Unexpected real entry appeared at the widget destination.' }
                    Remove-Item -LiteralPath $target -Force -ErrorAction Stop
                }
                New-Item -ItemType Junction -Path $target -Target $source -ErrorAction Stop | Out-Null
            }
            if (-not (Test-ConfigLink -Source $source -Destination $target)) { throw "Widget link verification failed: $target" }
        }
    } catch {
        $failure = $_
        try {
            if ($newParent) {
                # Rename the partial directory; never recurse through its widget links.
                if (Get-Item -LiteralPath $Destination -Force -ErrorAction SilentlyContinue) {
                    Move-Item -LiteralPath $Destination -Destination ($Destination + '.failed_' + [guid]::NewGuid().ToString('N')) -ErrorAction Stop
                }
                if ($parentBackup) { Move-Item -LiteralPath $parentBackup -Destination $Destination -ErrorAction Stop }
            } else {
                for ($i = $changes.Count - 1; $i -ge 0; $i--) {
                    $change = $changes[$i]
                    if (Get-Item -LiteralPath $change.Target -Force -ErrorAction SilentlyContinue) {
                        Move-Item -LiteralPath $change.Target -Destination ($change.Target + '.failed_' + [guid]::NewGuid().ToString('N')) -ErrorAction Stop
                    }
                    if ($change.Backup) { Move-Item -LiteralPath $change.Backup -Destination $change.Target -ErrorAction Stop }
                }
            }
        } catch { throw "Zebar migration failed: $($failure.Exception.Message). Rollback failed: $($_.Exception.Message). Parent backup: $parentBackup" }
        throw $failure
    }
    if ($parentBackup) { Write-Warn "Previous Zebar directory link retained: $parentBackup" }
}
