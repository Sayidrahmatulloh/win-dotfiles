param([string]$RepoRoot = (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent))
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
. "$PSScriptRoot/../support/powershell.ps1"
Invoke-Expression (Read-Functions 'install.ps1')
$ids = @('Scoop','Winget','Fonts','Cursors','Modules','Symlinks','Git','Terminal','Zebar')
Assert-That ((@(Select-SetupStages -RepoRoot $RepoRoot).Id -join ',') -eq ($ids -join ',')) 'Default selection changed.'
Assert-That ((@(Select-SetupStages -RepoRoot $RepoRoot -Only @('zebar','terminal','Terminal')).Id -join ',') -eq 'Terminal,Zebar') 'Case-insensitive selection, deduplication or ordering failed.'
Assert-That ((@(Select-SetupStages -RepoRoot $RepoRoot -Only ' Zebar , Terminal ').Id -join ',') -eq 'Terminal,Zebar') 'Comma-separated CLI argument failed.'
Assert-That (@(Select-SetupStages -RepoRoot $RepoRoot -Skip 'Winget,Fonts').Count -eq 7) 'Skip array parsing failed.'
foreach ($case in @(@{Only=@('Unknown')}, @{Only=@('')}, @{Only=@('Terminal,')}, @{Only=@('Terminal');Skip=@('Winget')}, @{Skip=$ids})) {
    $threw = $false
    try { Select-SetupStages -RepoRoot $RepoRoot @case | Out-Null } catch { $threw = $true }
    Assert-That $threw 'Invalid or empty stage selection was accepted.'
}
Write-Host 'Setup stage selection tests passed.'

# Each descriptor carries its explicit root, even when another plan is built later.
$firstRoot = Join-Path $RepoRoot 'fixture first repo'
$secondRoot = Join-Path $RepoRoot 'fixture second repo'
$firstPlan = @(Get-SetupStages -RepoRoot $firstRoot)
$secondPlan = @(Get-SetupStages -RepoRoot $secondRoot)
$receivedRoots = [Collections.Generic.List[string]]::new()
function Install-PSModules { param($RepoRoot) $receivedRoots.Add($RepoRoot) }
. "$RepoRoot/lib/setup/stages.ps1"
function Invoke-Step { param($Name, $Block) & $Block }
$moduleStages = @($firstPlan | Where-Object Id -eq 'Modules') + @($secondPlan | Where-Object Id -eq 'Modules')
Invoke-SetupStages -Stages $moduleStages -RefreshEnvironment {}
Assert-That (($receivedRoots -join '|') -eq "$firstRoot|$secondRoot") 'Stage actions used an ambient or later repository root.'

# Exercise Windows PowerShell -> pwsh -File forwarding without any installers.
$principal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $fixture = Join-Path ([IO.Path]::GetTempPath()) ('stage forwarding ' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $fixture | Out-Null
    @'
param([string]$DotfilesPath, [string[]]$Only = @(), [string[]]$Skip = @())
@{Only=$Only;Skip=$Skip;Root=$DotfilesPath} | ConvertTo-Json | Set-Content (Join-Path $DotfilesPath 'received.json')
'@ | Set-Content (Join-Path $fixture 'install.ps1')
    foreach ($parameter in @('Only','Skip')) {
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$RepoRoot/bootstrap.ps1" -DotfilesPath $fixture "-$parameter" 'Zebar,Terminal'
        Assert-That ($LASTEXITCODE -eq 0) "Bootstrap forwarding failed for $parameter."
        $received = Get-Content (Join-Path $fixture 'received.json') -Raw | ConvertFrom-Json
        Assert-That ($received.$parameter[0] -eq 'Zebar,Terminal' -and $received.Root -eq $fixture) 'Child arguments or path with spaces were changed.'
    }
    Write-Host 'Windows PowerShell 5.1 child argument forwarding passed.'
}
