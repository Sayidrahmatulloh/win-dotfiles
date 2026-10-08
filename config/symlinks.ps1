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
$PROFILE_LINE = Get-PowerShellProfileLine
$SYMLINKS = @(Get-ConfigLinks -RepoRoot $DOTFILES -Configuration (Get-SetupConfig -RepoRoot $DOTFILES))

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

function New-Symlink {
    param(
        [string]$Src,
        [string]$Dst,
        [System.Collections.Generic.List[string]]$Linked,
        [System.Collections.Generic.List[string]]$Failed
    )
    $backup = $null
    try {
        if (-not (Test-Path -LiteralPath $Src -PathType Container)) { throw "Source folder is missing: $Src" }
        if (Test-ConfigLink -Source $Src -Destination $Dst) { Write-Skip "already linked: $Dst"; return }
        New-Item -ItemType Directory -Path (Split-Path $Dst -Parent) -Force | Out-Null
        $existing = Get-Item -LiteralPath $Dst -Force -ErrorAction SilentlyContinue
        if ($existing) {
            # Moving a directory entry preserves both real folders and old link targets.
            $backup = $Dst + '.bak_' + [guid]::NewGuid().ToString('N')
            Move-Item -LiteralPath $Dst -Destination $backup -ErrorAction Stop
            Write-Warn "backed up: $Dst -> $backup"
        }
        try { New-Item -ItemType SymbolicLink -Path $Dst -Target $Src -ErrorAction Stop | Out-Null }
        catch {
            $partial = Get-Item -LiteralPath $Dst -Force -ErrorAction SilentlyContinue
            if ($partial) {
                if ($partial.LinkType -notin @('Junction','SymbolicLink')) { throw 'Unexpected real folder appeared at the destination.' }
                Remove-Item -LiteralPath $Dst -Force -ErrorAction Stop
            }
            New-Item -ItemType Junction -Path $Dst -Target $Src -ErrorAction Stop | Out-Null
        }
        if (-not (Test-ConfigLink -Source $Src -Destination $Dst)) { throw 'New link target could not be verified.' }
        Write-Done "linked: $Dst"
        $Linked.Add($Dst)
    } catch {
        Write-Fail "link failed: $Dst : $($_.Exception.Message)"
        $Failed.Add($Dst)
        if ($backup -and (Get-Item -LiteralPath $backup -Force -ErrorAction SilentlyContinue)) {
            try {
                $partial = Get-Item -LiteralPath $Dst -Force -ErrorAction SilentlyContinue
                if ($partial) {
                    if ($partial.LinkType -notin @('Junction','SymbolicLink')) { throw "Destination contains a real folder; backup kept at $backup" }
                    Remove-Item -LiteralPath $Dst -Force -ErrorAction Stop
                }
                Move-Item -LiteralPath $backup -Destination $Dst -ErrorAction Stop
                Write-Warn "restored original configuration: $Dst"
            } catch { Write-Fail "Rollback failed; recover from $backup : $($_.Exception.Message)" }
        }
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

  $separator = if ($content -and -not $content.EndsWith("`n")) { [Environment]::NewLine } else { '' }
  Add-Content -LiteralPath $ProfilePath -Value ($separator + $Line)
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
