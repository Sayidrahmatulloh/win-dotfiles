# ============================================================
#  config/symlinks.ps1 — Link configs to their correct paths
# ============================================================

$DOTFILES = Split-Path $PSScriptRoot -Parent

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
$profileLine = '. $env:USERPROFILE\.config\powershell\user_profile.ps1'
$profileDir  = Split-Path $PROFILE -Parent

if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

if (-not (Test-Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}

if (-not (Get-Content $PROFILE -ErrorAction SilentlyContinue | Select-String -SimpleMatch $profileLine)) {
    Add-Content -Path $PROFILE -Value $profileLine
    Write-Host "  linked: $PROFILE" -ForegroundColor Green
} else {
    Write-Host "  skipped: $PROFILE (already linked)" -ForegroundColor Gray
}
