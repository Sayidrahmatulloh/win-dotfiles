# ============================================================
#  packages/scoop.ps1 — Install and upgrade packages via Scoop
# ============================================================

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\..\lib\utils.ps1"

# ── Constants ──────────────────────────────────────────────────────────────────

$BUCKETS = @('main', 'extras', 'nerd-fonts')

$TOOLS = @(
    # Core utilities
    'bun', 'cacert', 'curl', 'dark', 'fd', 'ffmpeg',
    'fzf', 'gcc', 'gh', '7zip', 'go', 'helix', 'innounp',
    'jq', 'llvm', 'lua', 'luajit', 'luarocks', 'make',
    'neovim', 'nodejs', 'oh-my-posh', 'python',
    'ripgrep', 'rust', 'stylua', 'tree-sitter',
    # Extras
    'autohotkey', 'keyviz', 'lazygit', 'posh-git', 'psfzf', 'terminal-icons'
)

# ── Scoop helpers ──────────────────────────────────────────────────────────────

function Get-InstalledBuckets { scoop bucket list 2>$null }
function Get-InstalledTools   { scoop list 2>$null }

function Add-Bucket  { param([string]$Name) scoop bucket add $Name 2>$null; return $LASTEXITCODE -eq 0 }
function Install-Tool { param([string]$Name) scoop install $Name *>$null;   return $LASTEXITCODE -eq 0 }
function Update-Tool  { param([string]$Name) scoop update $Name *>$null;    return $LASTEXITCODE -eq 0 }

# ── Core logic ─────────────────────────────────────────────────────────────────

function Sync-Buckets {
    param([string[]]$Buckets)

    Write-Section 'Buckets:'

    $installed = Get-InstalledBuckets
    $total     = $Buckets.Count
    $index     = 0

    foreach ($bucket in $Buckets) {
        $index++
        $prefix = '  [{0}/{1}]' -f $index, $total

        if ($installed -contains $bucket) {
            Write-Step $prefix $bucket 'already added'
            Write-Skip "bucket: $bucket"
            continue
        }

        Write-Step $prefix $bucket 'adding'

        if (Add-Bucket $bucket) {
            Write-Done "bucket: $bucket"
        } else {
            Write-Fail "bucket: $bucket"
        }
    }
}

function Sync-Tools {
    param([string[]]$Tools)

    Write-Section 'Tools:'

    $installed = Get-InstalledTools
    $results   = @{ Installed = @(); Upgraded = @(); Failed = @() }
    $total     = $Tools.Count
    $index     = 0

    foreach ($tool in $Tools) {
        $index++
        $prefix = '  [{0}/{1}]' -f $index, $total

        if ($installed -contains $tool) {
            Write-Step $prefix $tool 'upgrading'

            if (Update-Tool $tool) {
                Write-Host "  [^] upgraded:  $tool" -ForegroundColor Cyan
                $results.Upgraded += $tool
            } else {
                Write-Fail "upgrade failed: $tool"
                $results.Failed += $tool
            }
        } else {
            Write-Step $prefix $tool 'installing'

            if (Install-Tool $tool) {
                Write-Done "installed: $tool"
                $results.Installed += $tool
            } else {
                Write-Fail "install failed: $tool"
                $results.Failed += $tool
            }
        }
    }

    return $results
}

# ── Entry point ────────────────────────────────────────────────────────────────

function Main {
    Sync-Buckets $BUCKETS
    $results = Sync-Tools $TOOLS
    Write-Summary 'Scoop' $results
}

Main
