# ============================================================
#  fonts/fonts.ps1
# ============================================================

$systemFonts = "C:\Windows\Fonts"
$regPath     = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
$filesDir    = "$PSScriptRoot\files"
$tempDir     = "$env:TEMP\dotfiles-fonts"

function Install-FontFile {
    param([string] $fontPath)
    $name = Split-Path $fontPath -Leaf
    $dest = "$systemFonts\$name"
    if (-not (Test-Path $dest)) {
        Copy-Item $fontPath -Destination $systemFonts
        New-ItemProperty -Path $regPath -Name ([IO.Path]::GetFileNameWithoutExtension($fontPath)) `
            -Value $name -PropertyType String -Force | Out-Null
        Write-Host "  installed: $name" -ForegroundColor Green
    } else {
        Write-Host "  skipped:   $name (already installed)" -ForegroundColor Gray
    }
}

# ── Scoop fonts ──────────────────────────────────────────────

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

Get-ChildItem "$filesDir\*.zip" | ForEach-Object {
    Write-Host "`n  Extracting $($_.Name)..." -ForegroundColor Cyan
    Expand-Archive -Path $_.FullName -DestinationPath $tempDir -Force
    Get-ChildItem "$tempDir\*.ttf", "$tempDir\*.otf" -Recurse | ForEach-Object {
        Install-FontFile $_.FullName
    }
    Remove-Item $tempDir -Recurse -Force
}

Write-Host "`n  All fonts installed!" -ForegroundColor Green
