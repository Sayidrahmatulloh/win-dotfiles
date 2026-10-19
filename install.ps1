# Setup order and reporting. Bootstrap helpers stay here for first-run downloads.
[CmdletBinding()]
param([string]$DotfilesPath, [string[]]$Only = @(), [string[]]$Skip = @())
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
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $installer = Join-Path ([IO.Path]::GetTempPath()) ("scoop-install-$([guid]::NewGuid().ToString('N')).ps1")
        try {
            Invoke-WebRequest -UseBasicParsing -Uri 'https://get.scoop.sh' -OutFile $installer
            & $installer
        }
        finally {
            if (Test-Path -LiteralPath $installer) { Remove-Item -LiteralPath $installer -Force -ErrorAction SilentlyContinue }
        }
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

function Get-SetupStages {
    @(
        @{Id = 'Scoop'; Name = 'Scoop packages'; Action = { & "$DOTFILES/scripts/install/scoop.ps1" } }
        @{Id = 'Winget'; Name = 'Winget apps'; Action = { & "$DOTFILES/scripts/install/winget.ps1" } }
        @{Id = 'Fonts'; Name = 'Fonts'; Action = { & "$DOTFILES/scripts/install/fonts.ps1" } }
        @{Id = 'Cursors'; Name = 'Bibata cursors'; Action = { & "$DOTFILES/scripts/install/cursors.ps1" } }
        @{Id = 'Modules'; Name = 'PS modules'; Action = { Install-PSModules -RepoRoot $DOTFILES } }
        @{Id = 'Symlinks'; Name = 'Symlinks'; Action = { & "$DOTFILES/config/symlinks.ps1" } }
        @{Id = 'Git'; Name = 'Git config'; Action = { & "$DOTFILES/scripts/install/git.ps1" } }
        @{Id = 'Terminal'; Name = 'Windows Terminal'; Action = { & "$DOTFILES/scripts/install/terminal.ps1" } }
        @{Id = 'Zebar'; Name = 'Build Zebar widget'; Action = { Build-Zebar -RepoRoot $DOTFILES } }
    )
}

function Select-SetupStages {
    param([string[]]$Only = @(), [string[]]$Skip = @())
    if ($Only.Count -and $Skip.Count) { throw 'Use either -Only or -Skip, not both.' }
    $stages = @(Get-SetupStages)
    $names = @($stages.Id)
    $onlyNames = @($Only | ForEach-Object { $_ -split ',' | ForEach-Object { $_.Trim() } })
    $skipNames = @($Skip | ForEach-Object { $_ -split ',' | ForEach-Object { $_.Trim() } })
    foreach ($name in @($onlyNames) + @($skipNames)) {
        if ($name -notin $names) { throw "Unknown setup stage '$name'. Available: $($names -join ', ')." }
    }
    $selected = @($stages | Where-Object { (-not $onlyNames.Count -or $_.Id -in $onlyNames) -and $_.Id -notin $skipNames })
    if (-not $selected.Count) { throw 'No setup stages selected.' }
    return $selected
}

function Assert-SetupStageConfiguration {
    param([string]$RepoRoot, [string[]]$StageIds)
    $null = Get-SetupConfig -RepoRoot $RepoRoot
    if ('Zebar' -in $StageIds -or 'Symlinks' -in $StageIds) { Assert-ZebarConfiguration -RepoRoot $RepoRoot }
    if ('Modules' -in $StageIds) { $null = Get-PowerShellModules -RepoRoot $RepoRoot }
    if ('Cursors' -in $StageIds -or 'Zebar' -in $StageIds) {
        . "$RepoRoot/scripts/theme/ThemeConfig.ps1"
        $null = Get-ThemeCatalog -Root $RepoRoot
    }
}

function Invoke-SetupStages {
    param([object[]]$Stages)
    foreach ($stage in $Stages) {
        Invoke-Step -Name $stage.Name -Block $stage.Action
        if ($stage.Id -in @('Scoop', 'Winget')) { Refresh-SetupEnvironment }
    }
}

function Main {
    if ($PSVersionTable.PSVersion.Major -lt 7 -or -not $IsWindows) { throw 'Use bootstrap.ps1 from Windows PowerShell to install PowerShell 7 first.' }
    $principal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    if ($principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { throw 'Run setup in a normal user terminal. App installers request elevation when needed.' }
    $stages = @(Select-SetupStages -Only $Only -Skip $Skip)
    $stageIds = @($stages.Id)
    $logDir = Join-Path $env:LOCALAPPDATA 'win-dotfiles\logs'
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    $logPath = Join-Path $logDir ('setup-' + (Get-Date -Format 'yyyyMMdd-HHmmss-fff') + '.log')
    Start-Transcript -Path $logPath | Out-Null
    Write-Host "Log: $logPath"

    try {
        if ('Scoop' -in $stageIds -or 'Fonts' -in $stageIds -or -not (Test-Path -LiteralPath "$DOTFILES\lib\utils.ps1")) { Install-Scoop | Out-Host }
        Sync-Repo | Out-Host
        . "$DOTFILES\lib\utils.ps1"
        . "$DOTFILES\lib\setup.ps1"
        Assert-SetupStageConfiguration -RepoRoot $DOTFILES -StageIds $stageIds
        Write-Banner
        Write-Host "Selected stages: $($stageIds -join ', ')"
        $results = @(Invoke-SetupStages -Stages $stages)
        Write-Host "`nSetup results:"
        $results | Format-Table Name, Success, Message -Wrap | Out-Host
        Write-Host "Log: $logPath"
        $failed = @($results | Where-Object { -not $_.Success })
        if ($failed.Count) { Write-Host 'Some steps failed. Fix the reported problems and run bootstrap.ps1 again.'; return 1 }
        Write-Host 'Setup completed. Restart your terminal.'
        return 0
    }
    finally { Stop-Transcript | Out-Null }
}

try { $setupExitCode = Main; exit $setupExitCode }
catch { Write-Error $_ -ErrorAction Continue; exit 1 }
