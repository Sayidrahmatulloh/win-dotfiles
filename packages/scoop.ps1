# ============================================================
#  packages/scoop.ps1 — Install and upgrade packages via Scoop
# ============================================================

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ── Constants ─────────────────────────────────────────────────────────────────

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

# ── Output helpers ─────────────────────────────────────────────────────────────

function Write-Step {
    param([string]$Prefix, [string]$Name, [string]$Status)
    Write-Host $Prefix      -NoNewline -ForegroundColor DarkGray
    Write-Host " $Name"     -NoNewline -ForegroundColor White
    Write-Host "... $Status"            -ForegroundColor DarkGray
}

function Write-Result {
    param([string]$Icon, [string]$Label, [string]$Name, [ConsoleColor]$Color)
    Write-Host "  $Icon $Label" -NoNewline -ForegroundColor $Color
    Write-Host $Name             -ForegroundColor White
}

function Write-SectionHeader {
    param([string]$Title)
    Write-Host ""
    Write-Host "  $Title" -ForegroundColor White
}

# ── Scoop helpers ──────────────────────────────────────────────────────────────

function Get-InstalledBuckets {
    scoop bucket list 2>$null
}

function Get-InstalledTools {
    scoop list 2>$null
}

function Install-Bucket {
    param([string]$Bucket)
    scoop bucket add $Bucket 2>$null
    return $LASTEXITCODE -eq 0
}

function Install-Tool {
    param([string]$Tool)
    scoop install $Tool *>$null
    return $LASTEXITCODE -eq 0
}

function Update-Tool {
    param([string]$Tool)
    scoop update $Tool *>$null
    return $LASTEXITCODE -eq 0
}

# ── Core logic ─────────────────────────────────────────────────────────────────

function Sync-Buckets {
    param([string[]]$Buckets)

    Write-SectionHeader 'Buckets:'

    $installed = Get-InstalledBuckets
    $total     = $Buckets.Count
    $index     = 0

    foreach ($bucket in $Buckets) {
        $index++
        $prefix = '  [{0}/{1}]' -f $index, $total

        if ($installed -contains $bucket) {
            Write-Step $prefix $bucket 'already installed'
            Write-Result '[~]' 'skipped:  ' $bucket DarkGray
            continue
        }

        Write-Step $prefix $bucket 'adding'

        if (Install-Bucket $bucket) {
            Write-Result '[+]' 'added:    ' $bucket Green
        } else {
            Write-Result '[x]' 'failed:   ' $bucket Red
        }
    }
}

function Sync-Tools {
    param([string[]]$Tools)

    Write-SectionHeader 'Tools:'

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
                Write-Result '[^]' 'upgraded: ' $tool Cyan
                $results.Upgraded += $tool
            } else {
                Write-Result '[x]' 'failed:   ' $tool Red
                $results.Failed   += $tool
            }
        } else {
            Write-Step $prefix $tool 'installing'

            if (Install-Tool $tool) {
                Write-Result '[+]' 'installed:' $tool Green
                $results.Installed += $tool
            } else {
                Write-Result '[x]' 'failed:   ' $tool Red
                $results.Failed    += $tool
            }
        }
    }

    return $results
}

function Write-Summary {
    param([hashtable]$Results)

    $divider = '  ' + ('-' * 40)

    Write-Host ''
    Write-Host $divider                                                    -ForegroundColor DarkGray
    Write-Host '  Scoop summary:'                                          -ForegroundColor White
    Write-Host ('  [+] Installed : {0}' -f $Results.Installed.Count)     -ForegroundColor Green
    Write-Host ('  [^] Upgraded  : {0}' -f $Results.Upgraded.Count)      -ForegroundColor Cyan
    Write-Host ('  [x] Failed    : {0}' -f $Results.Failed.Count)        -ForegroundColor Red

    foreach ($f in $Results.Failed) {
        Write-Host "       - $f" -ForegroundColor DarkRed
    }

    Write-Host $divider -ForegroundColor DarkGray
}

# ── Entry point ────────────────────────────────────────────────────────────────

function Main {
    Sync-Buckets $BUCKETS
    $results = Sync-Tools $TOOLS
    Write-Summary $results
}

Main
