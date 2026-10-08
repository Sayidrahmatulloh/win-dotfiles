param([string]$RepoRoot = (Split-Path $PSScriptRoot -Parent))
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
. "$PSScriptRoot\helpers.ps1"
Invoke-Expression (Read-Functions 'config/powershell/user_profile.ps1')
# All destructive commands are mocked. Exercise reporting with locked temp files.
function Remove-Item {
    [CmdletBinding()]
    param($Path, [switch]$Recurse, [switch]$Force)
    if ($script:failCleanup) { Write-Error 'Fixture file is locked.' }
}
function Clear-RecycleBin {
    [CmdletBinding()]
    param([switch]$Force)
    if ($script:failCleanup) { throw 'Fixture recycle bin is unavailable.' }
}
function Start-Process { param($FilePath, $ArgumentList, [switch]$Wait, [switch]$NoNewWindow) }
$script:failCleanup = $true
$output = (Clear-System 6>&1 | Out-String)
Assert-That ($output -match 'partial \(1 errors; some files could not be removed\)') 'Locked files were reported as successful cleanup.'
Assert-That ($output -match 'Recycle Bin\.\.\.\s+failed') 'Recycle bin failure was reported as success.'
$script:failCleanup = $false
$output = (Clear-System 6>&1 | Out-String)
Assert-That ($output -match 'Temp files\.\.\.\s+done') 'Successful temp cleanup was not reported.'
Assert-That ($output -match 'Recycle Bin\.\.\.\s+done') 'Successful recycle bin cleanup was not reported.'
Write-Host 'Cleanup result reporting tests passed.'
