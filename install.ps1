# ============================================================
#  install.ps1 — Dotfiles bootstrap
#  Usage: irm https://raw.githubusercontent.com/sayidrahmatulloh/win-dotfiles/main/install.ps1 | iex
# ============================================================

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ── Constants ──────────────────────────────────────────────────────────────────

$DOTFILES = "$HOME\.win-dotfiles"
$REPO     = 'https://github.com/sayidrahmatulloh/win-dotfiles'

# ── Admin check ───────────────────────────────────────────────────────────────

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)
if (-not $isAdmin) {
    Write-Host '  Relaunching as Administrator...' -ForegroundColor Yellow
    Start-Process pwsh -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

# ── Output helpers (inline — lib not available before clone) ───────────────────

function Write-Title   { param([string]$Msg) Write-Host "`n  ==> $Msg" -ForegroundColor Cyan   }
function Write-Done    { param([string]$Msg) Write-Host "  [+] $Msg"   -ForegroundColor Green  }
function Write-Skip    { param([string]$Msg) Write-Host "  [~] $Msg"   -ForegroundColor Gray   }
function Write-Warn    { param([string]$Msg) Write-Host "  [!] $Msg"   -ForegroundColor Yellow }

# ── Steps ──────────────────────────────────────────────────────────────────────

function Install-Scoop {
    Write-Title 'Setting up Scoop'

    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Skip 'Scoop already installed'
    } else {
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
        Invoke-RestMethod -Uri 'https://get.scoop.sh' | Invoke-Expression
        Write-Done 'Scoop installed'
    }

    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        scoop install git
        $env:PATH += ';C:\Program Files\Git\cmd'
        Write-Done 'Git installed'
    }
}

function Sync-Repo {
    Write-Title 'Cloning dotfiles'

    if (Test-Path $DOTFILES) {
        Write-Warn 'Already exists — pulling latest...'
        git -C $DOTFILES pull
    } else {
        git clone $REPO $DOTFILES
    }

    Write-Done "Repo ready: $DOTFILES"
}

function Install-ScoopPackages {
    Write-Title 'Installing Scoop packages'
    & "$DOTFILES\packages\scoop.ps1"
}

function Install-WingetApps {
    Write-Title 'Installing Winget apps'
    & "$DOTFILES\packages\winget.ps1"
}

function Install-Fonts {
    Write-Title 'Installing fonts'
    & "$DOTFILES\fonts\fonts.ps1"
}

function Install-PSModules {
    Write-Title 'Installing PowerShell modules'

    $module = 'Microsoft.WinGet.CommandNotFound'

    if (Get-Module -ListAvailable -Name $module) {
        Write-Skip "$module already installed"
    } else {
        Install-Module $module -Repository PSGallery -Force -Scope CurrentUser
        Write-Done "$module installed"
    }
}

function Set-Symlinks {
    Write-Title 'Linking configs'
    & "$DOTFILES\config\symlinks.ps1"
}

# ── Entry point ────────────────────────────────────────────────────────────────

function Main {
    Install-Scoop
    Sync-Repo
    Install-ScoopPackages
    Install-WingetApps
    Install-Fonts
    Install-PSModules
    Set-Symlinks

    Write-Host "`n  All done! Restart your terminal.`n" -ForegroundColor Green
}

Main
