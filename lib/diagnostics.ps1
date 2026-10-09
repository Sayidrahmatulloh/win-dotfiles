# Read-only checks. Each emits a result; failed checks do not stop the report.
function New-DoctorResult {
    param([string]$Name, [ValidateSet('OK','WARN','FAIL')][string]$Status, [string]$Detail, [string]$Fix = '')
    [pscustomobject]@{ Name = $Name; Status = $Status; Detail = $Detail; Fix = $Fix }
}
function Test-DoctorLink {
    param([string]$Source, [string]$Destination)
    $item = Get-Item -LiteralPath $Destination -Force -ErrorAction SilentlyContinue
    if (-not $item) { return New-DoctorResult $Destination FAIL 'Configuration destination is missing.' '.\config\symlinks.ps1' }
    if ($item.LinkType -notin @('Junction', 'SymbolicLink')) {
        return New-DoctorResult $Destination WARN 'A separate copy exists; repo edits will not update it.' '.\config\symlinks.ps1 (backs up existing config)'
    }
    if (-not (Test-ConfigLink -Source $Source -Destination $Destination)) {
        return New-DoctorResult $Destination FAIL 'Link points to a different checkout.' '.\config\symlinks.ps1'
    }
    if (-not (Test-Path -LiteralPath $Source -PathType Container)) { return New-DoctorResult $Destination FAIL 'Link source is missing.' 'Restore the missing repo configuration.' }
    New-DoctorResult $Destination OK "Linked to $Source"
}
function Test-DoctorLock {
    param([string]$PackagePath, [string]$LockPath)
    if ($PSVersionTable.PSVersion.Major -lt 7) {
        return New-DoctorResult 'Zebar lockfile' WARN 'This check requires PowerShell 7 JSON support.' 'Run doctor.ps1 from pwsh.'
    }
    $package = Get-Content -LiteralPath $PackagePath -Raw | ConvertFrom-Json -AsHashtable
    $lock = Get-Content -LiteralPath $LockPath -Raw | ConvertFrom-Json -AsHashtable
    if (-not $lock.Contains('workspaces') -or -not $lock.workspaces.Contains('')) { throw 'bun.lock has no root workspace.' }
    $root = $lock.workspaces['']
    foreach ($section in @('dependencies','devDependencies')) {
        $expectedItems = @(); $actualItems = @()
        if ($package.Contains($section)) { $expectedItems = @($package[$section].GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" } | Sort-Object) }
        if ($root.Contains($section)) { $actualItems = @($root[$section].GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" } | Sort-Object) }
        if (($expectedItems -join "`n") -cne ($actualItems -join "`n")) {
            return New-DoctorResult 'Zebar lockfile' FAIL "$section differs between package.json and bun.lock." 'Developer: run bun install --lockfile-only in the widget folder, review and commit bun.lock.'
        }
    }
    New-DoctorResult 'Zebar lockfile' OK 'Root dependencies match package.json (dependency graph not installed or validated).'
}
function Invoke-DoctorCheck {
    param([string]$Name, [scriptblock]$Check)
    try { & $Check } catch { New-DoctorResult $Name FAIL $_.Exception.Message 'Inspect the indicated file or path.' }
}
function Get-DoctorResults {
    param([string]$RepoRoot, $Configuration)
    $windows = $env:OS -eq 'Windows_NT'
    if (-not $windows) { New-DoctorResult 'Windows' FAIL 'This setup requires Windows.' 'Run on Windows.'; return }
    if ($PSVersionTable.PSVersion.Major -lt 7) { New-DoctorResult 'PowerShell' FAIL "Running $($PSVersionTable.PSVersion); setup requires 7+." '.\bootstrap.ps1' }
    else { New-DoctorResult 'PowerShell' OK $PSVersionTable.PSVersion.ToString() }
    foreach ($name in $Configuration.requiredCommands) {
        $command = Get-Command $name -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($command) { New-DoctorResult "Command: $name" OK $command.Source }
        else { New-DoctorResult "Command: $name" FAIL 'Not found on PATH.' '.\bootstrap.ps1; then reopen your terminal.' }
    }
    foreach ($app in @(@('GlazeWM','glzr.io\GlazeWM\glazewm.exe'), @('Zebar','glzr.io\Zebar\zebar.exe'))) {
        $path = Join-Path $env:ProgramFiles $app[1]
        $command = Get-Command $app[0] -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($command -or (Test-Path -LiteralPath $path)) { New-DoctorResult $app[0] OK 'Executable found.' }
        else { New-DoctorResult $app[0] FAIL 'Executable not found on PATH or in the standard install location.' '.\scripts\install\winget.ps1; check custom install location.' }
    }
    Invoke-DoctorCheck 'PowerShell modules' {
        foreach ($module in (Get-PowerShellModules -RepoRoot $RepoRoot)) {
            if (Get-Module -ListAvailable -Name $module) { New-DoctorResult "Module: $module" OK 'Available (not imported by doctor).' }
            else { New-DoctorResult "Module: $module" FAIL 'Not available in this PowerShell session.' '.\bootstrap.ps1' }
        }
    }
    foreach ($link in (Get-ConfigLinks -RepoRoot $RepoRoot -Configuration $Configuration)) {
        $source = $link.Src
        $destination = $link.Dst
        Invoke-DoctorCheck $destination { Test-DoctorLink $source $destination }
    }
    $profilePath = $PROFILE.CurrentUserCurrentHost
    $profileLine = Get-PowerShellProfileLine
    if ((Test-Path -LiteralPath $profilePath) -and @((Get-Content -LiteralPath $profilePath) | Where-Object { $_.Trim() -eq $profileLine }).Count) {
        New-DoctorResult 'PowerShell profile' OK $profilePath
    } else { New-DoctorResult 'PowerShell profile' FAIL "Profile does not load repo config: $profilePath" 'Run .\config\symlinks.ps1 from PowerShell 7.' }
    Invoke-DoctorCheck 'Shared Git config' {
        $source = [IO.Path]::GetFullPath((Join-Path $RepoRoot 'config\git\gitconfig')).Replace('\','/')
        $origins = @(& git -C $RepoRoot config --global --includes --show-origin --list 2>&1)
        if ($LASTEXITCODE -ne 0) { throw 'Cannot read global Git configuration.' }
        $found = @($origins | Where-Object { $_.ToString().StartsWith("file:$source`t", [StringComparison]::OrdinalIgnoreCase) }).Count -gt 0
        if ($found) { New-DoctorResult 'Shared Git config' OK 'Repo configuration is included in global Git settings.' }
        else { New-DoctorResult 'Shared Git config' FAIL 'Repo configuration is not included in global Git settings.' '.\scripts\install\git.ps1' }
        foreach ($key in @('user.name', 'user.email')) {
            $value = & git -C $RepoRoot config --get $key
            if ($LASTEXITCODE -eq 0 -and $value) { New-DoctorResult "Git identity: $key" OK 'Configured for this checkout.' }
            else { New-DoctorResult "Git identity: $key" WARN 'Not configured for this checkout.' "git config --global $key <your-value>" }
        }
    }
    Invoke-DoctorCheck 'Prompt theme' {
        $path = Join-Path $RepoRoot 'config\powershell\dev.omp.json'
        $null = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
        New-DoctorResult 'Prompt theme' OK 'dev.omp.json parses successfully.'
    }
    Invoke-DoctorCheck 'Windows Terminal' {
        $live = Get-TerminalSettingsPath -LocalAppData $env:LOCALAPPDATA
        $saved = Join-Path $RepoRoot 'config\terminal\settings.json'
        $savedJson = Get-Content -LiteralPath $saved -Raw | ConvertFrom-Json | ConvertTo-Json -Depth 100 -Compress
        $liveJson = Get-Content -LiteralPath $live -Raw | ConvertFrom-Json | ConvertTo-Json -Depth 100 -Compress
        if ($savedJson -ceq $liveJson) { New-DoctorResult 'Windows Terminal' OK 'Current settings match the repo.' }
        else { New-DoctorResult 'Windows Terminal' WARN 'Current settings differ from the repo.' 'Keep current: .\scripts\install\terminal.ps1 -Mode Export; restore repo: .\scripts\install\terminal.ps1' }
    }
    Invoke-DoctorCheck 'Zebar selection' { Assert-ZebarConfiguration -RepoRoot $RepoRoot -Configuration $Configuration; New-DoctorResult 'Zebar selection' OK 'Build, startup and link agree.' }
    Invoke-DoctorCheck 'Zebar runtime settings' { Test-DoctorZebarRuntime -RepoRoot $RepoRoot -Configuration $Configuration }
    $widget = Join-Path $RepoRoot $Configuration.zebar.widget
    Invoke-DoctorCheck 'Zebar lockfile' { Test-DoctorLock (Join-Path $widget 'package.json') (Join-Path $widget 'bun.lock') }
    foreach ($relative in @('dist\index.html', "src\fonts\$($Configuration.zebar.fontFile)")) {
        $path = Join-Path $widget $relative
        if (Test-Path -LiteralPath $path -PathType Leaf) { New-DoctorResult "Zebar: $relative" OK 'File exists.' }
        else { New-DoctorResult "Zebar: $relative" FAIL 'File is missing.' '.\bootstrap.ps1 (Fonts and Build Zebar stages)' }
    }
    Invoke-DoctorCheck 'Desktop themes' {
        . (Join-Path $RepoRoot 'scripts/theme/ThemeConfig.ps1')
        $catalog = Get-ThemeCatalog -Root $RepoRoot
        foreach ($entry in $catalog.themes) {
            $path = Join-Path $RepoRoot $entry.wallpaper
            if (Test-Path -LiteralPath $path -PathType Leaf) { New-DoctorResult "Wallpaper: $($entry.id)" OK 'Asset exists.' }
            else { New-DoctorResult "Wallpaper: $($entry.id)" FAIL "Missing asset: $path" 'Restore the image specified by themes/themes.json.' }
        }
    }
    Invoke-DoctorCheck 'Bibata cursors' { Test-DoctorCursors -RepoRoot $RepoRoot }
    Invoke-DoctorCheck 'Desktop runtime' {
        foreach ($file in @('themes/themes.json','scripts/theme/ApplyTheme.ps1','scripts/theme/SetCursor.ps1','scripts/theme/SetWallpaper.ps1','scripts/theme/ThemeConfig.ps1','assets/cursors/Bibata-Modern-Zebar.zip')) {
            $source = Join-Path $RepoRoot $file
            $built = Join-Path $widget "dist/desktop/$file"
            if ((Test-Path -LiteralPath $built -PathType Leaf) -and (Get-FileHash $built).Hash -eq (Get-FileHash $source).Hash) { New-DoctorResult "Desktop runtime: $file" OK 'Build matches source.' }
            else { New-DoctorResult "Desktop runtime: $file" FAIL 'Build is missing or stale.' '.\bootstrap.ps1 (Build Zebar stage)' }
        }
    }
    New-DoctorResult 'Scope' OK 'Read-only static checks; running app health and full dependency graph are not tested.'
}

function Test-DoctorCursors {
    param(
        [string]$RepoRoot,
        [string]$InstalledRoot = (Join-Path $env:LOCALAPPDATA 'win-dotfiles/cursors/Bibata-Modern-Zebar'),
        $ActiveValues = (Get-ItemProperty -LiteralPath 'HKCU:\Control Panel\Cursors')
    )
    . (Join-Path $RepoRoot 'scripts/theme/SetCursor.ps1')
    $catalog = Get-ThemeCatalog -Root $RepoRoot
    $archive = Join-Path $RepoRoot 'assets/cursors/Bibata-Modern-Zebar.zip'
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [IO.Compression.ZipFile]::OpenRead($archive)
    try {
        foreach ($theme in $catalog.themes) {
            foreach ($file in (Get-CursorRoles).Values) {
                $entry = $zip.GetEntry("$($theme.cursor)/$file")
                if (-not $entry) { throw "Cursor ZIP is missing $($theme.cursor)/$file." }
                $path = Join-Path $InstalledRoot "$($theme.cursor)/$file"
                if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Installed cursor is missing: $path. Run scripts/install/cursors.ps1." }
                $stream = $entry.Open()
                $hasher = [Security.Cryptography.SHA256]::Create()
                try { $expectedHash = [BitConverter]::ToString($hasher.ComputeHash($stream)).Replace('-', '') }
                finally { $stream.Dispose(); $hasher.Dispose() }
                if ((Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash -ne $expectedHash) { throw "Installed cursor differs from ZIP: $path. Run scripts/install/cursors.ps1." }
            }
        }
    } finally { $zip.Dispose() }
    New-DoctorResult 'Bibata assets' OK 'Standard Bibata variants exist; installed files match ZIP hashes.'
    $schemeProperty = $ActiveValues.PSObject.Properties['(default)']
    $scheme = if ($schemeProperty) { $schemeProperty.Value } else { '' }
    if ($scheme -match '^Bibata Modern Zebar (.+)$' -and $Matches[1] -in @($catalog.themes.id)) {
        $theme = $catalog.themes | Where-Object id -EQ $Matches[1]
        foreach ($role in (Get-CursorRoles).GetEnumerator()) {
            $expected = [IO.Path]::GetFullPath((Join-Path $InstalledRoot "$($theme.cursor)/$($role.Value)"))
            $actual = $ActiveValues.PSObject.Properties[$role.Key]
            if (-not $actual -or $actual.Value -ine $expected) { throw "Active cursor path differs for $($role.Key). Run scripts/install/cursors.ps1." }
        }
        New-DoctorResult 'Bibata scheme' OK "Active theme: $($theme.id)"
    } else { New-DoctorResult 'Bibata scheme' WARN 'Another mouse pointer scheme is active.' '.\scripts\install\cursors.ps1' }
}

function Test-DoctorZebarRuntime {
    param([string]$RepoRoot, $Configuration, [string]$RuntimeDirectory = (Join-Path $env:USERPROFILE '.glzr/zebar'))
    $settings = Join-Path $RuntimeDirectory 'settings.json'
    Assert-ZebarConfiguration -RepoRoot $RepoRoot -Configuration $Configuration -SettingsPath $settings
    foreach ($pair in @(@('config/glzr/zebar/settings.json','settings.json'), @('widgets/zebar/normalize.css','normalize.css'))) {
        $source = Join-Path $RepoRoot $pair[0]
        $live = Join-Path $RuntimeDirectory $pair[1]
        if (-not (Test-Path -LiteralPath $live -PathType Leaf)) {
            New-DoctorResult "Zebar runtime: $($pair[1])" FAIL 'Runtime file is missing.' '.\config\symlinks.ps1'
        } elseif ((Get-FileHash $source).Hash -ne (Get-FileHash $live).Hash) {
            New-DoctorResult "Zebar runtime: $($pair[1])" WARN 'Runtime file differs from the repo.' '.\config\symlinks.ps1 (backs up existing settings)'
        } else { New-DoctorResult "Zebar runtime: $($pair[1])" OK 'Runtime file matches the repo.' }
    }
}
