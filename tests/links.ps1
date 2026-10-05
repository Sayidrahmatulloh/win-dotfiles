param([string]$RepoRoot = (Split-Path $PSScriptRoot -Parent))
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
. "$PSScriptRoot\helpers.ps1"
. "$RepoRoot\lib\utils.ps1"
Invoke-Expression (Read-Functions 'config/symlinks.ps1')
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
$result = New-Results
New-Symlink $source $destination $result.Installed $result.Failed
Assert-That ($result.Failed.Count -eq 1) 'Failed link was not reported.'
Assert-That ((Get-Content (Join-Path $destination 'keep.txt')).Trim() -eq 'original configuration') 'Original folder was not restored.'
Assert-That (@(Get-ChildItem $fixture -Filter 'config.bak_*').Count -eq 0) 'Rollback left original config under its backup name.'
$result = New-Results
New-Symlink $source $oldLink $result.Installed $result.Failed
Assert-That ($result.Failed.Count -eq 1) 'Failed replacement of an old junction was not reported.'
Assert-That (Test-ConfigLink $oldSource $oldLink) 'Old junction target was not restored.'
Assert-That (Test-Path $oldSource) 'Old junction target was deleted.'
Write-Host 'Folder and junction rollback tests passed.'