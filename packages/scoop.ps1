# ============================================================
#  packages/scoop.ps1 — Install and upgrade packages via Scoop
# ============================================================

param([switch]$Update)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\..\lib\utils.ps1"

# ── Package list ───────────────────────────────────────────────────────────────

$BUCKETS = @('main', 'extras', 'nerd-fonts')

$TOOLS = @(
  # Core
  'bun', 'cacert', 'curl', 'dark', 'fd', 'ffmpeg',
  'fzf', 'gcc', 'gh', '7zip', 'go', 'helix', 'innounp',
  'jq', 'llvm', 'lua', 'luajit', 'luarocks', 'make',
  'neovim', 'nodejs', 'oh-my-posh', 'python',
  'ripgrep', 'rust', 'stylua', 'tree-sitter',
  # Extras
  'autohotkey', 'keyviz', 'lazygit', 'posh-git', 'psfzf', 'terminal-icons'
)

# ── Guards ─────────────────────────────────────────────────────────────────────

function Assert-ScoopAvailable {
  if (-not (Get-Command 'scoop' -ErrorAction SilentlyContinue)) {
    Write-Fail 'scoop not found. Run install.ps1 first.'
    throw 'Required package manager is not available.'
  }
}

# ── Bucket helpers ─────────────────────────────────────────────────────────────

function Test-BucketAdded {
  param([string]$Name)
  $list = scoop bucket list 2>$null
  return [bool]($list | Where-Object { $_.Name -eq $Name })
}

function Add-Bucket {
  param([string]$Name)
  $out = scoop bucket add $Name 2>&1
  return ($LASTEXITCODE -eq 0) -and ($out -notmatch 'ERROR')
}

# ── Tool helpers ───────────────────────────────────────────────────────────────

function Test-ToolInstalled {
  param([string]$Name)
  $list = scoop list 2>$null
  return [bool]($list | Where-Object { $_.Name -eq $Name })
}

function Install-Tool {
  param([string]$Name)
  $null = scoop install $Name 2>&1
  return $LASTEXITCODE -eq 0
}

function Update-Tool {
  param([string]$Name)
  $out = scoop update $Name 2>&1
  if ($LASTEXITCODE -ne 0) { return 'failed' }
  if ($out -match 'Latest versions for all apps are installed' -or
    $out -match 'is already the newest version') { return 'latest' }
  return 'upgraded'
}

# ── Core logic ─────────────────────────────────────────────────────────────────

function Sync-Buckets {
  param([string[]]$Buckets)
  Write-Section 'Buckets:'

  $anyAdded = $false
  $failedBuckets = [Collections.Generic.List[string]]::new()
  $i = 0

  foreach ($bucket in $Buckets) {
    $i++
    $pfx = "  [$i/$($Buckets.Count)]"

    if (Test-BucketAdded $bucket) {
      Write-Skip "bucket: $bucket"
      continue
    }

    Write-Step $pfx $bucket 'adding'

    if (Add-Bucket $bucket) {
      Write-Done "bucket added: $bucket"
      $anyAdded = $true
    }
    else {
      Write-Fail "bucket failed: $bucket"
      $failedBuckets.Add($bucket)
    }
  }

  if ($anyAdded) {
    Write-Step '  ' 'scoop' 'updating index'
    $null = scoop update 2>&1
    if ($LASTEXITCODE -ne 0) { throw 'Scoop bucket index update failed.' }
    Write-Done 'index updated'
  }
  if ($failedBuckets.Count) { throw "Scoop buckets failed: $($failedBuckets -join ', ')" }
}

function Sync-Tools {
  param([string[]]$Tools)
  Write-Section 'Tools:'

  $r = New-Results
  $i = 0

  foreach ($tool in $Tools) {
    $i++
    $pfx = "  [$i/$($Tools.Count)]"

    if (Test-ToolInstalled $tool) {
      if (-not $Update) {
        Write-Skip "already installed: $tool"
        $r.Latest.Add($tool)
        continue
      }
      Write-Step $pfx $tool 'upgrading'
      switch (Update-Tool $tool) {
        'upgraded' { Write-Done "upgraded: $tool"; $r.Upgraded.Add($tool) }
        'latest' { Write-Skip "up to date: $tool"; $r.Latest.Add($tool) }
        'failed' { Write-Fail "upgrade failed: $tool"; $r.Failed.Add($tool) }
      }
    }
    else {
      Write-Step $pfx $tool 'installing'
      if (Install-Tool $tool) {
        Write-Done "installed: $tool"
        $r.Installed.Add($tool)
      }
      else {
        Write-Fail "install failed: $tool"
        $r.Failed.Add($tool)
      }
    }
  }

  return $r
}

# ── Entry point ────────────────────────────────────────────────────────────────

function Main {
  Assert-ScoopAvailable
  Sync-Buckets $BUCKETS
  $results = Sync-Tools $TOOLS
  Write-Summary 'Scoop' $results
  if ($results.Failed.Count) { throw "Scoop packages failed: $($results.Failed -join ', ')" }
}

Main
