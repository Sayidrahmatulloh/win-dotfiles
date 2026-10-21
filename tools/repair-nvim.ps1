param([string]$RepoRoot = (Split-Path $PSScriptRoot -Parent))
$ErrorActionPreference = 'Stop'

if (Get-Process -Name tree-sitter -ErrorAction SilentlyContinue) {
    throw 'A Treesitter build is active. Wait for it to finish before running this repair.'
}

$lockRoot = Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'tree-sitter/lock'
if (Test-Path -LiteralPath $lockRoot) {
    foreach ($lock in Get-ChildItem -LiteralPath $lockRoot -File -Filter 'diff-*.lock') {
        if ($lock.Name -notmatch '^diff-[0-9a-f]+\.lock$') { continue }
        if ($lock.LastWriteTimeUtc -gt [DateTime]::UtcNow.AddHours(-1)) {
            throw "A recent parser lock was retained: $($lock.FullName)"
        }
        $stream = [IO.File]::Open($lock.FullName, 'Open', 'ReadWrite', 'None')
        $stream.Dispose()
        if (Get-Process -Name tree-sitter -ErrorAction SilentlyContinue) {
            throw 'A Treesitter build started; the lock was retained.'
        }
        $backup = $lock.FullName + '.stale-backup-' + (Get-Date -Format 'yyyyMMdd-HHmmss')
        Move-Item -LiteralPath $lock.FullName -Destination $backup
        Write-Host "Backed up stale parser lock: $($lock.Name)"
    }
}

Push-Location -LiteralPath $RepoRoot
try {
    & nvim --headless -u NONE -i NONE -n -l (Join-Path $PSScriptRoot 'repair-nvim-parsers.lua')
    if ($LASTEXITCODE -ne 0) { throw 'Treesitter parser repair failed.' }
    & nvim --headless -u NONE -i NONE -n -l (Join-Path $RepoRoot 'tests/neovim/shell.lua')
    if ($LASTEXITCODE -ne 0) { throw 'PowerShell terminal verification failed.' }
} finally {
    Pop-Location
}
