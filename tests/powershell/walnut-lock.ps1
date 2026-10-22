param([string]$RepoRoot = (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent))
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/../support/powershell.ps1"
Add-Type -AssemblyName System.Security
. "$RepoRoot/apps/walnut-lock/credentials.ps1"

$fixture = Join-Path ([IO.Path]::GetTempPath()) ('walnut-credential-test-' + [guid]::NewGuid().ToString('N'))
$path = Join-Path $fixture 'credential.dat'
Assert-That ($null -eq (Read-Credential -Path $path)) 'A missing credential was not handled.'
Save-Credential -Code 'FixtureOnly123' -Path $path
$record = Read-Credential -Path $path
$salt = [Convert]::FromBase64String($record.salt)
Assert-That ((Get-CodeHash 'FixtureOnly123' $salt) -ceq $record.hash) 'Credential round trip failed.'
Assert-That ((Get-CodeHash 'WrongCode123' $salt) -cne $record.hash) 'Wrong code matched the credential.'
Assert-That ([Text.Encoding]::UTF8.GetString([IO.File]::ReadAllBytes($path)) -notmatch 'FixtureOnly123') 'Credential was stored as plaintext.'
Save-Credential -Code 'FixtureOnly123' -Path $path
Assert-That ((Read-Credential -Path $path).salt -cne $record.salt) 'Saving a credential reused its salt.'

# SelfTest compiles and constructs windows, then exits before installing hooks.
& "$RepoRoot/apps/walnut-lock/start.ps1" -SelfTest
if ($LASTEXITCODE -ne 0) { throw 'Walnut self-test failed.' }
& "$RepoRoot/apps/walnut-lock/watch.ps1" -CheckOnly

# Exercise the deployed startup adapter without starting the supervisor or input lock.
$launcherCalls = [Collections.Generic.List[string]]::new()
function Start-Process {
    param($FilePath, $WindowStyle, $ArgumentList)
    Assert-That ($FilePath -eq 'powershell.exe' -and $WindowStyle -eq 'Hidden') 'Startup did not select the hidden Windows PowerShell host.'
    $fileIndex = [array]::IndexOf($ArgumentList, '-File')
    Assert-That ($fileIndex -ge 0) 'Startup omitted its script argument.'
    $target = $ArgumentList[$fileIndex + 1].Trim('"')
    Assert-That ([IO.Path]::GetFullPath($target) -eq [IO.Path]::GetFullPath("$RepoRoot/apps/walnut-lock/watch.ps1")) 'Startup still points to the old application directory.'
    $launcherCalls.Add($target)
}
& "$RepoRoot/config/glzr/glazewm/start-walnut-lock.ps1"
Assert-That ($launcherCalls.Count -eq 1) 'GlazeWM startup did not invoke the supervisor exactly once.'
Remove-Item Function:\Start-Process
Write-Host 'Walnut credential, host forwarding, UI and migrated startup tests passed without locking input.'
