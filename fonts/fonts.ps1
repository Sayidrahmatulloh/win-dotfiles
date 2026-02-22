# ============================================================
#  fonts/fonts.ps1 — Install system fonts via Scoop and zip files
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

$SYSTEM_FONTS = 'C:\Windows\Fonts'
$FILES_DIR    = "$PSScriptRoot\files"
$TEMP_DIR     = "$env:TEMP\dotfiles-fonts"

$SCOOP_FONTS = @(
    'JetBrainsMono-NF',
    'CascadiaCode-NF',
    'FiraCode-NF'
)

# ── Output helpers ─────────────────────────────────────────────────────────────

function Write-SectionHeader {
    param([string]$Title)
    Write-Host ''
    Write-Host "  $Title" -ForegroundColor Cyan
}

function Write-Installed { param([string]$Name) Write-Host "  [+] installed: $Name" -ForegroundColor Green }
function Write-Skipped   { param([string]$Name) Write-Host "  [~] skipped:   $Name (already installed)" -ForegroundColor Gray }

# ── Font helpers ───────────────────────────────────────────────────────────────

function Install-FontFile {
    param([string]$FontPath)

    $name = Split-Path $FontPath -Leaf
    $dest = "$SYSTEM_FONTS\$name"

    if (Test-Path $dest) {
        Write-Skipped $name
        return
    }

    $shell = New-Object -ComObject Shell.Application
    $shell.Namespace(0x14).CopyHere($FontPath, 0x10)
    Write-Installed $name
}

function Test-ScoopFontInstalled {
    param([string]$Font)
    return [bool](scoop list $Font 2>&1 | Select-String $Font)
}

# ── Core logic ─────────────────────────────────────────────────────────────────

function Install-ScoopFonts {
    param([string[]]$Fonts)

    Write-SectionHeader 'Scoop fonts'
    scoop bucket add nerd-fonts 2>$null

    foreach ($font in $Fonts) {
        if (Test-ScoopFontInstalled $font) {
            Write-Skipped $font
            continue
        }

        scoop install $font
        Write-Installed $font
    }
}

function Install-ZipFonts {
    param([string]$FilesDir, [string]$TempDir)

    Write-SectionHeader 'Zip fonts'

    Reset-TempDir $TempDir

    Get-ChildItem "$FilesDir\*.zip" | ForEach-Object {
        Write-Host "  Extracting $($_.Name)..." -ForegroundColor DarkGray

        $extractPath = "$TempDir\$($_.BaseName)"
        Expand-Archive -Path $_.FullName -DestinationPath $extractPath -Force

        Get-ChildItem "$extractPath\*.ttf", "$extractPath\*.otf" -Recurse |
            ForEach-Object { Install-FontFile $_.FullName }
    }
}

function Reset-TempDir {
    param([string]$Path)

    if (Test-Path $Path) {
        Remove-Item $Path -Recurse -Force
    }
    New-Item -ItemType Directory -Path $Path | Out-Null
}

function Remove-TempDir {
    param([string]$Path)

    if (Test-Path $Path) {
        Remove-Item $Path -Recurse -Force
        Write-Host "`n  Cleaned up temp dir." -ForegroundColor DarkGray
    }
}

# ── Entry point ────────────────────────────────────────────────────────────────

function Main {
    Install-ScoopFonts $SCOOP_FONTS
    Install-ZipFonts   $FILES_DIR $TEMP_DIR
    Remove-TempDir     $TEMP_DIR
}

Main
