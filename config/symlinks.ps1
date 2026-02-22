# ============================================================
#  config/symlinks.ps1 — Link configs to their correct paths
# ============================================================

# ── Admin check ──────────────────────────────────────────────
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "  Run as Administrator!" -ForegroundColor Red
    exit 1
}

$DOTFILES = Split-Path $PSScriptRoot -Parent

# ── Create config dirs if not exists ─────────────────────────
$dirs = @(
    "$DOTFILES\config\powershell"
    "$DOTFILES\config\nvim"
    "$DOTFILES\config\glzr"
)

foreach ($dir in $dirs) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "  created: $dir" -ForegroundColor Cyan
    }
}

# ── Symlink function ──────────────────────────────────────────
function Link($src, $dst) {
    # Create parent dir if not exists
    $dir = Split-Path $dst -Parent
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    # Remove existing file or folder
    if (Test-Path $dst) {
        Remove-Item $dst -Recurse -Force
    }

    New-Item -ItemType SymbolicLink -Path $dst -Target $src -Force | Out-Null
    Write-Host "  linked: $dst" -ForegroundColor Green
}

# ── Symlinks ──────────────────────────────────────────────────

# PowerShell config dir (user_profile.ps1 + dev.omp.json)
Link "$DOTFILES\config\powershell" "$env:USERPROFILE\.config\powershell"

# Neovim
Link "$DOTFILES\config\nvim" "$env:LOCALAPPDATA\nvim"

# GlazeWM
Link "$DOTFILES\config\glzr" "$env:USERPROFILE\.glzr"

# ── Write entry point to $PROFILE ────────────────────────────
$userProfile = "C:\Users\$env:USERNAME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
$profileLine = '. $env:USERPROFILE\.config\powershell\user_profile.ps1'
$profileDir  = Split-Path $userProfile -Parent

if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

if (-not (Test-Path $userProfile)) {
    New-Item -ItemType File -Path $userProfile -Force | Out-Null
}

if (-not (Get-Content $userProfile -ErrorAction SilentlyContinue | Select-String -SimpleMatch $profileLine)) {
    Add-Content -Path $userProfile -Value $profileLine
    Write-Host "  linked: $userProfile" -ForegroundColor Green
} else {
    Write-Host "  skipped: $userProfile (already linked)" -ForegroundColor Gray
}
