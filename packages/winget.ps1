# ============================================================
#  packages/winget.ps1 — Install and upgrade apps via Winget
# ============================================================

param([switch]$Update)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\..\lib\utils.ps1"

# ── App list ───────────────────────────────────────────────────────────────────

$APPS = @(
  # Browsers
  'Zen-Team.Zen-Browser'
  'Google.Chrome.EXE'
  # Window management
  'glzr-io.glazewm'
  'RamenSoftware.Windhawk'
  # Development
  'Microsoft.VisualStudioCode'
  'Microsoft.VisualStudio.2022.BuildTools'
  'Microsoft.PowerShell'
  'Microsoft.WindowsTerminal'
  'Microsoft.WSL'
  # Utilities
  'HaiNguyen.Mechvibes'
  'Voidstar.FilePilot'
  'Microsoft.PowerToys'
  'Devolutions.UniGetUI'
)

$WINGET_FLAGS = @(
  '--silent'
  '--accept-package-agreements'
  '--accept-source-agreements'
)

# ── Guards ─────────────────────────────────────────────────────────────────────

function Assert-WingetAvailable {
  if (-not (Get-Command 'winget' -ErrorAction SilentlyContinue)) {
    Write-Fail 'winget not found. Install App Installer from the Microsoft Store.'
    throw 'Required package manager is not available.'
  }
}

# ── App helpers ────────────────────────────────────────────────────────────────

function Test-AppInstalled {
  param([string]$AppId)
  $out = winget list --id $AppId --exact --accept-source-agreements 2>&1
  # Check both exit code and that the AppId actually appears in output
  return ($LASTEXITCODE -eq 0) -and ($out -match [regex]::Escape($AppId))
}

function Install-App {
  param([string]$AppId)
  $null = winget install --id $AppId --exact @WINGET_FLAGS 2>&1
  return $LASTEXITCODE -eq 0
}

function Update-App {
  param([string]$AppId)
  $out = winget upgrade --id $AppId --exact @WINGET_FLAGS 2>&1
  # Exit code 0  = upgraded successfully
  # Exit code -1978335189 (0x8A150015) = no upgrade available — treat as latest
  if ($LASTEXITCODE -eq 0) { return 'upgraded' }
  if ($out -match 'No applicable upgrade found' -or
    $out -match 'No available upgrade found' -or
    $LASTEXITCODE -eq -1978335189) { return 'latest' }
  return 'failed'
}

# ── Core logic ─────────────────────────────────────────────────────────────────

function Sync-Apps {
  param([string[]]$Apps)
  Write-Section 'Apps:'

  $r = New-Results
  $i = 0

  foreach ($app in $Apps) {
    $i++
    $pfx = "  [$i/$($Apps.Count)]"

    if (Test-AppInstalled $app) {
      if (-not $Update) {
        Write-Skip "already installed: $app"
        $r.Latest.Add($app)
        continue
      }
      Write-Step $pfx $app 'upgrading'
      switch (Update-App $app) {
        'upgraded' { Write-Done "upgraded: $app"; $r.Upgraded.Add($app) }
        'latest' { Write-Skip "up to date: $app"; $r.Latest.Add($app) }
        'failed' { Write-Fail "upgrade failed: $app"; $r.Failed.Add($app) }
      }
    }
    else {
      Write-Step $pfx $app 'installing'
      if (Install-App $app) {
        Write-Done "installed: $app"
        $r.Installed.Add($app)
      }
      else {
        Write-Fail "install failed: $app"
        $r.Failed.Add($app)
      }
    }
  }

  return $r
}

# ── Entry point ────────────────────────────────────────────────────────────────

function Main {
  Assert-WingetAvailable
  $results = Sync-Apps $APPS
  Write-Summary 'Winget' $results
  if ($results.Failed.Count) { throw "Winget packages failed: $($results.Failed -join ', ')" }
}

Main
