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
    "MartiCliment.UniGetUI"
)

$results = @{ installed = @(); upgraded = @(); failed = @() }
$total   = $apps.Count
$i       = 0

foreach ($app in $apps) {
    $i++
    $prefix = "  [{0}/{1}]" -f $i, $total
    Write-Host "$prefix " -NoNewline -ForegroundColor DarkGray
    Write-Host $app -NoNewline -ForegroundColor White
    Write-Host "..." -NoNewline -ForegroundColor DarkGray

    $isInstalled = winget list --id $app --exact --accept-source-agreements 2>$null |
                   Select-String --SimpleMatch $app

    if ($isInstalled) {
        Write-Host " upgrading" -ForegroundColor DarkCyan
        winget upgrade --id $app --silent --accept-package-agreements --accept-source-agreements *>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  [^] upgraded: " -NoNewline -ForegroundColor Cyan
            Write-Host $app -ForegroundColor White
            $results.upgraded += $app
        } else {
            Write-Host "  [x] failed:   " -NoNewline -ForegroundColor Red
            Write-Host $app -ForegroundColor White
            $results.failed += $app
        }
    } else {
        Write-Host " installing" -ForegroundColor DarkGray
        winget install --id $app --silent --accept-package-agreements --accept-source-agreements *>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  [+] installed: " -NoNewline -ForegroundColor Green
            Write-Host $app -ForegroundColor White
            $results.installed += $app
        } else {
            Write-Host "  [x] failed:    " -NoNewline -ForegroundColor Red
            Write-Host $app -ForegroundColor White
            $results.failed += $app
        }
    }
}

# Summary
Write-Host ""
Write-Host "  ----------------------------------------" -ForegroundColor DarkGray
Write-Host "  Winget summary:" -ForegroundColor White
Write-Host ("  [+] Installed : {0}" -f $results.installed.Count) -ForegroundColor Green
Write-Host ("  [^] Upgraded  : {0}" -f $results.upgraded.Count)  -ForegroundColor Cyan
Write-Host ("  [x] Failed    : {0}" -f $results.failed.Count)    -ForegroundColor Red
if ($results.failed.Count -gt 0) {
    foreach ($f in $results.failed) {
        Write-Host "       - $f" -ForegroundColor DarkRed
    }
}
Write-Host "  ----------------------------------------" -ForegroundColor DarkGray
