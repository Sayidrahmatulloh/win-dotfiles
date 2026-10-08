param([string]$RepoRoot = (Split-Path $PSScriptRoot -Parent))
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
. "$PSScriptRoot\helpers.ps1"
. "$RepoRoot\lib\utils.ps1"
Invoke-Expression (Read-Functions 'config/symlinks.ps1')
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('profile-entry-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $fixture | Out-Null
$loader = '$global:dotfilesProfileLoaded = $true'
foreach ($content in @('# previous profile', '$global:previousProfileLoaded = $true', "# previous profile`r`n", '')) {
    $path = Join-Path $fixture ('profile-' + [guid]::NewGuid().ToString('N') + '.ps1')
    [IO.File]::WriteAllText($path, $content)
    Set-ProfileEntry -ProfilePath $path -Line $loader
    $global:dotfilesProfileLoaded = $false
    . $path
    Assert-That $global:dotfilesProfileLoaded 'Appended profile entry did not execute.'
    $before = [IO.File]::ReadAllText($path)
    Set-ProfileEntry -ProfilePath $path -Line $loader
    Assert-That ([IO.File]::ReadAllText($path) -ceq $before) 'Repeated setup modified the profile.'
    Assert-That ($before.StartsWith($content)) 'Existing profile content changed.'
}
Write-Host 'Profile newline and idempotency tests passed.'
