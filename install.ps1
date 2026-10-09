# Setup order and reporting. Bootstrap helpers stay here for first-run downloads.
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
    . "$DOTFILES\lib\setup.ps1"
    # Validate all input data before any package/configuration stage runs.
    $null = Get-SetupConfig -RepoRoot $DOTFILES
    Assert-ZebarConfiguration -RepoRoot $DOTFILES
    $null = Get-PowerShellModules -RepoRoot $DOTFILES
    . "$DOTFILES\scripts\theme\ThemeConfig.ps1"
    $null = Get-ThemeCatalog -Root $DOTFILES
    Write-Banner
    $results = [Collections.Generic.List[object]]::new()
    $results.Add((Invoke-Step 'Scoop packages' { & "$DOTFILES\scripts\install\scoop.ps1" }))
    Refresh-SetupEnvironment
    $results.Add((Invoke-Step 'Winget apps' { & "$DOTFILES\scripts\install\winget.ps1" }))
    Refresh-SetupEnvironment
    $results.Add((Invoke-Step 'Fonts' { & "$DOTFILES\scripts\install\fonts.ps1" }))
    $results.Add((Invoke-Step 'Bibata cursors' { & "$DOTFILES\scripts\install\cursors.ps1" }))
    $results.Add((Invoke-Step 'PS modules' { Install-PSModules -RepoRoot $DOTFILES }))
    $results.Add((Invoke-Step 'Symlinks' { & "$DOTFILES\config\symlinks.ps1" }))
    $results.Add((Invoke-Step 'Git config' { & "$DOTFILES\scripts\install\git.ps1" }))
    $results.Add((Invoke-Step 'Windows Terminal' { & "$DOTFILES\scripts\install\terminal.ps1" }))
    $results.Add((Invoke-Step 'Build Zebar widget' { Build-Zebar -RepoRoot $DOTFILES }))
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
