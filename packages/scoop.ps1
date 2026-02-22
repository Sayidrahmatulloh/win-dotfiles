# ============================================================
#  packages/scoop.ps1
# ============================================================

$buckets = @("main", "extras", "nerd-fonts")

foreach ($bucket in $buckets) {
    scoop bucket add $bucket 2>$null
    Write-Host "  bucket: $bucket" -ForegroundColor Green
}

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

foreach ($tool in $tools) {
    if (-not (scoop list $tool 2>&1 | Select-String $tool)) {
        scoop install $tool
        Write-Host "  installed: $tool" -ForegroundColor Green
    } else {
        Write-Host "  skipped:   $tool (already installed)" -ForegroundColor Gray
    }
}
