param([string]$RepoRoot = (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent))
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/../support/powershell.ps1"
Add-Type -AssemblyName System.Security
. "$RepoRoot/tools/walnut-lock/credentials.ps1"

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
& "$RepoRoot/tools/walnut-lock/start.ps1" -SelfTest
if ($LASTEXITCODE -ne 0) { throw 'Walnut self-test failed.' }
& "$RepoRoot/tools/walnut-lock/watch.ps1" -CheckOnly
Write-Host 'Walnut credential, host forwarding and UI self-tests passed without locking input.'
