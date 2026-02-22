# ============================================================
#  packages/winget.ps1 — Install and upgrade apps via Winget
# ============================================================

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ── Constants ──────────────────────────────────────────────────────────────────

$APPS = @(
    # Browsers
    'Zen-Team.Zen-Browser',
    'Google.Chrome.EXE',
    # Window management
    'glzr-io.glazewm',
    'RamenSoftware.Windhawk',
    # Development
    'Microsoft.VisualStudioCode',
    'Microsoft.VisualStudio.2022.BuildTools',
    'Microsoft.PowerShell',
    'Microsoft.WindowsTerminal',
    'Microsoft.WSL',
    # Utilities
    'HaiNguyen.Mechvibes',
    'Voidstar.FilePilot',
    'Microsoft.PowerToys',
    'MartiCliment.UniGetUI'
)

$WINGET_FLAGS = '--silent --accept-package-agreements --accept-source-agreements'

# ── Output helpers ─────────────────────────────────────────────────────────────

function Write-Step {
    param([string]$Prefix, [string]$Name, [string]$Status)
    Write-Host $Prefix       -NoNewline -ForegroundColor DarkGray
    Write-Host " $Name"      -NoNewline -ForegroundColor White
    Write-Host "... $Status"             -ForegroundColor DarkGray
}

function Write-Result {
    param([string]$Icon, [string]$Label, [string]$Name, [ConsoleColor]$Color)
    Write-Host "  $Icon $Label" -NoNewline -ForegroundColor $Color
    Write-Host $Name             -ForegroundColor White
}

function Write-SectionHeader {
    param([string]$Title)
    Write-Host ''
    Write-Host "  $Title" -ForegroundColor White
}

# ── Winget helpers ─────────────────────────────────────────────────────────────

function Test-AppInstalled {
    param([string]$AppId)
    winget list --id $AppId --exact --accept-source-agreements *>$null
    return $LASTEXITCODE -eq 0
}

function Install-App {
    param([string]$AppId)
    Invoke-Expression "winget install --id $AppId $WINGET_FLAGS *>`$null"
    return $LASTEXITCODE -eq 0
}

function Update-App {
    param([string]$AppId)
    Invoke-Expression "winget upgrade --id $AppId $WINGET_FLAGS *>`$null"
    return $LASTEXITCODE -eq 0
}

# ── Core logic ─────────────────────────────────────────────────────────────────

function Sync-Apps {
    param([string[]]$Apps)

    Write-SectionHeader 'Apps:'

    $results = @{ Installed = @(); Upgraded = @(); Failed = @() }
    $total   = $Apps.Count
    $index   = 0

    foreach ($app in $Apps) {
        $index++
        $prefix = '  [{0}/{1}]' -f $index, $total

        if (Test-AppInstalled $app) {
            Write-Step $prefix $app 'upgrading'

            if (Update-App $app) {
                Write-Result '[^]' 'upgraded: ' $app Cyan
                $results.Upgraded += $app
            } else {
                Write-Result '[x]' 'failed:   ' $app Red
                $results.Failed   += $app
            }
        } else {
            Write-Step $prefix $app 'installing'

            if (Install-App $app) {
                Write-Result '[+]' 'installed:' $app Green
                $results.Installed += $app
            } else {
                Write-Result '[x]' 'failed:   ' $app Red
                $results.Failed    += $app
            }
        }
    }

    return $results
}

function Write-Summary {
    param([hashtable]$Results)

    $divider = '  ' + ('-' * 40)

    Write-Host ''
    Write-Host $divider                                                  -ForegroundColor DarkGray
    Write-Host '  Winget summary:'                                       -ForegroundColor White
    Write-Host ('  [+] Installed : {0}' -f $Results.Installed.Count)   -ForegroundColor Green
    Write-Host ('  [^] Upgraded  : {0}' -f $Results.Upgraded.Count)    -ForegroundColor Cyan
    Write-Host ('  [x] Failed    : {0}' -f $Results.Failed.Count)      -ForegroundColor Red

    foreach ($f in $Results.Failed) {
        Write-Host "       - $f" -ForegroundColor DarkRed
    }

    Write-Host $divider -ForegroundColor DarkGray
}

# ── Entry point ────────────────────────────────────────────────────────────────

function Main {
    $results = Sync-Apps $APPS
    Write-Summary $results
}

Main
