param([string]$RepoRoot = (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent))
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
. "$PSScriptRoot/../support/powershell.ps1"
. "$RepoRoot\lib\utils.ps1"
. "$RepoRoot/lib/setup/links.ps1"
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('link-test-' + [guid]::NewGuid().ToString('N'))
$source = Join-Path $fixture 'source'
$oldSource = Join-Path $fixture 'old-source'
$destination = Join-Path $fixture 'config'
New-Item -ItemType Directory -Path $source,$oldSource,$destination -Force | Out-Null
Set-Content -LiteralPath (Join-Path $destination 'keep.txt') -Value 'original configuration'
$oldLink = Join-Path $fixture 'old-link'
New-Item -ItemType Junction -Path $oldLink -Target $oldSource | Out-Null
# Directory creation works, but both link creation methods fail.
function New-Item {
    param($ItemType,$Path,$Target,[switch]$Force,$ErrorAction)
    if ($ItemType -in @('SymbolicLink','Junction')) { throw 'simulated link creation failure' }
    Microsoft.PowerShell.Management\New-Item -ItemType $ItemType -Path $Path -Force:$Force
}
$result = New-Symlink -Src $source -Dst $destination
Assert-That ($result.Status -eq 'Failed' -and -not $result.RollbackError) 'Failed link or successful rollback was not reported.'
Assert-That ((Get-Content (Join-Path $destination 'keep.txt')).Trim() -eq 'original configuration') 'Original folder was not restored.'
Assert-That (@(Get-ChildItem $fixture -Filter 'config.bak_*').Count -eq 0) 'Rollback left original config under its backup name.'
$result = New-Symlink -Src $source -Dst $oldLink
Assert-That ($result.Status -eq 'Failed' -and -not $result.RollbackError) 'Failed replacement of an old junction was not reported.'
Assert-That (Test-ConfigLink $oldSource $oldLink) 'Old junction target was not restored.'
Assert-That (Test-Path $oldSource) 'Old junction target was deleted.'
Write-Host 'Folder and junction rollback tests passed.'

# A failed restoration retains the backup and both errors in the returned record.
function Move-Item {
    param($LiteralPath, $Destination, $ErrorAction)
    if ($LiteralPath -like '*.bak_*') { throw 'simulated rollback failure' }
    Microsoft.PowerShell.Management\Move-Item -LiteralPath $LiteralPath -Destination $Destination -ErrorAction Stop
}
$result = New-Symlink -Src $source -Dst $destination
Assert-That ($result.Status -eq 'Failed' -and $result.Message -like '*simulated link creation failure*') 'The primary link error was lost.'
Assert-That ($result.RollbackError -eq 'simulated rollback failure' -and (Test-Path -LiteralPath $result.BackupPath)) 'Rollback failure or recovery path was lost.'
Assert-That ((Get-Content -LiteralPath (Join-Path $result.BackupPath 'keep.txt')).Trim() -eq 'original configuration') 'Rollback failure damaged the backup.'
Remove-Item Function:\Move-Item

# Recovery must not delete a real folder that appeared at the destination.
New-Item -ItemType Directory -Path $destination -Force | Out-Null
Set-Content -LiteralPath (Join-Path $destination 'occupied.txt') -Value 'new data'
$threw = $false
try { Restore-ConfigLinkBackup -Destination $destination -BackupPath $result.BackupPath }
catch { $threw = $_.Exception.Message -like 'Destination contains a real folder*' }
Assert-That ($threw -and (Test-Path -LiteralPath $result.BackupPath) -and (Test-Path -LiteralPath (Join-Path $destination 'occupied.txt'))) 'Recovery overwrote an occupied directory or lost the backup.'
Write-Host 'Rollback diagnostics and occupied-directory protection passed.'
Remove-Item Function:\New-Item
$success = @(New-Symlink -Src $source -Dst $destination)
Assert-That ($success.Count -eq 1 -and $success[0].Status -eq 'Installed' -and (Test-ConfigLink $source $destination)) 'Successful linking emitted extra output or did not create the expected link.'
Assert-That (Test-Path -LiteralPath (Join-Path $success[0].BackupPath 'occupied.txt')) 'Successful linking lost the previous configuration.'
$repeat = New-Symlink -Src $source -Dst $destination
Assert-That ($repeat.Status -eq 'Latest' -and -not $repeat.BackupPath) 'A repeated link operation did not skip the existing link.'
