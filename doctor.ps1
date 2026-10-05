# Read-only diagnostics entry point. Check implementations are in lib/diagnostics.ps1.
[CmdletBinding()]
param(
    [string]$DotfilesPath = $PSScriptRoot,
    [switch]$Json
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\lib\settings.ps1"
. "$PSScriptRoot\lib\files.ps1"
. "$PSScriptRoot\lib\diagnostics.ps1"

try {
    $repoRoot = [IO.Path]::GetFullPath($DotfilesPath)
    $configuration = $null
    try { $configuration = Get-SetupConfig -RepoRoot $repoRoot }
    catch {
        $results = @(
            New-DoctorResult 'Setup configuration' FAIL $_.Exception.Message 'Fix setup.json in the selected checkout.'
            New-DoctorResult 'Scope' WARN 'Other checks skipped until the selected setup.json is valid.'
        )
    }
    if ($configuration) { $results = @(Get-DoctorResults -RepoRoot $repoRoot -Configuration $configuration) }
    if ($Json) { ConvertTo-Json -InputObject $results -Depth 5 }
    else {
        Write-Host 'win-dotfiles doctor (read-only)'
        foreach ($result in $results) {
            $color = switch ($result.Status) { OK { 'Green' }; WARN { 'Yellow' }; FAIL { 'Red' } }
            Write-Host "[$($result.Status)] $($result.Name): $($result.Detail)" -ForegroundColor $color
            if ($result.Fix) { Write-Host "       Fix: $($result.Fix)" }
        }
        $failures = @($results | Where-Object Status -eq FAIL).Count
        $warnings = @($results | Where-Object Status -eq WARN).Count
        Write-Host "`n$failures failure(s), $warnings warning(s)."
    }
    if (@($results | Where-Object Status -eq FAIL).Count) { exit 1 }
    exit 0
} catch { Write-Error $_ -ErrorAction Continue; exit 1 }
