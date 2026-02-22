# ============================================================
#  packages/winget.ps1 — Install and upgrade apps via Winget
# ============================================================

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\..\lib\utils.ps1"

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

# ── Helpers ────────────────────────────────────────────────────────────────────

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


# ── Core logic ─────────────────────────────────────────────────────────────────

function Sync-Apps {
    param([string[]]$Apps)

    Write-Section 'Apps:'

    $results = @{ Installed = @(); Failed = @() }
    $total   = $Apps.Count
    $index   = 0

    foreach ($app in $Apps) {
        $index++
        $prefix = '  [{0}/{1}]' -f $index, $total

        if (Test-AppInstalled $app) {
            Write-Step $prefix $app 'checking'
            Write-Skip $app
        } else {
            Write-Step $prefix $app 'installing'

            if (Install-App $app) {
                Write-Done "installed: $app"
                $results.Installed += $app
            } else {
                Write-Fail "install failed: $app"
                $results.Failed += $app
            }
        }
    }

    return $results
}

# ── Entry point ────────────────────────────────────────────────────────────────

function Main {
    $results = Sync-Apps $APPS
    Write-Summary 'Winget' $results
}

Main
