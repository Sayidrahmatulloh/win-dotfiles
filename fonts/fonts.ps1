# ============================================================
#  fonts/fonts.ps1
# ============================================================

# ── Admin check ──────────────────────────────────────────────
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent() ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "  Run as Administrator!" -ForegroundColor Red
    exit 1
}

$systemFonts = "C:\Windows\Fonts"
$filesDir    = "$PSScriptRoot\files"
$tempDir     = "$env:TEMP\dotfiles-fonts"

# ── Font install function ─────────────────────────────────────
function Install-FontFile {
    param([string] $fontPath)
    $name = Split-Path $fontPath -Leaf
    $dest = "$systemFonts\$name"

    if (-not (Test-Path $dest)) {
        $shell = New-Object -ComObject Shell.Application
        $shell.Namespace(0x14).CopyHere($fontPath, 0x10)
        Write-Host "  installed: $name" -ForegroundColor Green
    } else {
        Write-Host "  skipped:   $name (already installed)" -ForegroundColor Gray
    }
}

# ── Scoop fonts ──────────────────────────────────────────────
Write-Host "`n==> Scoop fonts" -ForegroundColor Cyan

scoop bucket add nerd-fonts 2>$null

$scoopFonts = @(
    "JetBrainsMono-NF"
    "CascadiaCode-NF"
    "FiraCode-NF"
)

foreach ($font in $scoopFonts) {
    if (-not (scoop list $font 2>$null | Select-String $font)) {
        scoop install $font
        Write-Host "  installed: $font" -ForegroundColor Green
    } else {
        Write-Host "  skipped:   $font (already installed)" -ForegroundColor Gray
    }
}

# ── Fonts from zip files ─────────────────────────────────────
Write-Host "`n==> Zip fonts" -ForegroundColor Cyan

# Clean up temp dir before extraction
if (Test-Path $tempDir) {
    Remove-Item $tempDir -Recurse -Force
}
New-Item -ItemType Directory -Path $tempDir | Out-Null

Get-ChildItem "$filesDir\*.zip" | ForEach-Object {
    Write-Host "`n  Extracting $($_.Name)..." -ForegroundColor Cyan

    # Extract each zip into its own subfolder to avoid conflicts
    $extractPath = "$tempDir\$($_.BaseName)"
    Expand-Archive -Path $_.FullName -DestinationPath $extractPath -Force

    Get-ChildItem "$extractPath\*.ttf", "$extractPath\*.otf" -Recurse | ForEach-Object {
        Install-FontFile $_.FullName
    }
}

# ── Cleanup ────────────────────
