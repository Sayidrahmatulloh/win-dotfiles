# ============================================================
#  packages/scoop.ps1
# ============================================================

# --- Buckets ---
$buckets = @("main", "extras", "nerd-fonts")

Write-Host ""
Write-Host "  Buckets:" -ForegroundColor White
foreach ($bucket in $buckets) {
    $exists = scoop bucket list 2>$null | Out-String | Select-String --SimpleMatch $bucket
    if ($exists) {
        Write-Host "  [~] already:  $bucket" -ForegroundColor DarkGray
    } else {
        scoop bucket add $bucket 2>$null
        Write-Host "  [+] added:    $bucket" -ForegroundColor Green
    }
}

# --- Tools ---
$tools = @(
    # Main
    "bun", "cacert", "curl", "dark", "fd", "ffmpeg",
    "fzf", "gcc", "gh", "7zip", "go", "helix", "innounp",
    "jq", "llvm", "lua", "luajit", "luarocks", "make",
    "neovim", "nodejs", "oh-my-posh", "python",
    "ripgrep", "rust", "stylua", "tree-sitter",
    # Extras
    "autohotkey", "keyviz", "lazygit", "posh-git", "psfzf", "terminal-icons"
)

$results = @{ installed = @(); upgraded = @(); failed = @() }
$total   = $tools.Count
$i       = 0

Write-Host ""
Write-Host "  Tools:" -ForegroundColor White

foreach ($tool in $tools) {
    $i++
    $prefix = "  [{0}/{1}]" -f $i, $total
    Write-Host "$prefix " -NoNewline -ForegroundColor DarkGray
    Write-Host $tool -NoNewline -ForegroundColor White
    Write-Host "..." -NoNewline -ForegroundColor DarkGray

    $isInstalled = scoop list $tool 2>&1 | Select-String --SimpleMatch $tool

    if ($isInstalled) {
        Write-Host " upgrading" -ForegroundColor DarkCyan
        scoop update $tool *>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  [^] upgraded: " -NoNewline -ForegroundColor Cyan
            Write-Host $tool -ForegroundColor White
            $results.upgraded += $tool
        } else {
            Write-Host "  [x] failed:   " -NoNewline -ForegroundColor Red
            Write-Host $tool -ForegroundColor White
            $results.failed += $tool
        }
    } else {
        Write-Host " installing" -ForegroundColor DarkGray
        scoop install $tool *>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  [+] installed: " -NoNewline -ForegroundColor Green
            Write-Host $tool -ForegroundColor White
            $results.installed += $tool
        } else {
            Write-Host "  [x] failed:    " -NoNewline -ForegroundColor Red
            Write-Host $tool -ForegroundColor White
            $results.failed += $tool
        }
    }
}

# Summary
Write-Host ""
Write-Host "  ----------------------------------------" -ForegroundColor DarkGray
Write-Host "  Scoop summary:" -ForegroundColor White
Write-Host ("  [+] Installed : {0}" -f $results.installed.Count) -ForegroundColor Green
Write-Host ("  [^] Upgraded  : {0}" -f $results.upgraded.Count)  -ForegroundColor Cyan
Write-Host ("  [x] Failed    : {0}" -f $results.failed.Count)    -ForegroundColor Red
if ($results.failed.Count -gt 0) {
    foreach ($f in $results.failed) {
        Write-Host "       - $f" -ForegroundColor DarkRed
    }
}
Write-Host "  ----------------------------------------" -ForegroundColor DarkGray
