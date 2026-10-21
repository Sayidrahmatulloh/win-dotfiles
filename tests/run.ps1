# Run every test in its own PowerShell process so mocks cannot leak between suites.
[CmdletBinding()]
param([string]$RepoRoot = (Split-Path $PSScriptRoot -Parent))
$ErrorActionPreference = 'Stop'
if ($PSVersionTable.PSVersion.Major -lt 7) { throw 'Run tests from PowerShell 7.' }
$powerShell = [Diagnostics.Process]::GetCurrentProcess().MainModule.FileName
$failures = @()
$suiteDirectory = Join-Path $PSScriptRoot 'powershell'
$tests = @(Get-ChildItem -LiteralPath $suiteDirectory -Filter '*.ps1' -File | Sort-Object Name)
if (-not $tests.Count) { throw "No PowerShell test suites found in $suiteDirectory." }
foreach ($test in $tests) {
    Write-Host "`nTest: $($test.BaseName)"
    & $powerShell -NoProfile -File $test.FullName -RepoRoot $RepoRoot
    if ($LASTEXITCODE -ne 0) { $failures += $test.Name }
}
if ($failures.Count) { Write-Host "Failed: $($failures -join ', ')"; exit 1 }
Write-Host "`nAll $($tests.Count) test suites passed."
exit 0
