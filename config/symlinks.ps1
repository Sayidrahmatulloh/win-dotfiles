# ============================================================
#  config/symlinks.ps1 — Link configs to their correct paths
# ============================================================

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\..\lib\utils.ps1"

Assert-Admin

# ── Constants ──────────────────────────────────────────────────────────────────

$DOTFILES     = Split-Path $PSScriptRoot -Parent
$PROFILE_PATH = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
$PROFILE_LINE = '. $env:USERPROFILE\.config\powershell\user_profile.ps1'

$SYMLINKS = @(
    @{ Src = "$DOTFILES\config\powershell"; Dst = "$env:USERPROFILE\.config\powershell" },
    @{ Src = "$DOTFILES\config\nvim";       Dst = "$env:LOCALAPPDATA\nvim"              },
    @{ Src = "$DOTFILES\config\glzr";       Dst = "$env:USERPROFILE\.glzr"             }
)

# ── Helpers ────────────────────────────────────────────────────────────────────

function Initialize-ConfigDirs {
    param([array]$Links)
    foreach ($link in $Links) {
        if (-not (Test-Path $link.Src)) {
            New-Item -ItemType Directory -Path $link.Src -Force | Out-Null
            Write-Done "created: $($link.Src)"
        }
    }
}

function Test-SymlinkValid {
    param([string]$Src, [string]$Dst)
    # Get-Item -Force detects broken symlinks that Test-Path misses
    $item = Get-Item $Dst -Force -ErrorAction SilentlyContinue
    return $item -and $item.LinkType -eq 'SymbolicLink' -and $item.Target -eq $Src
}

function New-Symlink {
    param([string]$Src, [string]$Dst)

    $parentDir = Split-Path $Dst -Parent
    if (-not (Test-Path $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }

    if (Test-SymlinkValid -Src $Src -Dst $Dst) {
        Write-Skip $Dst
        return
    }

    $existing = Get-Item $Dst -Force -ErrorAction SilentlyContinue
    if ($existing) { Remove-Item $Dst -Recurse -Force }

    New-Item -ItemType SymbolicLink -Path $Dst -Target $Src -Force | Out-Null
    Write-Done "linked: $Dst"
}

function Set-ProfileEntry {
    param([string]$ProfilePath, [string]$Line)

    $dir = Split-Path $ProfilePath -Parent
    if (-not (Test-Path $dir))          { New-Item -ItemType Directory -Path $dir          -Force | Out-Null }
    if (-not (Test-Path $ProfilePath))  { New-Item -ItemType File      -Path $ProfilePath  -Force | Out-Null }

    $exists = Get-Content $ProfilePath -ErrorAction SilentlyContinue |
              Select-String -SimpleMatch $Line

    if ($exists) {
        Write-Skip $ProfilePath
    } else {
        Add-Content -Path $ProfilePath -Value $Line
        Write-Done "profile: $ProfilePath"
    }
}

# ── Entry point ────────────────────────────────────────────────────────────────

function Main {
    Write-Section 'Config dirs:'
    Initialize-ConfigDirs $SYMLINKS

    Write-Section 'Symlinks:'
    foreach ($link in $SYMLINKS) {
        New-Symlink -Src $link.Src -Dst $link.Dst
    }

    Write-Section 'Profile:'
    Set-ProfileEntry -ProfilePath $PROFILE_PATH -Line $PROFILE_LINE
}

Main
