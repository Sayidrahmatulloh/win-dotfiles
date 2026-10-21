param([string]$RepoRoot = (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent))
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
. "$PSScriptRoot/../support/powershell.ps1"
. "$RepoRoot\lib\utils.ps1"
Invoke-Expression (Read-Functions 'scripts/install/winget.ps1')
$WINGET_FLAGS = @('--silent')
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
Assert-That (Test-ToolInstalled git) 'Installed Scoop tool was missed.'
Assert-That (-not (Test-ToolInstalled missing)) 'Missing Scoop tool was reported installed.'
$script:exitCode = 1; $script:output = @("There aren't any apps installed.")
Assert-That (-not (Test-ToolInstalled git)) 'Empty Scoop inventory was treated as an error.'
$script:output = @('inventory offline')
Assert-FailsWith { Test-ToolInstalled git } 'inventory offline'
$script:exitCode = 2; $script:output = @('No bucket found.')
Assert-That (-not (Test-BucketAdded main)) 'Empty Scoop bucket list was treated as an error.'
$script:exitCode = -1978335212; $script:output = @('No installed package found.')
Assert-That (-not (Test-AppInstalled App.Missing)) 'Winget missing-package exit code was treated as an error.'
$script:exitCode = 2; $script:output = @('source unavailable')
$script:commands = @()
$result = Sync-Packages -Names @('App.Broken') -IsInstalled { param($name) Test-AppInstalled $name } -Install { param($name) Install-App $name } -Upgrade { throw 'Not requested' }
Assert-That ($result.Failed -contains 'App.Broken') 'Winget inventory error was not recorded.'
Assert-That (@($script:commands | Where-Object { $_ -like 'winget install*' }).Count -eq 0) 'Inventory error triggered installation.'
Assert-FailsWith { Install-Tool broken } 'source unavailable'
Assert-FailsWith { Install-App App.Broken } 'exit 2'
$script:exitCode = -1978335189
Assert-That ((Update-App App.Existing) -eq 'latest') 'Winget no-upgrade result was rejected.'
$script:exitCode = -1978335211; $script:output = @('No sources defined')
Assert-FailsWith { Update-App App.Existing } 'No sources defined'
Write-Host 'Inventory and command failure tests passed.'