# ============================================================
#  config/symlinks.ps1 — Link configs to their correct paths
# ============================================================

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ── Admin check ────────────────────────────────────────────────────────────────

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)
if (-not $isAdmin) {
    Write-Host '  Run as Administrator!' -ForegroundColor Red
    exit 1
}

# ── Constants ──────────────────────────────────────────────────────────────────

$DOTFILES     = Split-Path $PSScriptRoot -Parent
$PROFILE_PATH = "C:\Users\$env:USERNAME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
$PROFILE_LINE = '. $env:USERPROFILE\.config\powershell\user_profile.ps1'

$SYMLINKS = @(
    @{ Src = "$DOTFILES\config\powershell"; Dst = "$env:USERPROFILE\.config\powershell" },
    @{ Src = "$DOTFILES\config\nvim";       Dst = "$env:LOCALAPPDATA\nvim"              },
    @{ Src = "$DOTFILES\config\glzr";       Dst = "$env:USERPROFILE\.glzr"             }
)

# ── Output helpers ─────────────────────────────────────────────────────────────

function Write-Linked  { param([string]$Path) Write-Host "  [+] linked:  $Path" -ForegroundColor Green }
function Write-Skipped { param([string]$Path) Write-Host "  [~] skipped: $Path (already linked)" -ForegroundColor Gray }

# ── Symlink helpers ────────────────────────────────────────────────────────────

function Assert-ParentDir {
    param([string]$Path)
    $dir = Split-Path $Path -Parent
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

function Test-SymlinkValid {
    param([string]$Src, [string]$Dst)
    # Get-Item -Force detects broken symlinks too (Test-Path misses them)
    $item = Get-Item $Dst -Force -ErrorAction SilentlyContinue
    return $item -and $item.LinkType -eq 'SymbolicLink' -and $item.Target -eq $Src
}

function New-Symlink {
    param([string]$Src, [string]$Dst)

    Assert-ParentDir $Dst

    if (Test-SymlinkValid -Src $Src -Dst $Dst) {
        Write-Skipped $Dst
        return
    }

    $existing = Get-Item $Dst -Force -ErrorAction SilentlyContinue
    if ($existing) {
        Remove-Item $Dst -Recurse -Force
    }

    New-Item -ItemType SymbolicLink -Path $Dst -Target $Src -Force | Out-Null
    Write-Linked $Dst
}

# ── Profile helpers ────────────────────────────────────────────────────────────

function Assert-ProfileFile {
    param([string]$Path)
    $dir = Split-Path $Path -Parent
    if (-not (Test-Path $dir))  { New-Item -ItemType Directory -Path $dir  -Force | Out-Null }
    if (-not (Test-Path $Path)) { New-Item -ItemType File      -Path $Path -Force | Out-Null }
}

function Set-ProfileEntry {
    param([string]$ProfilePath, [string]$Line)

    Assert-ProfileFile $ProfilePath

    $exists = Get-Content $ProfilePath -ErrorAction SilentlyContinue |
              Select-String -SimpleMatch $Line

    if ($exists) {
        Write-Skipped $ProfilePath
    } else {
        Add-Content -Path $ProfilePath -Value $Line
        Write-Linked $ProfilePath
    }
}

# ── Entry point ────────────────────────────────────────────────────────────────

function Initialize-ConfigDirs {
    Write-Host ''
    Write-Host '  Config dirs:' -ForegroundColor White

    foreach ($link in $SYMLINKS) {
        if (-not (Test-Path $link.Src)) {
            New-Item -ItemType Directory -Path $link.Src -Force | Out-Null
            Write-Host "  [+] created: $($link.Src)" -ForegroundColor Cyan
        } else {
            Write-Host "  [~] exists:  $($link.Src)" -ForegroundColor Gray
        }
    }
}

function Main {
    Initialize-ConfigDirs

    Write-Host ''
    Write-Host '  Symlinks:' -ForegroundColor White

    foreach ($link in $SYMLINKS) {
        New-Symlink -Src $link.Src -Dst $link.Dst
    }

    Write-Host ''
    Write-Host '  Profile:' -ForegroundColor White
    Set-ProfileEntry -ProfilePath $PROFILE_PATH -Line $PROFILE_LINE
}

Main
