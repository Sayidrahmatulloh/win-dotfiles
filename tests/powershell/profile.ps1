param([string]$RepoRoot = (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent))
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
. "$PSScriptRoot/../support/powershell.ps1"
# Exercise profile startup with missing optional dependencies, in this test's child process.
function Import-Module { param($Name,$ErrorAction) throw "simulated missing module: $Name" }
function Get-Command {
    param($Name,$ErrorAction)
    if ($Name -in @('oh-my-posh','Set-PsFzfOption')) { return $null }
    Microsoft.PowerShell.Core\Get-Command $Name -ErrorAction SilentlyContinue
}
function Set-PSReadLineOption { param($EditMode,$BellStyle,$ViModeIndicator,$PredictionSource,$ErrorAction) }
function Set-PSReadLineKeyHandler { param($Chord,$Function) }
. "$RepoRoot\config\powershell\user_profile.ps1"
function ssh { $script:sshArguments = @($args) }
Connect-Bandit 3
Assert-That ($script:sshArguments[0] -eq 'bandit3@bandit.labs.overthewire.org') 'Bandit host argument was wrong.'
$script:scoopCalls = @()
function scoop { $script:scoopCalls += ($args -join ' '); $global:LASTEXITCODE = 1 }
$null = @(Update-Scoop 2>&1)
Assert-That ($script:scoopCalls.Count -eq 1 -and $script:scoopCalls[0] -eq 'update *') 'Failed update still ran cleanup.'
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('profile-test-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $fixture | Out-Null
$cpp = Join-Path $fixture 'source.cpp'
$zig = Join-Path $fixture 'source.zig'
Set-Content $cpp 'fixture source'
Set-Content $zig 'fixture source'
$existingExe = Join-Path $fixture 'source.exe'
Set-Content $existingExe 'existing output'
function g++ {
    $script:compilerArguments = @($args)
    $script:buildTarget = $args[2]
    $global:LASTEXITCODE = 1
    'simulated compiler failure'
}
$threw = $false
try { Invoke-Cpp $cpp } catch { $threw = $true }
Assert-That $threw 'C++ compile failure was not reported.'
Assert-That ($script:buildTarget -ne $existingExe) 'C++ compile target overwrote an existing output.'
Assert-That (-not (Test-Path (Split-Path $script:buildTarget -Parent))) 'Failed C++ build left its private directory.'
function zig {
    $script:compilerArguments = @($args)
    $script:buildTarget = $args[2].Substring('-femit-bin='.Length)
    $global:LASTEXITCODE = 1
    'simulated compiler failure'
}
$threw = $false
try { Invoke-Zig $zig } catch { $threw = $true }
Assert-That $threw 'Zig compile failure was not reported.'
Assert-That (-not (Test-Path (Split-Path $script:buildTarget -Parent))) 'Failed Zig build left its private directory.'
Assert-That ((Get-Content $existingExe).Trim() -eq 'existing output') 'Compiler helper changed or deleted a source-adjacent file.'
Write-Host 'Missing dependencies and profile helper tests passed.'