# ============================================================
#  config/powershell/user_profile.ps1
# ============================================================

# Set PowerShell to UTF-8
[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

# ── Module imports ────────────────────────────────────────────
# Wrapped individually so a missing module doesn't break the entire profile

$modules = @()
try { $modules = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'modules.json') -Raw | ConvertFrom-Json -ErrorAction Stop }
catch { Write-Warning "Module list could not be read: $($_.Exception.Message)" }
foreach ($module in $modules) {
  try { Import-Module -Name $module -ErrorAction Stop }
  catch { Write-Warning "Module '$module' not found. Run the packages script to install it." }
}

# Oh My Posh
$omp_config = Join-Path $PSScriptRoot "dev.omp.json"
if ((Test-Path $omp_config) -and (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
  oh-my-posh --init --shell pwsh --config $omp_config | Invoke-Expression
}
else {
  Write-Warning "Oh My Posh command or config is unavailable: $omp_config"
}

# PSReadLine
Set-PSReadLineOption -EditMode Vi
Set-PSReadLineOption -BellStyle None
Set-PSReadLineOption -ViModeIndicator Cursor
Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
if ($Host.UI.SupportsVirtualTerminal) {
  try { Set-PSReadLineOption -PredictionSource History -ErrorAction SilentlyContinue } catch {}
}

# Fzf
if (Get-Command Set-PsFzfOption -ErrorAction SilentlyContinue) {
  Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'
}

# ── Env ───────────────────────────────────────────────────────

$gitSsh = Join-Path $env:SystemRoot 'System32\OpenSSH\ssh.exe'
if (Test-Path $gitSsh) {
  $env:GIT_SSH = $gitSsh
}
else {
  Write-Warning "OpenSSH not found at '$gitSsh'. GIT_SSH not set."
}

$env:CC = 'gcc'
$env:CXX = 'g++'

# ── Aliases ───────────────────────────────────────────────────

Set-Alias -Name vim   -Value nvim
Set-Alias -Name ll    -Value ls
Set-Alias -Name g     -Value git
Set-Alias -Name lg    -Value lazygit
Set-Alias -Name py    -Value python
Set-Alias -Name grep  -Value rg
Set-Alias -Name cs    -Value Clear-System
Set-Alias -Name su    -Value Update-Scoop

# Dynamic git bin path (works on any machine)
$gitCmd = Get-Command 'git' -ErrorAction SilentlyContinue
if ($gitCmd) {
  $gitRoot = Split-Path (Split-Path $gitCmd.Source -Parent) -Parent
  $gitBin = "$gitRoot\usr\bin"
  if (Test-Path $gitBin) {
    Set-Alias -Name tig  -Value "$gitBin\tig.exe"
    Set-Alias -Name less -Value "$gitBin\less.exe"
  }
}
elseif (Test-Path "$env:USERPROFILE\scoop\apps\git\current\usr\bin") {
  $gitBin = "$env:USERPROFILE\scoop\apps\git\current\usr\bin"
  Set-Alias -Name tig  -Value "$gitBin\tig.exe"
  Set-Alias -Name less -Value "$gitBin\less.exe"
}

# ── Functions ─────────────────────────────────────────────────

function which {
  param([Parameter(Mandatory)] [string] $command)
  Get-Command -Name $command -ErrorAction SilentlyContinue |
  Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

function Start-Neovide { neovide --frame none @args }

function New-TempBuildDirectory {
  $path = Join-Path ([IO.Path]::GetTempPath()) ('dotfiles-build-' + [guid]::NewGuid().ToString('N'))
  New-Item -ItemType Directory -Path $path | Out-Null
  return $path
}

function Remove-TempBuildDirectory {
  param([string]$Path)
  $resolved = [IO.Path]::GetFullPath($Path)
  $root = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\')
  if (-not $resolved.StartsWith($root + '\', [StringComparison]::OrdinalIgnoreCase) -or (Split-Path $resolved -Leaf) -notlike 'dotfiles-build-*') {
    throw 'Build directory is outside the expected temporary location.'
  }
  if (Test-Path -LiteralPath $resolved) { Remove-Item -LiteralPath $resolved -Recurse -Force }
}

function Invoke-Cpp {
  param([Parameter(Mandatory)] [string] $cppFilePath)
  $source = (Resolve-Path -LiteralPath $cppFilePath -ErrorAction Stop).Path
  $directory = New-TempBuildDirectory
  $exe = Join-Path $directory 'program.exe'
  try {
    $out = & g++ $source -o $exe 2>&1
    if ($LASTEXITCODE -ne 0) { Write-Error "Compilation failed:`n$out"; return }
    & $exe
  } finally { Remove-TempBuildDirectory $directory }
}

function Invoke-Zig {
  param([Parameter(Mandatory)] [string] $zigFilePath)
  $source = (Resolve-Path -LiteralPath $zigFilePath -ErrorAction Stop).Path
  $directory = New-TempBuildDirectory
  $exe = Join-Path $directory 'program.exe'
  try {
    $out = & zig build-exe $source "-femit-bin=$exe" 2>&1
    if ($LASTEXITCODE -ne 0) { Write-Error "Compilation failed:`n$out"; return }
    & $exe
  } finally { Remove-TempBuildDirectory $directory }
}

function Invoke-Swift {
  param([string] $appName = 'app')
  # Capture both stdout and stderr so the error message is actually useful
  $out = & swift build 2>&1
  if ($LASTEXITCODE -ne 0) { Write-Error "Compilation failed:`n$out"; return }
  Write-Host "Compilation successful. Running '$appName'..."
  & "./.build/debug/$appName"
}

function Get-NpmPackageVersion {
  param([Parameter(Mandatory)] [string] $PackageName)
  try {
    $r = Invoke-RestMethod -Uri "https://registry.npmjs.org/$PackageName/latest" -Method Get -ErrorAction Stop
    if ($r.version) { Write-Host "Package: $PackageName`nLatest Version: $($r.version)" }
    else { Write-Host 'Version not found.' }
  }
  catch { Write-Host "Error: '$PackageName' not found or network issue." }
}

function Clear-System {
  $isAdmin = ([Security.Principal.WindowsPrincipal] `
      [Security.Principal.WindowsIdentity]::GetCurrent() `
  ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

  Write-Host "`nCleaning system..." -ForegroundColor Cyan

  Write-Host 'Temp files...' -NoNewline
  $tempPaths = @("$env:TEMP\*", "$env:LOCALAPPDATA\Temp\*")
  # C:\Windows\Temp requires admin — only include when elevated
  if ($isAdmin) { $tempPaths += 'C:\Windows\Temp\*' }
  try {
    Remove-Item $tempPaths -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host ' done' -ForegroundColor Green
  }
  catch { Write-Host ' partial' -ForegroundColor Yellow }

  Write-Host 'Recycle Bin...' -NoNewline
  try { Clear-RecycleBin -Force -ErrorAction SilentlyContinue; Write-Host ' done' -ForegroundColor Green }
  catch { Write-Host ' failed' -ForegroundColor Yellow }

  if ($isAdmin) {
    Write-Host 'Disk Cleanup...' -NoNewline
    try { Start-Process 'cleanmgr.exe' -ArgumentList '/sagerun:1' -Wait -NoNewWindow; Write-Host ' done' -ForegroundColor Green }
    catch { Write-Host ' failed' -ForegroundColor Yellow }
  }
  else {
    Write-Host 'Disk Cleanup skipped (requires admin).' -ForegroundColor DarkGray
  }

  Write-Host "`nDone!" -ForegroundColor Green
}

function Connect-Bandit {
  param([Parameter(Mandatory)] [int] $Level)
  $user = "bandit$Level"
  $server = 'bandit.labs.overthewire.org'
  $port = 2220
  Write-Host "Connecting to Bandit Level $Level..." -ForegroundColor Cyan
  Write-Host "ssh $user@$server -p $port" -ForegroundColor Yellow
  # Direct call instead of Invoke-Expression — avoids injection risk
  & ssh "$user@$server" -p $port
}

function Update-Scoop {
  try {
    $PSNativeCommandUseErrorActionPreference = $false
    foreach ($arguments in @(@('update','*'), @('cleanup','*'), @('cache','rm','*'))) {
      $global:LASTEXITCODE = 0
      & scoop @arguments
      if ($LASTEXITCODE -ne 0) { throw "scoop $($arguments -join ' ') failed (exit $LASTEXITCODE). Later cleanup steps were skipped." }
    }
    Write-Host 'Scoop update and cleanup completed.' -ForegroundColor Green
  } catch { Write-Error $_ -ErrorAction Continue }
}
