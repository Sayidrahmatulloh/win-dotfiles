# ============================================================
#  install.ps1 — Dotfiles bootstrap
#  Usage: irm https://raw.githubusercontent.com/sayidrahmatulloh/win-dotfiles/main/install.ps1 | iex
# ============================================================

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ── Constants ──────────────────────────────────────────────────────────────────

$DOTFILES = "$HOME\win-dotfiles"
$REPO = 'https://github.com/sayidrahmatulloh/win-dotfiles'

# ── Minimal inline helpers (lib not yet available) ────────────────────────────

$ESC = [char]27
$RESET = "$ESC[0m"; $BOLD = "$ESC[1m"
$GRAY = "$ESC[90m"; $RED = "$ESC[91m"
$GREEN = "$ESC[92m"; $CYAN = "$ESC[96m"

function _done { param([string]$M) Write-Host "  ${GREEN}[+]${RESET}  $M" }
function _skip { param([string]$M) Write-Host "  ${GRAY}[~]${RESET}  ${GRAY}$M${RESET}" }
function _warn { param([string]$M) Write-Host "  ${GRAY}[!]${RESET}  ${GRAY}$M${RESET}" }
function _fail { param([string]$M) Write-Host "  ${RED}[x]${RESET}  ${RED}$M${RESET}"; exit 1 }

# ── Guards ─────────────────────────────────────────────────────────────────────

function Assert-OS {
  if ($PSVersionTable.PSVersion.Major -lt 7) {
    _fail "PowerShell 7+ required. Current: $($PSVersionTable.PSVersion)"
  }
}

function Assert-Admin {
  $principal = [Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
  $isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

  if (-not $isAdmin) {
    _fail 'Run as Administrator (right-click → Run as Administrator).'
  }
}

# ── Bootstrap steps ───────────────────────────────────────────────────────────

function Install-Scoop {
  Write-Host "`n  ${BOLD}${CYAN}==>  Scoop${RESET}"

  if (Get-Command scoop -ErrorAction SilentlyContinue) {
    _skip 'Scoop already installed'
    $null = scoop update *>&1
  }
  else {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-RestMethod 'https://get.scoop.sh' | Invoke-Expression
    _done 'Scoop installed'
  }

  if (Get-Command git -ErrorAction SilentlyContinue) {
    _skip 'git already installed'
  }
  else {
    $null = scoop install git *>&1
    # Inject git into PATH for the rest of this session
    $scoopCmd = Get-Command 'scoop' -ErrorAction SilentlyContinue
    if ($scoopCmd) {
      $gitBin = "$(Split-Path (Split-Path $scoopCmd.Source -Parent) -Parent)\apps\git\current\cmd"
      if (Test-Path $gitBin) { $env:PATH = "$gitBin;$env:PATH" }
    }
    _done 'git installed'
  }
}

function Sync-Repo {
  Write-Host "`n  ${BOLD}${CYAN}==>  Dotfiles${RESET}"

  if (Test-Path "$DOTFILES\.git") {
    _skip "Already cloned at $DOTFILES"
  }
  elseif (Test-Path $DOTFILES) {
    _fail "'$DOTFILES' exists but is not a git repo. Remove it and re-run."
  }
  else {
    $out = git clone --depth=1 $REPO $DOTFILES 2>&1
    if ($LASTEXITCODE -ne 0) {
      Write-Host ($out | Out-String).Trim() -ForegroundColor DarkGray
      _fail 'git clone failed.'
    }
    _done "Repo cloned: $DOTFILES"
  }
}

# ── Entry point ────────────────────────────────────────────────────────────────

function Main {
  Assert-OS
  Assert-Admin

  Install-Scoop
  Sync-Repo

  # Load shared helpers now that repo is on disk
  . "$DOTFILES\lib\utils.ps1"

  Write-Banner

  $script:anyFailed = $false

  Write-Stage '📦' 'Scoop Packages'
  Invoke-Step 'Scoop packages' { & "$DOTFILES\packages\scoop.ps1" }

  Write-Stage '🪟' 'Winget Apps'
  Invoke-Step 'Winget apps' { & "$DOTFILES\packages\winget.ps1" }

  Write-Stage '🔤' 'Fonts'
  Invoke-Step 'Fonts' { & "$DOTFILES\fonts\fonts.ps1" }

  Write-Stage '📦' 'PowerShell Modules'
  Invoke-Step 'PS modules' { Install-PSModules }

  Write-Stage '🔗' 'Symlinks'
  Invoke-Step 'Symlinks' { & "$DOTFILES\config\symlinks.ps1" }

  # ── Final banner ──────────────────────────────────────────────────────────
  Write-Host ''
  if ($script:anyFailed) {
    Write-Host "  ${LYELLOW}${BOLD}⚠  Done with errors — review output above and re-run.${RESET}"
  }
  else {
    Write-Host "  ${LGREEN}${BOLD}✔  All done! Restart your terminal.${RESET}"
  }
  Write-Host ''
}

function Install-PSModules {
  $modules = @('Microsoft.WinGet.CommandNotFound')

  foreach ($m in $modules) {
    if (Get-Module -ListAvailable -Name $m -ErrorAction SilentlyContinue) {
      Write-Skip "$m already installed"
    }
    else {
      Install-Module $m -Repository PSGallery -Force -Scope CurrentUser -ErrorAction SilentlyContinue
      if (Get-Module -ListAvailable -Name $m -ErrorAction SilentlyContinue) {
        Write-Done "installed: $m"
      }
      else {
        Write-Warn "could not install: $m"
      }
    }
  }
}

Main
