[CmdletBinding()]
param([string]$DotfilesPath)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$DOTFILES = if ($DotfilesPath) { [IO.Path]::GetFullPath($DotfilesPath) }
elseif ($PSScriptRoot -and (Test-Path "$PSScriptRoot\lib\utils.ps1")) { $PSScriptRoot }
else { Join-Path $env:USERPROFILE 'win-dotfiles' }
$REPO = 'https://github.com/Sayidrahmatulloh/win-dotfiles.git'

function Refresh-SetupEnvironment {
    $paths = @([Environment]::GetEnvironmentVariable('Path', 'Machine'), [Environment]::GetEnvironmentVariable('Path', 'User'), $env:PATH)
    $env:PATH = (($paths -join ';') -split ';' | Where-Object { $_ } | Select-Object -Unique) -join ';'
}
function Install-Scoop {
    if (Get-Command scoop -ErrorAction SilentlyContinue) { Write-Host 'Scoop already installed.' }
    else {
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Invoke-RestMethod 'https://get.scoop.sh' | Invoke-Expression
        Refresh-SetupEnvironment
        if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) { throw 'Scoop installation did not complete.' }
    }
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        & scoop install git
        if ($LASTEXITCODE -ne 0) { throw "Git installation failed (exit $LASTEXITCODE)." }
        Refresh-SetupEnvironment
        if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw 'Git is not available after installation.' }
    }
}
function Sync-Repo {
    if (Test-Path -LiteralPath "$DOTFILES\.git") { Write-Host "Using existing checkout: $DOTFILES" }
    elseif (Test-Path -LiteralPath $DOTFILES) { throw "'$DOTFILES' exists but is not a Git checkout. Choose another -DotfilesPath." }
    else {
        & git clone --depth=1 $REPO $DOTFILES
        if ($LASTEXITCODE -ne 0) { throw "Git clone failed (exit $LASTEXITCODE)." }
    }
    if (-not (Test-Path -LiteralPath "$DOTFILES\lib\utils.ps1")) { throw 'The checkout is missing lib/utils.ps1.' }
}
function Install-PSModules {
    $failed = [Collections.Generic.List[string]]::new()
    foreach ($module in @('posh-git', 'Terminal-Icons', 'PSFzf', 'Microsoft.WinGet.CommandNotFound')) {
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
    $fontName = 'CaskaydiaMonoNerdFont-Regular.ttf'
    $target = Join-Path $WidgetDir "src\fonts\$fontName"
    if (Test-Path -LiteralPath $target -PathType Leaf) { return }
    $scoopRoot = Get-ScoopRoot
    if (-not $scoopRoot) { throw 'Cannot locate Scoop to restore the Zebar font.' }
    $fontDir = Join-Path $scoopRoot 'apps\CascadiaMono-NF\current'
    $source = if (Test-Path -LiteralPath $fontDir) {
        Get-ChildItem -LiteralPath $fontDir -Filter $fontName -File -Recurse | Select-Object -First 1
    }
    if (-not $source) { throw 'Zebar font is missing. Install CascadiaMono-NF through the Fonts stage and retry.' }
    New-Item -ItemType Directory -Path (Split-Path $target -Parent) -Force | Out-Null
    Copy-Item -LiteralPath $source.FullName -Destination $target
}
function Build-Zebar {
    $widgetDir = Join-Path $DOTFILES 'config\glzr\zebar\attaquer-solid-ts'
    if (-not (Test-Path -LiteralPath "$widgetDir\package.json")) { throw 'Zebar package.json is missing.' }
    if (-not (Get-Command bun -ErrorAction SilentlyContinue)) { throw 'Bun is missing. Retry the Scoop packages stage.' }
    Ensure-ZebarFont -WidgetDir $widgetDir
    & bun install --cwd $widgetDir --frozen-lockfile
    if ($LASTEXITCODE -ne 0) { throw "Zebar dependencies failed (exit $LASTEXITCODE)." }
    & bun run --cwd $widgetDir build
    if ($LASTEXITCODE -ne 0) { throw "Zebar build failed (exit $LASTEXITCODE)." }
    if (-not (Test-Path -LiteralPath "$widgetDir\dist\index.html")) { throw 'Zebar build did not produce dist/index.html.' }
}
function Main {
    if ($PSVersionTable.PSVersion.Major -lt 7 -or -not $IsWindows) { throw 'Use bootstrap.ps1 from Windows PowerShell to install PowerShell 7 first.' }
    $principal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    if ($principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { throw 'Run setup in a normal user terminal. App installers request elevation when needed.' }
    $logDir = Join-Path $env:LOCALAPPDATA 'win-dotfiles\logs'
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    $logPath = Join-Path $logDir ('setup-' + (Get-Date -Format 'yyyyMMdd-HHmmss-fff') + '.log')
    Start-Transcript -Path $logPath | Out-Null
    Write-Host "Log: $logPath"
    try {
        Install-Scoop | Out-Host
        Sync-Repo | Out-Host
        . "$DOTFILES\lib\utils.ps1"
        Write-Banner
        $results = [Collections.Generic.List[object]]::new()
        $results.Add((Invoke-Step 'Scoop packages' { & "$DOTFILES\packages\scoop.ps1" }))
        Refresh-SetupEnvironment
        $results.Add((Invoke-Step 'Winget apps' { & "$DOTFILES\packages\winget.ps1" }))
        Refresh-SetupEnvironment
        $results.Add((Invoke-Step 'Fonts' { & "$DOTFILES\fonts\fonts.ps1" }))
        $results.Add((Invoke-Step 'PS modules' { Install-PSModules }))
        $results.Add((Invoke-Step 'Symlinks' { & "$DOTFILES\config\symlinks.ps1" }))
        $results.Add((Invoke-Step 'Build Zebar widget' { Build-Zebar }))
        Write-Host "`nSetup results:"
        $results | Format-Table Name, Success, Message -Wrap | Out-Host
        Write-Host "Log: $logPath"
        $failed = @($results | Where-Object { -not $_.Success })
        if ($failed.Count) { Write-Host 'Some steps failed. Fix the reported problems and run bootstrap.ps1 again.'; return 1 }
        Write-Host 'Setup completed. Restart your terminal.'
        return 0
    } finally { Stop-Transcript | Out-Null }
}
try { $setupExitCode = Main; exit $setupExitCode }
catch { Write-Error $_ -ErrorAction Continue; exit 1 }
