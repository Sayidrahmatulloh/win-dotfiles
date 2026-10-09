# ============================================================
#  scripts/install/fonts.ps1 — Install system fonts via Scoop and zip files
# ============================================================

param([switch]$Update)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\..\..\lib\utils.ps1"

# ── Constants ──────────────────────────────────────────────────────────────────

$SYSTEM_FONTS = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'
$FILES_DIR = Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) "assets/fonts"
$TEMP_DIR = "$env:TEMP\dotfiles-fonts"

$configuration = Get-SetupConfig -RepoRoot (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
$SCOOP_FONTS = $configuration.scoop.fonts

# ── Bootstrap ──────────────────────────────────────────────────────────────────

$SCOOP_ROOT = Get-ScoopRoot
if (-not $SCOOP_ROOT) {
  Write-Fail 'Cannot locate Scoop root directory. Run install.ps1 first.'
  throw 'Scoop root was not found.'
}

# ── Scoop font helpers ────────────────────────────────────────────────────────

function Test-ScoopFontInstalled {
  param([string]$Name)
  Test-Path "$SCOOP_ROOT\apps\$Name"
}

function Ensure-NerdFontsBucket {
    if (Test-BucketAdded 'nerd-fonts') { return }
    $null = Add-Bucket 'nerd-fonts'
    $null = Invoke-PackageCommand scoop @('update')
}

# Check both the file and registry: retry repairs a partial font installation.
function Get-FontRegistration {
    param([string]$FontName)
    @{
        Path = 'HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts'
        Name = [IO.Path]::GetFileNameWithoutExtension($FontName) + ' (TrueType)'
    }
}

function Test-FontRegistered {
    param([string]$FontPath)
    $registration = Get-FontRegistration -FontName (Split-Path $FontPath -Leaf)
    try {
        $value = Get-ItemPropertyValue -LiteralPath $registration.Path -Name $registration.Name -ErrorAction SilentlyContinue
    } catch [System.Management.Automation.PSArgumentException] {
        # The registry provider throws for a missing value even with SilentlyContinue.
        return $false
    }
    return (Test-Path -LiteralPath $FontPath -PathType Leaf) -and ($value -eq $FontPath)
}

function Install-FontFile {
    param(
        [string]$FontPath,
        [System.Collections.Generic.List[string]]$Installed,
        [System.Collections.Generic.List[string]]$Failed
    )
    $name = Split-Path $FontPath -Leaf
    $destination = Join-Path $SYSTEM_FONTS $name
    try {
        if (Test-FontRegistered $destination) { Write-Skip "already installed: $name"; return }
        New-Item -ItemType Directory -Path $SYSTEM_FONTS -Force | Out-Null
        if (-not (Test-Path -LiteralPath $destination -PathType Leaf)) {
            Copy-Item -LiteralPath $FontPath -Destination $destination -ErrorAction Stop
        }
        $registration = Get-FontRegistration $name
        if (-not (Test-Path -LiteralPath $registration.Path)) { New-Item -Path $registration.Path -Force | Out-Null }
        New-ItemProperty -LiteralPath $registration.Path -Name $registration.Name -Value $destination -PropertyType String -Force -ErrorAction Stop | Out-Null
        if (-not (Test-FontRegistered $destination)) { throw 'Font registration could not be verified.' }
        Write-Done "installed or repaired: $name"
        $Installed.Add($name)
    } catch {
        Write-Fail "$name : $($_.Exception.Message)"
        $Failed.Add($name)
    }
}

# ── Core logic ────────────────────────────────────────────────────────────────

function Install-ScoopFonts {
  param([string[]]$Fonts)
  Write-Section 'Scoop fonts:'
  Ensure-NerdFontsBucket
  Sync-Packages -Names $Fonts -Update:$Update `
    -IsInstalled { param($name) Test-ScoopFontInstalled $name } `
    -Install { param($name) Install-Tool $name } `
    -Upgrade { param($name) Update-Tool $name }
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

  $tempRoot = [IO.Path]::GetFullPath($TempDir).TrimEnd('\')
  $workDir = Join-Path $tempRoot ('fonts-' + [guid]::NewGuid().ToString('N'))
  $null = New-Item -ItemType Directory -Path $workDir -Force

  try {
    foreach ($zip in $zips) {
      Write-Step '  ' $zip.Name 'extracting'
      $dest = "$workDir\$($zip.BaseName)"
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
    # Delete only this run's checked private directory, never the shared temp root.
    $resolvedWorkDir = [IO.Path]::GetFullPath($workDir)
    if (-not $resolvedWorkDir.StartsWith($tempRoot + '\', [StringComparison]::OrdinalIgnoreCase)) {
      throw 'Font extraction directory is outside its temporary root.'
    }
    if (Test-Path -LiteralPath $resolvedWorkDir) { Remove-Item -LiteralPath $resolvedWorkDir -Recurse -Force }
  }

  return $r
}

# ── Entry point ────────────────────────────────────────────────────────────────

$combined = Merge-Results (Install-ScoopFonts $SCOOP_FONTS) (Install-ZipFonts $FILES_DIR $TEMP_DIR)
Write-Summary 'Fonts' $combined

if ($combined.Failed.Count) { throw "Fonts failed: $($combined.Failed -join ', ')" }
