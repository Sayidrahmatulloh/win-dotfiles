# ============================================================
#  fonts/fonts.ps1 — Install system fonts via Scoop and zip files
# ============================================================

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\..\lib\utils.ps1"

# ── Constants ──────────────────────────────────────────────────────────────────

$SYSTEM_FONTS = 'C:\Windows\Fonts'
$FILES_DIR = "$PSScriptRoot\files"
$TEMP_DIR = "$env:TEMP\dotfiles-fonts"

$SCOOP_FONTS = @(
  'JetBrainsMono-NF'
  'CascadiaCode-NF'
  'FiraCode-NF'
)

# ── Bootstrap ──────────────────────────────────────────────────────────────────

$SCOOP_ROOT = Get-ScoopRoot
if (-not $SCOOP_ROOT) {
  Write-Fail 'Cannot locate Scoop root directory. Run install.ps1 first.'
  exit 1
}

# ── Scoop font helpers ────────────────────────────────────────────────────────

function Test-ScoopFontInstalled {
  param([string]$Name)
  Test-Path "$SCOOP_ROOT\apps\$Name"
}

function Ensure-NerdFontsBucket {
  if (Test-Path "$SCOOP_ROOT\buckets\nerd-fonts") { return }
  Write-Step '  ' 'nerd-fonts' 'adding bucket'
  $null = scoop bucket add nerd-fonts *>&1
  if ($LASTEXITCODE -eq 0) {
    Write-Done 'bucket added: nerd-fonts'
    $null = scoop update *>&1
  }
  else {
    Write-Fail 'failed to add nerd-fonts bucket'
  }
}

function Update-ScoopFont {
  param([string]$Name)
  $out = scoop update $Name *>&1
  if ($LASTEXITCODE -ne 0) { return 'failed' }
  if ($out -match 'Latest versions for all apps are installed' -or
    $out -match 'is already the newest version') { return 'latest' }
  return 'upgraded'
}

# ── File font helpers ─────────────────────────────────────────────────────────

function Install-FontFile {
  param(
    [string]$FontPath,
    [System.Collections.Generic.List[string]]$Installed,
    [System.Collections.Generic.List[string]]$Failed
  )

  $name = Split-Path $FontPath -Leaf
  $dest = "$SYSTEM_FONTS\$name"

  if (Test-Path $dest) {
    Write-Skip "already installed: $name"
    return
  }

  try {
    # WHY Shell.Application:
    # C:\Windows\Fonts is a Shell namespace folder. Direct Copy-Item is blocked
    # by the kernel even for admins. CopyHere() goes through the correct Shell
    # API, handles registry registration automatically.
    $shell = New-Object -ComObject Shell.Application
    $shell.Namespace(0x14).CopyHere($FontPath, 0x414)
    # 0x04 = no progress | 0x10 = no UI | 0x400 = no error UI

    # CopyHere is async — poll until the file appears (max 10 s)
    $deadline = (Get-Date).AddSeconds(10)
    while (-not (Test-Path $dest) -and (Get-Date) -lt $deadline) {
      Start-Sleep -Milliseconds 200
    }

    if (Test-Path $dest) {
      Write-Done "installed: $name"
      $Installed.Add($name)
    }
    else {
      Write-Fail "timed out: $name"
      $Failed.Add($name)
    }
  }
  catch {
    Write-Fail "failed: $name — $($_.Exception.Message)"
    $Failed.Add($name)
  }
}

# ── Core logic ────────────────────────────────────────────────────────────────

function Install-ScoopFonts {
  param([string[]]$Fonts)
  Write-Section 'Scoop fonts:'
  Ensure-NerdFontsBucket

  $r = New-Results
  $i = 0

  foreach ($font in $Fonts) {
    $i++
    $pfx = "  [$i/$($Fonts.Count)]"

    if (Test-ScoopFontInstalled $font) {
      Write-Step $pfx $font 'upgrading'
      switch (Update-ScoopFont $font) {
        'upgraded' { Write-Done "upgraded: $font"; $r.Upgraded.Add($font) }
        'latest' { Write-Skip "up to date: $font"; $r.Latest.Add($font) }
        'failed' { Write-Fail "upgrade failed: $font"; $r.Failed.Add($font) }
      }
    }
    else {
      Write-Step $pfx $font 'installing'
      $null = scoop install $font *>&1
      if ($LASTEXITCODE -eq 0) {
        Write-Done "installed: $font"
        $r.Installed.Add($font)
      }
      else {
        Write-Fail "failed: $font"
        $r.Failed.Add($font)
      }
    }
  }

  return $r
}

function Install-ZipFonts {
  param([string]$FilesDir, [string]$TempDir)
  Write-Section 'Zip fonts:'

  $r = New-Results
  $zips = @(Get-ChildItem "$FilesDir\*.zip" -ErrorAction SilentlyContinue)

  if ($zips.Count -eq 0) {
    Write-Skip 'no zip archives found'
    return $r
  }

  if (Test-Path $TempDir) { Remove-Item $TempDir -Recurse -Force }
  $null = New-Item -ItemType Directory -Path $TempDir

  try {
    foreach ($zip in $zips) {
      Write-Step '  ' $zip.Name 'extracting'
      $dest = "$TempDir\$($zip.BaseName)"
      Expand-Archive -Path $zip.FullName -DestinationPath $dest -Force
      Write-Host ''   # newline after inline Write-Step

      $files = @(Get-ChildItem $dest -Include '*.ttf', '*.otf' -Recurse -ErrorAction SilentlyContinue)

      if ($files.Count -eq 0) {
        Write-Skip "no font files in: $($zip.Name)"
        continue
      }

      foreach ($f in $files) {
        Install-FontFile $f.FullName $r.Installed $r.Failed
      }
    }
  }
  finally {
    if (Test-Path $TempDir) { Remove-Item $TempDir -Recurse -Force }
  }

  return $r
}

# ── Entry point ────────────────────────────────────────────────────────────────

$combined = Merge-Results (Install-ScoopFonts $SCOOP_FONTS) (Install-ZipFonts $FILES_DIR $TEMP_DIR)
Write-Summary 'Fonts' $combined
