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
        else { New-DoctorResult $app[0] FAIL 'Executable not found on PATH or in the standard install location.' '.\packages\winget.ps1; check custom install location.' }
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
        else { New-DoctorResult 'Shared Git config' FAIL 'Repo configuration is not included in global Git settings.' '.\config\git\git.ps1' }
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
        else { New-DoctorResult 'Windows Terminal' WARN 'Current settings differ from the repo.' 'Keep current: .\config\terminal\terminal.ps1 -Mode Export; restore repo: .\config\terminal\terminal.ps1' }
    }
    $widget = Join-Path $RepoRoot $Configuration.zebar.widget
    Invoke-DoctorCheck 'Zebar lockfile' { Test-DoctorLock (Join-Path $widget 'package.json') (Join-Path $widget 'bun.lock') }
    foreach ($relative in @('dist\index.html', "src\fonts\$($Configuration.zebar.fontFile)")) {
        $path = Join-Path $widget $relative
        if (Test-Path -LiteralPath $path -PathType Leaf) { New-DoctorResult "Zebar: $relative" OK 'File exists.' }
        else { New-DoctorResult "Zebar: $relative" FAIL 'File is missing.' '.\bootstrap.ps1 (Fonts and Build Zebar stages)' }
    }
    Invoke-DoctorCheck 'Wallpaper assets' {
        $scriptDir = Join-Path $widget 'public\assets\scripts'
        $map = Get-Content -LiteralPath (Join-Path $scriptDir 'theme-wallpapers.json') -Raw | ConvertFrom-Json
        foreach ($entry in $map.PSObject.Properties) {
            $path = Join-Path $scriptDir $entry.Value
            if (Test-Path -LiteralPath $path -PathType Leaf) { New-DoctorResult "Wallpaper: $($entry.Name)" OK 'Asset exists.' }
            else { New-DoctorResult "Wallpaper: $($entry.Name)" FAIL "Missing asset: $path" 'Restore the image specified by theme-wallpapers.json.' }
        }
    }
    New-DoctorResult 'Scope' OK 'Read-only static checks; running app health and full dependency graph are not tested.'
}
