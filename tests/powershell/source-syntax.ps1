param([string]$RepoRoot = (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent))
$ErrorActionPreference = 'Stop'
$files = @(Get-ChildItem -LiteralPath $RepoRoot -File -Filter '*.ps1')
foreach ($directory in @('lib', 'scripts', 'tools', 'apps', 'config/powershell', 'tests')) {
    $files += @(Get-ChildItem -LiteralPath (Join-Path $RepoRoot $directory) -Recurse -File -Filter '*.ps1')
}
$files += Get-Item -LiteralPath (Join-Path $RepoRoot 'config/symlinks.ps1')
foreach ($file in $files) {
    $tokens = $null
    $parseErrors = $null
    $null = [Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$tokens, [ref]$parseErrors)
    if ($parseErrors.Count) { throw "$($file.FullName): $($parseErrors -join '; ')" }
}
Write-Host "All $($files.Count) authored PowerShell sources parse successfully."
