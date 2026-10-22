param([string]$RepoRoot = (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent))
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
. "$PSScriptRoot/../support/powershell.ps1"
. "$RepoRoot/lib/utils.ps1"
. "$RepoRoot/lib/setup/modules.ps1"
$moduleInventory = [Collections.Generic.HashSet[string]]::new()
$attempted = [Collections.Generic.List[string]]::new()
$null = $moduleInventory.Add('existing')
function Get-PowerShellModules { param($RepoRoot) @('existing', 'broken', 'missing-after-install', 'next') }
function Get-Module {
    param($Name, [switch]$ListAvailable, $ErrorAction)
    if ($moduleInventory.Contains($Name)) { [pscustomobject]@{ Name = $Name } }
}
function Install-Module {
    param($Name, $Repository, $Scope, [switch]$Force, $ErrorAction)
    Assert-That ($Repository -eq 'FixtureRepository' -and $Scope -eq 'CurrentUser') 'Module installation ignored its repository or user scope.'
    $attempted.Add($Name)
    if ($Name -eq 'broken') { throw 'repository unavailable' }
    if ($Name -ne 'missing-after-install') { $null = $moduleInventory.Add($Name) }
}
function Write-InstallResult {}
function Write-Summary {}
$failure = $null
try { Install-PSModules -RepoRoot $RepoRoot -Repository FixtureRepository }
catch { $failure = $_.Exception }
Assert-That ($null -ne $failure) 'Module failures were swallowed.'
$results = $failure.Data['InstallResults']
Assert-That (($attempted -join ',') -eq 'broken,missing-after-install,next') 'An existing module was reinstalled or a failure stopped later installs.'
Assert-That ($results.Latest -contains 'existing' -and $results.Installed -contains 'next' -and $results.Failed.Count -eq 2) 'Module results lost their statuses.'
Assert-That (($results.Entries | Where-Object Name -eq 'broken').Message -eq 'repository unavailable') 'Module error details were lost.'
Assert-That (($results.Entries | Where-Object Name -eq 'missing-after-install').Message -eq 'Module not found after installation.') 'Installation verification failure was hidden.'
Write-Host 'Module reuse, repository selection, failure details and continuation passed.'
