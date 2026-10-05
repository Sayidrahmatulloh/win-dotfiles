# Run every test in its own PowerShell process so mocks cannot leak between suites.
[CmdletBinding()]
param([string]$RepoRoot = (Split-Path $PSScriptRoot -Parent))
$ErrorActionPreference = 'Stop'
if ($PSVersionTable.PSVersion.Major -lt 7) { throw 'Run tests from PowerShell 7.' }
$powerShell = (Get-Process -Id $PID).Path
$failures = @()
$tests = Get-ChildItem -LiteralPath $PSScriptRoot -Filter '*.ps1' -File |
    Where-Object Name -notin @('run.ps1', 'helpers.ps1') | Sort-Object Name
foreach ($test in $tests) {
    Write-Host "`nTest: $($test.BaseName)"
    & $powerShell -NoProfile -File $test.FullName -RepoRoot $RepoRoot
    if ($LASTEXITCODE -ne 0) { $failures += $test.Name }
}
if ($failures.Count) { Write-Host "Failed: $($failures -join ', ')"; exit 1 }
Write-Host "`nAll $($tests.Count) test suites passed."
exit 0
