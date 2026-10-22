# links installation functions. Importing this file performs no installation.
function Write-LinkPermissionHint {
  $principal = [Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
  $isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

  if (-not $isAdmin) {
    Write-Warn 'Running without Administrator rights. Junctions will be used for directory links.'
  }
}

function Initialize-SourceDirs {
  param([array]$Links)

  foreach ($link in $Links) {
    if (Test-Path $link.Src -PathType Leaf) {
      throw "Source is a file, expected a directory: $($link.Src)"
    }

    if (Test-Path $link.Src -PathType Container) {
      Write-Skip "exists: $($link.Src)"
      continue
    }

    throw "Configuration source is missing: $($link.Src)"
  }
}

function Restore-ConfigLinkBackup {
    param([Parameter(Mandatory)][string]$Destination, [Parameter(Mandatory)][string]$BackupPath)
    if (-not (Get-Item -LiteralPath $BackupPath -Force -ErrorAction SilentlyContinue)) { throw "Backup is missing: $BackupPath" }
    $partial = Get-Item -LiteralPath $Destination -Force -ErrorAction SilentlyContinue
    if ($partial) {
        if ($partial.LinkType -notin @('Junction', 'SymbolicLink')) { throw "Destination contains a real folder; backup kept at $BackupPath" }
        Remove-Item -LiteralPath $Destination -Force -ErrorAction Stop
    }
    Move-Item -LiteralPath $BackupPath -Destination $Destination -ErrorAction Stop
}

function New-Symlink {
    param([Parameter(Mandatory)][string]$Src, [Parameter(Mandatory)][string]$Dst)
    $backup = ''
    try {
        if (-not (Test-Path -LiteralPath $Src -PathType Container)) { throw "Source folder is missing: $Src" }
        if (Test-ConfigLink -Source $Src -Destination $Dst) {
            return New-InstallResult -Name $Dst -Status Latest -Message 'already linked'
        }
        New-Item -ItemType Directory -Path (Split-Path $Dst -Parent) -Force | Out-Null
        $backup = Move-ConfigEntryToBackup -Path $Dst
        New-DirectoryLink -Source $Src -Destination $Dst
        return New-InstallResult -Name $Dst -Status Installed -Message 'linked' -BackupPath $backup
    } catch {
        $message = $_.Exception.Message
        $rollbackError = ''
        if ($backup) {
            try { Restore-ConfigLinkBackup -Destination $Dst -BackupPath $backup }
            catch { $rollbackError = $_.Exception.Message }
        }
        return New-InstallResult -Name $Dst -Status Failed -Message $message -BackupPath $backup -RollbackError $rollbackError
    }
}

function Set-ProfileEntry {
  param([string]$ProfilePath, [string]$Line)

  $dir = Split-Path $ProfilePath -Parent
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir         -Force | Out-Null }
  if (-not (Test-Path $ProfilePath)) { New-Item -ItemType File      -Path $ProfilePath -Force | Out-Null }

  $content = Get-Content $ProfilePath -Raw -ErrorAction SilentlyContinue

  $alreadyPresent = $content -and (
    $content -split "`n" | Where-Object { $_.Trim() -eq $Line.Trim() }
  )

  if ($alreadyPresent) {
    Write-Skip "profile entry already present: $ProfilePath"
    return
  }

  $separator = if ($content -and -not $content.EndsWith("`n")) { [Environment]::NewLine } else { '' }
  Add-Content -LiteralPath $ProfilePath -Value ($separator + $Line)
  Write-Done "profile entry added: $ProfilePath"
}

function Install-ConfigLinks {
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [Parameter(Mandatory)][string]$ProfilePath,
        [string]$ZebarDirectory = (Join-Path $env:USERPROFILE '.glzr/zebar')
    )
    Write-LinkPermissionHint
    Assert-ZebarConfiguration -RepoRoot $RepoRoot
    $links = @(Get-ConfigLinks -RepoRoot $RepoRoot -Configuration (Get-SetupConfig -RepoRoot $RepoRoot))
    Initialize-SourceDirs $links
    Initialize-ZebarRuntime -RepoRoot $RepoRoot -Destination $ZebarDirectory

    Write-Section 'Symlinks:'
    $results = New-Results
    foreach ($link in ($links | Where-Object { $_.Dst -notlike (Join-Path $ZebarDirectory '*') })) {
        $entry = New-Symlink -Src $link.Src -Dst $link.Dst
        Add-InstallResult -Results $results -Entry $entry
        Write-InstallResult $entry
    }
    Write-Section 'Profile:'
    Set-ProfileEntry -ProfilePath $ProfilePath -Line (Get-PowerShellProfileLine)
    Complete-InstallResults -Name 'Symlinks' -Results $results -FailureLabel 'Links'
}
