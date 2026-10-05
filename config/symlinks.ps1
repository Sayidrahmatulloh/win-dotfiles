# ============================================================
#  config/symlinks.ps1 — Link configs to their correct paths
# ============================================================

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\..\lib\utils.ps1"

# ── Constants ──────────────────────────────────────────────────────────────────

$DOTFILES = Split-Path $PSScriptRoot -Parent
$PROFILE_PATH = if ($PROFILE -and (Test-Path (Split-Path $PROFILE -Parent))) {
  $PROFILE
} elseif ($PROFILE.CurrentUserCurrentHost) {
  $PROFILE.CurrentUserCurrentHost
} else {
  "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
}
$PROFILE_LINE = '. $env:USERPROFILE\.config\powershell\user_profile.ps1'

$SYMLINKS = @(
  @{ Src = "$DOTFILES\config\powershell"; Dst = "$env:USERPROFILE\.config\powershell" }
  @{ Src = "$DOTFILES\config\nvim"; Dst = "$env:LOCALAPPDATA\nvim" }
  @{ Src = "$DOTFILES\config\glzr\glazewm"; Dst = "$env:USERPROFILE\.glzr\glazewm" }
  @{ Src = "$DOTFILES\config\glzr\zebar"; Dst = "$env:USERPROFILE\.glzr\zebar" }
)

# ── Helpers ────────────────────────────────────────────────────────────────────

function Check-Admin {
  $principal = [Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
  $isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

  if (-not $isAdmin) {
    Write-Warn 'Running without Administrator rights. Junctions will be used for directory links.'
  }
}

# Ensure each Src directory exists in the dotfiles repo
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

# Returns $true when $Dst is a symlink or junction pointing exactly to $Src
function Test-SymlinkValid {
  param([string]$Src, [string]$Dst)

  $item = Get-Item $Dst -Force -ErrorAction SilentlyContinue
  if (-not $item -or ($item.LinkType -ne 'SymbolicLink' -and $item.LinkType -ne 'Junction')) { return $false }

  # $item.Target can be [string[]] on Windows — normalise to scalar
  $target = (@($item.Target)[0]).TrimEnd('\')
  $normalizedSrc = $Src.TrimEnd('\')
  return ($target -eq $normalizedSrc)
}

function New-Symlink {
  param(
    [string]$Src,
    [string]$Dst,
    [System.Collections.Generic.List[string]]$Linked,
    [System.Collections.Generic.List[string]]$Failed
  )

  # Ensure parent directory exists
  $parent = Split-Path $Dst -Parent
  if (-not (Test-Path $parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
  }

  # Already correct — nothing to do
  if (Test-SymlinkValid -Src $Src -Dst $Dst) {
    Write-Skip "already linked: $Dst"
    return
  }

  $existing = Get-Item $Dst -Force -ErrorAction SilentlyContinue

  if ($existing) {
    if ($existing.LinkType -in @('SymbolicLink', 'Junction')) {
      # Stale link pointing somewhere else — safe to remove
      Remove-Item $Dst -Force
    }
    else {
      # Real directory or file — safely backup instead of skipping
      $ts = (Get-Date).ToString('yyyyMMdd_HHmmss')
      $bak = "${Dst}.bak_${ts}"
      try {
        Move-Item -Path $Dst -Destination $bak -Force
        Write-Warn "backed up existing folder: $Dst -> $bak"
      }
      catch {
        Write-Fail "could not backup existing folder: $Dst"
        $Failed.Add($Dst)
        return
      }
    }
  }

  try {
    # Try SymbolicLink first, fallback to Junction if unprivileged
    try {
      New-Item -ItemType SymbolicLink -Path $Dst -Target $Src -Force -ErrorAction Stop | Out-Null
    }
    catch {
      New-Item -ItemType Junction -Path $Dst -Target $Src -Force -ErrorAction Stop | Out-Null
    }
    Write-Done "linked: $Dst"
    $Linked.Add($Dst)
  }
  catch {
    Write-Fail "link failed: $Dst — $_"
    $Failed.Add($Dst)
  }
}

# Ensure the PowerShell profile sources our user_profile.ps1
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

  Add-Content -Path $ProfilePath -Value $Line
  Write-Done "profile entry added: $ProfilePath"
}

# ── Entry point ────────────────────────────────────────────────────────────────

function Main {
  Check-Admin

  Write-Section 'Source dirs:'
  Initialize-SourceDirs $SYMLINKS

  Write-Section 'Symlinks:'
  $linked = [System.Collections.Generic.List[string]]::new()
  $failed = [System.Collections.Generic.List[string]]::new()

  foreach ($link in $SYMLINKS) {
    New-Symlink -Src $link.Src -Dst $link.Dst -Linked $linked -Failed $failed
  }

  Write-Section 'Profile:'
  Set-ProfileEntry -ProfilePath $PROFILE_PATH -Line $PROFILE_LINE

  Write-Summary 'Symlinks' @{
    Installed = $linked
    Upgraded  = [System.Collections.Generic.List[string]]::new()
    Latest    = [System.Collections.Generic.List[string]]::new()
    Failed    = $failed
  }
  if ($failed.Count) { throw "Links failed: $($failed -join ', ')" }
}

Main
