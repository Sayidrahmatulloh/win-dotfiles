# ============================================================
#  config/powershell/user_profile.ps1
# ============================================================

# Set PowerShell to UTF-8
[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

# ── Module imports ────────────────────────────────────────────
# Wrapped individually so a missing module doesn't break the entire profile

foreach ($module in @('posh-git', 'Terminal-Icons', 'Microsoft.WinGet.CommandNotFound', 'PSFzf')) {
  try { Import-Module -Name $module -ErrorAction Stop }
  catch { Write-Warning "Module '$module' not found. Run the packages script to install it." }
}

# Oh My Posh
$omp_config = Join-Path $PSScriptRoot "dev.omp.json"
if (Test-Path $omp_config) {
  oh-my-posh --init --shell pwsh --config $omp_config | Invoke-Expression
}
else {
  Write-Warning "Oh My Posh config not found: $omp_config"
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
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'

# ── Env ───────────────────────────────────────────────────────

$gitSsh = 'C:\Windows\system32\OpenSSH\ssh.exe'
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

function Invoke-Cpp {
  param([Parameter(Mandatory)] [string] $cppFilePath)
  if (-not (Test-Path $cppFilePath)) { Write-Error "Error: '$cppFilePath' not found."; return }
  $exe = [IO.Path]::ChangeExtension($cppFilePath, '.exe')
  $out = & g++ "$cppFilePath" -o "$exe" 2>&1
  if ($LASTEXITCODE -ne 0) { Write-Error "Compilation failed:`n$out"; return }
  Write-Host "Compilation successful. Running '$exe'..."
  & $exe
  Remove-Item $exe -Force -ErrorAction SilentlyContinue
}

function Invoke-Zig {
  param([Parameter(Mandatory)] [string] $zigFilePath)
  if (-not (Test-Path $zigFilePath)) { Write-Error "Error: '$zigFilePath' not found."; return }
  $exe = [IO.Path]::ChangeExtension($zigFilePath, '.exe')
  $exeObj = [IO.Path]::ChangeExtension($zigFilePath, '.exe.obj')
  $pdb = [IO.Path]::ChangeExtension($zigFilePath, '.pdb')
  $out = & zig build-exe "$zigFilePath" 2>&1
  if ($LASTEXITCODE -ne 0) { Write-Error "Compilation failed:`n$out"; return }
  Write-Host "Compilation successful. Running '$exe'..."
  & $exe
  # -ErrorAction SilentlyContinue: .pdb and .exe.obj may not always be generated
  Remove-Item $exe, $exeObj, $pdb -Force -ErrorAction SilentlyContinue
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
  $host = 'bandit.labs.overthewire.org'
  $port = 2220
  Write-Host "Connecting to Bandit Level $Level..." -ForegroundColor Cyan
  Write-Host "ssh $user@$host -p $port" -ForegroundColor Yellow
  # Direct call instead of Invoke-Expression — avoids injection risk
  & ssh "$user@$host" -p $port
}

function Update-Scoop {
  try {
    Write-Host "`nUpdating packages..."     -ForegroundColor Yellow; scoop update *
    Write-Host "`nCleaning old versions..." -ForegroundColor Yellow; scoop cleanup *
    Write-Host "`nClearing cache..."        -ForegroundColor Yellow; scoop cache rm *
    Write-Host "`nDone!" -ForegroundColor Green
  }
  catch {
    Write-Host "`nError: $($_.Exception.Message)" -ForegroundColor Red
  }
}
