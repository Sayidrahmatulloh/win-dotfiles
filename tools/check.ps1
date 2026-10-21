[CmdletBinding()]
param([string]$RepoRoot = (Split-Path $PSScriptRoot -Parent), [switch]$Neovim, [switch]$Variants)
$ErrorActionPreference = 'Stop'
. "$RepoRoot/lib/setup/settings.ps1"

function Invoke-Check {
    param([string]$Name, [scriptblock]$Command)
    Write-Host "`nCheck: $Name"
    $global:LASTEXITCODE = 0
    & $Command
    if ($LASTEXITCODE -ne 0) { throw "$Name failed (exit $LASTEXITCODE)." }
}

Push-Location -LiteralPath $RepoRoot
try {
    Invoke-Check 'PowerShell' { & "$RepoRoot/tests/run.ps1" -RepoRoot $RepoRoot }
    $widget = Join-Path $RepoRoot (Get-SetupConfig -RepoRoot $RepoRoot).zebar.widget
    Invoke-Check 'Widget tests' { & bun test --cwd $widget }
    Invoke-Check 'TypeScript' { & bun run --cwd $widget typecheck }
    Invoke-Check 'Production build' { & bun run --cwd $widget build }
    Invoke-Check 'Desktop assets' { & "$RepoRoot/tools/check-desktop-build.ps1" -RepoRoot $RepoRoot }
    if ($Variants) {
        $variant = Join-Path $RepoRoot 'widgets/zebar/attaquer-buildless'
        Invoke-Check 'Buildless dependencies' { & bun install --cwd $variant --frozen-lockfile }
        Invoke-Check 'Buildless font' { & "$RepoRoot/tools/prepare-ci-font.ps1" -FontDirectory (Join-Path $variant 'fonts') }
        Invoke-Check 'Buildless build' { & bun run --cwd $variant build }
    }
    if ($Neovim) { Invoke-Check 'Neovim' { & "$RepoRoot/tools/check-nvim.ps1" -RepoRoot $RepoRoot -Integration } }
    Write-Host "`nAll selected checks passed."
} finally { Pop-Location }
