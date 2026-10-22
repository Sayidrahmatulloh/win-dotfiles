# fonts installation functions. Importing this file performs no installation.
function Test-ScoopFontInstalled {
  param([string]$Name, [Parameter(Mandatory)][string]$ScoopRoot)
  Test-Path (Join-Path $ScoopRoot "apps/$Name")
}

function Ensure-NerdFontsBucket {
    if (Test-ScoopBucketAdded 'nerd-fonts') { return }
    $null = Add-ScoopBucket 'nerd-fonts'
    $null = Invoke-PackageCommand scoop @('update')
}

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

function Copy-UserFontFile {
    param([string]$Source, [string]$Destination)
    New-Item -ItemType Directory -Path (Split-Path $Destination -Parent) -Force | Out-Null
    if (-not (Test-Path -LiteralPath $Destination -PathType Leaf)) {
        Copy-Item -LiteralPath $Source -Destination $Destination -ErrorAction Stop
    }
}

function Register-UserFont {
    param([string]$FontPath)
    $registration = Get-FontRegistration (Split-Path $FontPath -Leaf)
    if (-not (Test-Path -LiteralPath $registration.Path)) { New-Item -Path $registration.Path -Force | Out-Null }
    New-ItemProperty -LiteralPath $registration.Path -Name $registration.Name -Value $FontPath -PropertyType String -Force -ErrorAction Stop | Out-Null
    if (-not (Test-FontRegistered $FontPath)) { throw 'Font registration could not be verified.' }
}

function Install-FontFile {
    param([string]$FontPath, [string]$SystemFonts = (Join-Path $env:LOCALAPPDATA 'Microsoft/Windows/Fonts'))
    $name = Split-Path $FontPath -Leaf
    $destination = Join-Path $SystemFonts $name
    if (Test-FontRegistered $destination) { return New-InstallResult -Name $name -Status Latest -Message 'already installed' }
    Copy-UserFontFile -Source $FontPath -Destination $destination
    Register-UserFont -FontPath $destination
    New-InstallResult -Name $name -Status Installed -Message 'installed or repaired'
}

function Install-ScoopFonts {
  param([string[]]$Fonts, [Parameter(Mandatory)][string]$ScoopRoot, [switch]$Update)
  Write-Section 'Scoop fonts:'
  Ensure-NerdFontsBucket
  Sync-Packages -Names $Fonts -Update:$Update `
    -IsInstalled { param($name) Test-ScoopFontInstalled -Name $name -ScoopRoot $ScoopRoot } `
    -Install { param($name) Install-ScoopPackage $name } `
    -Upgrade { param($name) Update-ScoopPackage $name } `
    -Report { param($entry) Write-InstallResult $entry }
}

function Install-ZipFonts {
  param([string]$FilesDir, [string]$TempDir, [string]$SystemFonts = (Join-Path $env:LOCALAPPDATA 'Microsoft/Windows/Fonts'))
  Write-Section 'Zip fonts:'

  $r = New-Results
  $zips = @(Get-ChildItem -LiteralPath $FilesDir -Filter '*.zip' -ErrorAction SilentlyContinue)

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

      $files = @(Get-ChildItem -LiteralPath $dest -Include '*.ttf', '*.otf' -Recurse -ErrorAction SilentlyContinue)

      if ($files.Count -eq 0) {
        Write-Skip "no font files in: $($zip.Name)"
        continue
      }

      foreach ($f in $files) {
        try {
          $entry = Install-FontFile -FontPath $f.FullName -SystemFonts $SystemFonts
          Assert-PackageResult -Result $entry -Name $f.Name -AllowedStatuses Installed,Latest
        } catch {
          $entry = New-InstallResult -Name $f.Name -Status Failed -Message $_.Exception.Message
        }
        Add-InstallResult -Results $r -Entry $entry
        Write-InstallResult $entry
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
