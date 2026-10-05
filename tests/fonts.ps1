param([string]$RepoRoot = (Split-Path $PSScriptRoot -Parent))
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
. "$PSScriptRoot\helpers.ps1"
. "$RepoRoot\lib\utils.ps1"
Invoke-Expression (Read-Functions 'fonts/fonts.ps1')
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('font-repair-test-' + [guid]::NewGuid().ToString('N'))
$SYSTEM_FONTS = Join-Path $fixture 'installed'
New-Item -ItemType Directory -Path $fixture | Out-Null
$font = Join-Path $fixture 'fixture.ttf'
Set-Content -LiteralPath $font -Value 'font bytes'
$script:registered = $null
$script:registrationFails = $true
$script:registrationCalls = 0
function Get-ItemPropertyValue { param($LiteralPath,$Name,$ErrorAction) return $script:registered }
function New-Item {
    param($ItemType,$Path,[switch]$Force)
    if ($Path -like 'HKCU:*') { return }
    Microsoft.PowerShell.Management\New-Item -ItemType $ItemType -Path $Path -Force:$Force
}
function New-ItemProperty {
    param($LiteralPath,$Name,$Value,$PropertyType,[switch]$Force,$ErrorAction)
    $script:registrationCalls++
    if ($script:registrationFails) { throw 'simulated registry failure' }
    $script:registered = $Value
}
$result = New-Results
Install-FontFile $font $result.Installed $result.Failed
$destination = Join-Path $SYSTEM_FONTS 'fixture.ttf'
Assert-That ((Test-Path $destination) -and $result.Failed.Count -eq 1) 'Partial registration failure was not reported.'
$script:registrationFails = $false
$result = New-Results
Install-FontFile $font $result.Installed $result.Failed
Assert-That ($result.Installed.Count -eq 1 -and (Test-FontRegistered $destination)) 'Rerun did not repair the existing font registration.'
$calls = $script:registrationCalls
Install-FontFile $font $result.Installed $result.Failed
Assert-That ($script:registrationCalls -eq $calls) 'Registered font was rewritten on rerun.'
Write-Host 'Partial font installation repair tests passed.'