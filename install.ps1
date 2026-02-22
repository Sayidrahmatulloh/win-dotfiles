# ============================================================
#  install.ps1 — Dotfiles bootstrap
#  Usage: irm https://raw.githubusercontent.com/sayidrahmatulloh/win-dotfiles/main/install.ps1 | iex
# ============================================================

$ErrorActionPreference = "Stop"
$DOTFILES = "$HOME\.dotfiles"
$REPO     = "https://github.com/sayidrahmatulloh/win-dotfiles"

function Title($msg)   { Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Success($msg) { Write-Host "  $msg"     -ForegroundColor Green }
function Warn($msg)    { Write-Host "  ! $msg"   -ForegroundColor Yellow }

# 0. Git check
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Title "Installing Git"
    winget install --id Git.Git --silent --accept-package-agreements --accept-source-agreements
    $env:PATH += ";C:\Program Files\Git\cmd"
    Success "Git installed"
}

# 1. Clone
Title "Cloning dotfiles"
if (Test-Path $DOTFILES) {
    Warn "Already exists, pulling..."
    git -C $DOTFILES pull
} else {
    git clone $REPO $DOTFILES
}
Success "Repo ready: $DOTFILES"

# 2. Scoop
Title "Setting up Scoop"
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Invoke-RestMethod get.scoop.sh | Invoke-Expression
    Success "Scoop installed"
} else { Success "Scoop already installed" }
& "$DOTFILES\packages\scoop.ps1"

# 3. Winget
Title "Installing Winget apps"
& "$DOTFILES\packages\winget.ps1"

# 4. Fonts
Title "Installing fonts"
& "$DOTFILES\fonts\fonts.ps1"

# 5. PowerShell modules
Title "Installing PowerShell modules"
if (-not (Get-Module -ListAvailable -Name Microsoft.WinGet.CommandNotFound)) {
    Install-Module Microsoft.WinGet.CommandNotFound -Repository PSGallery -Force -Scope CurrentUser
    Success "Microsoft.WinGet.CommandNotFound installed"
} else { Success "Microsoft.WinGet.CommandNotFound already installed" }

# 6. Symlinks
Title "Linking configs"
& "$DOTFILES\config\symlinks.ps1"

Write-Host "`n  All done! Restart your terminal." -ForegroundColor Green
