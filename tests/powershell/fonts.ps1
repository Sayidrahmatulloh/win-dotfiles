param([string]$RepoRoot = (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent))
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
. "$PSScriptRoot/../support/powershell.ps1"
. "$RepoRoot\lib\utils.ps1"
. "$RepoRoot/lib/setup/fonts.ps1"
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('font-repair-test-' + [guid]::NewGuid().ToString('N'))
$SYSTEM_FONTS = Join-Path $fixture 'installed'
New-Item -ItemType Directory -Path $fixture | Out-Null
$font = Join-Path $fixture 'fixture.ttf'
Set-Content -LiteralPath $font -Value 'font bytes'
$script:registered = $null
$script:registrationFails = $true
$script:registrationCalls = 0
function Get-ItemPropertyValue {
    param($LiteralPath,$Name,$ErrorAction)
    if ($null -eq $script:registered) { throw [System.Management.Automation.PSArgumentException]::new('Missing registry value.') }
    return $script:registered
}
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
$message = $null
try { Install-FontFile $font -SystemFonts $SYSTEM_FONTS } catch { $message = $_.Exception.Message }
$destination = Join-Path $SYSTEM_FONTS 'fixture.ttf'
Assert-That ((Test-Path $destination) -and $message -eq 'simulated registry failure') 'Partial registration failure was not propagated.'
$script:registrationFails = $false
$result = Install-FontFile $font -SystemFonts $SYSTEM_FONTS
Assert-That ($result.Status -eq 'Installed' -and (Test-FontRegistered $destination)) 'Rerun did not repair the existing font registration.'
$calls = $script:registrationCalls
$result = Install-FontFile $font -SystemFonts $SYSTEM_FONTS
Assert-That ($result.Status -eq 'Latest' -and $script:registrationCalls -eq $calls) 'Registered font was rewritten on rerun.'
Write-Host 'Partial font installation repair tests passed.'
