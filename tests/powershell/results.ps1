param([string]$RepoRoot = (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent))
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
. "$PSScriptRoot/../support/powershell.ps1"
. "$RepoRoot/lib/utils.ps1"
$first = New-Results
$second = New-Results
Assert-That ($first.Failed.Count -eq 0 -and $first.Installed.Count -eq 0) 'Empty result views are not arrays.'
Add-InstallResult -Results $first -Entry (New-InstallResult -Name 'one' -Status Installed)
Add-InstallResult -Results $second -Entry (New-InstallResult -Name 'two' -Status Failed -Message 'link failed' -BackupPath 'fixture backup' -RollbackError 'restore failed')
$merged = Merge-Results $first $second
Assert-That ($merged.Entries.Count -eq 2 -and $merged.Installed[0] -eq 'one' -and $merged.Failed[0] -eq 'two') 'Merged views disagree with the stored records.'
$second.Entries[0].Status = 'Latest'
Assert-That ($merged.Failed.Count -eq 0 -and $merged.Latest[0] -eq 'two') 'Status views became stale after an entry changed.'
$second.Entries[0].Status = 'Failed'
function Write-Summary {}
function Write-Stage {}
function Write-Fail {}
$stage = Invoke-Step -Name 'fixture' -Block { Complete-InstallResults -Name 'fixture' -Results $merged }
Assert-That (-not $stage.Success -and $stage.Results.Entries[1].RollbackError -eq 'restore failed' -and $stage.Results.Entries[1].BackupPath -eq 'fixture backup') 'Stage reporting lost rollback diagnostics.'
Write-Host 'Derived result views, merging and stage error details passed.'
