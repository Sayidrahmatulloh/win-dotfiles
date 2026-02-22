# ============================================================
#  packages/winget.ps1
# ============================================================

$apps = @(
    "Zen-Team.Zen-Browser",
    "Google.Chrome.EXE",
    "glzr-io.glazewm",
    "Microsoft.VisualStudioCode",
    "Microsoft.VisualStudio.2022.BuildTools",
    "Microsoft.PowerShell",
    "Microsoft.WindowsTerminal",
    "Microsoft.WSL",
    "HaiNguyen.Mechvibes",
    "RamenSoftware.Windhawk",
    "Voidstar.FilePilot",
    "Microsoft.PowerToys",
    "MartiCliment.UniGetUI",
)


foreach ($app in $apps) {
    Write-Host "  Installing $app..." -ForegroundColor Gray
    winget install --id $app --silent --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  done: $app" -ForegroundColor Green
    } else {
        Write-Host "  failed: $app" -ForegroundColor Red
    }
}

