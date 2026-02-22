# ============================================================
#  fonts/fonts.ps1 — Install system fonts via Scoop and zip files
# ============================================================

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\..\lib\utils.ps1"

# ── Constants ──────────────────────────────────────────────────────────────────

$SYSTEM_FONTS = 'C:\Windows\Fonts'
$FILES_DIR    = "$PSScriptRoot\files"
$TEMP_DIR     = "$env:TEMP\dotfiles-fonts"

$SCOOP_FONTS = @(
    'JetBrainsMono-NF',
    'CascadiaCode-NF',
    'FiraCode-NF'
)

# ── Helpers ────────────────────────────────────────────────────────────────────

function Test-ScoopFontInstalled {
    param([string]$Font)
    $result = scoop info $Font 2>&1 | Out-String
    return $result -match 'Installed'
}

function Install-FontFile {
    param([string]$FontPath)

    $name = Split-Path $FontPath -Leaf
    $dest = "$SYSTEM_FONTS\$name"

    if (Test-Path $dest) {
        Write-Skip $name
        return
    }

    $shell = New-Object -ComObject Shell.Application
    $shell.Namespace(0x14).CopyHere($FontPath, 0x10)
    Write-Done $name
}

function Reset-TempDir {
    param([string]$Path)
    if (Test-Path $Path) { Remove-Item $Path -Recurse -Force }
    New-Item -ItemType Directory -Path $Path | Out-Null
}

# ── Core logic ─────────────────────────────────────────────────────────────────

function Install-ScoopFonts {
    param([string[]]$Fonts)

    Write-Section 'Scoop fonts:'
    scoop bucket add nerd-fonts 2>$null

    foreach ($font in $Fonts) {
        if (Test-ScoopFontInstalled $font) {
            Write-Skip $font
            continue
        }
        scoop install $font
        Write-Done $font
    }
}

function Install-ZipFonts {
    param([string]$FilesDir, [string]$TempDir)

    Write-Section 'Zip fonts:'
    Reset-TempDir $TempDir

    Get-ChildItem "$FilesDir\*.zip" | ForEach-Object {
        Write-Host "  extracting $($_.Name)..." -ForegroundColor DarkGray

        $extractPath = "$TempDir\$($_.BaseName)"
        Expand-Archive -Path $_.FullName -DestinationPath $extractPath -Force

        Get-ChildItem "$extractPath\*.ttf", "$extractPath\*.otf" -Recurse |
            ForEach-Object { Install-FontFile $_.FullName }
    }

    Remove-Item $TempDir -Recurse -Force
}

# ── Entry point ────────────────────────────────────────────────────────────────

function Main {
    Install-ScoopFonts $SCOOP_FONTS
    Install-ZipFonts   $FILES_DIR $TEMP_DIR
}

Main
