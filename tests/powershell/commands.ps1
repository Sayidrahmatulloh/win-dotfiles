param([string]$RepoRoot = (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent))
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
. "$PSScriptRoot/../support/powershell.ps1"
. "$RepoRoot\lib\utils.ps1"
. "$RepoRoot/lib/setup/winget.ps1"
$script:exitCode = 0
$script:output = @()
$script:commands = @()
function scoop { $script:commands += "scoop $($args -join ' ')"; $global:LASTEXITCODE = $script:exitCode; $script:output }
function winget { $script:commands += "winget $($args -join ' ')"; $global:LASTEXITCODE = $script:exitCode; $script:output }
function Assert-FailsWith {
    param([scriptblock]$Action, [string]$Message)
    $exception = $null
    try { & $Action | Out-Null } catch { $exception = $_.Exception.Message }
    Assert-That ($exception -and $exception.Contains($Message)) "Expected failure containing: $Message"
}
$script:output = @([pscustomobject]@{Name='git'})
Assert-That (Test-ScoopPackageInstalled git) 'Installed Scoop tool was missed.'
Assert-That (-not (Test-ScoopPackageInstalled missing)) 'Missing Scoop tool was reported installed.'
$script:exitCode = 1; $script:output = @("There aren't any apps installed.")
Assert-That (-not (Test-ScoopPackageInstalled git)) 'Empty Scoop inventory was treated as an error.'
$script:output = @('inventory offline')
Assert-FailsWith { Test-ScoopPackageInstalled git } 'inventory offline'
$script:exitCode = 2; $script:output = @('No bucket found.')
Assert-That (-not (Test-ScoopBucketAdded main)) 'Empty Scoop bucket list was treated as an error.'
$script:exitCode = -1978335212; $script:output = @('No installed package found.')
Assert-That (-not (Test-WingetPackageInstalled App.Missing)) 'Winget missing-package exit code was treated as an error.'
$script:exitCode = 2; $script:output = @('source unavailable')
$script:commands = @()
$result = Sync-Packages -Names @('App.Broken') -IsInstalled { param($name) Test-WingetPackageInstalled $name } -Install { param($name) Install-WingetPackage $name } -Upgrade { throw 'Not requested' }
Assert-That ($result.Failed -contains 'App.Broken') 'Winget inventory error was not recorded.'
Assert-That (@($script:commands | Where-Object { $_ -like 'winget install*' }).Count -eq 0) 'Inventory error triggered installation.'
Assert-FailsWith { Install-ScoopPackage broken } 'source unavailable'
Assert-FailsWith { Install-WingetPackage App.Broken } 'exit 2'
$script:exitCode = -1978335189
Assert-That ((Update-WingetPackage App.Existing).Status -eq 'Latest') 'Winget no-upgrade result was rejected.'
$script:exitCode = -1978335211; $script:output = @('No sources defined')
Assert-FailsWith { Update-WingetPackage App.Existing } 'No sources defined'
$script:exitCode = 0; $script:output = @()
$null = Install-WingetPackage App.New
Assert-That ($script:commands[-1] -match '--silent --accept-package-agreements --accept-source-agreements') 'Winget install omitted its shared agreement flags.'
$null = Update-WingetPackage App.Existing
Assert-That ($script:commands[-1] -match '--silent --accept-package-agreements --accept-source-agreements') 'Winget upgrade omitted its shared agreement flags.'
Write-Host 'Inventory and command failure tests passed.'
