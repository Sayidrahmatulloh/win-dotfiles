[CmdletBinding()]
param([string]$RepoRoot = (Split-Path $PSScriptRoot -Parent), [switch]$Integration)
$ErrorActionPreference = 'Stop'
if (-not (Get-Command nvim -ErrorAction SilentlyContinue)) { throw 'Neovim is required for these checks.' }
$previousScript = $env:NVIM_TEST_SCRIPT
Push-Location -LiteralPath $RepoRoot
try {
    foreach ($name in @('architecture', 'terminal', 'parsers', 'keymaps')) {
        & nvim --headless -u NONE -i NONE -n -l (Join-Path $RepoRoot "tests/neovim/$name.lua")
        if ($LASTEXITCODE -ne 0) { throw "Neovim check failed: $name" }
    }
    foreach ($profile in @('standalone', 'vscode')) {
        & nvim --headless -u NONE -i NONE -n -l (Join-Path $RepoRoot 'tests/neovim/structure.lua') $profile
        if ($LASTEXITCODE -ne 0) { throw "Neovim structure check failed: $profile" }
    }
    if (-not $Integration) { return }
    foreach ($name in @('ignore', 'shell', 'ui', 'http', 'format', 'keymaps')) {
        $env:NVIM_TEST_SCRIPT = Join-Path $RepoRoot "tests/neovim/$name.lua"
        if ($name -in @('ignore', 'shell')) {
            & nvim --headless -u NONE -i NONE -n -l $env:NVIM_TEST_SCRIPT
        } else {
            & nvim --headless -u (Join-Path $RepoRoot 'config/nvim/init.lua') -i NONE -n -c 'lua dofile(vim.env.NVIM_TEST_SCRIPT)' -c qa
        }
        if ($LASTEXITCODE -ne 0) { throw "Neovim integration check failed: $name" }
    }
} finally {
    $env:NVIM_TEST_SCRIPT = $previousScript
    Pop-Location
}
