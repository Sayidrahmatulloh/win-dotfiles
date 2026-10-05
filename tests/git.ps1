param([string]$RepoRoot = (Split-Path $PSScriptRoot -Parent))
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
. "$PSScriptRoot\helpers.ps1"
. "$RepoRoot\lib\files.ps1"
. "$RepoRoot\lib\settings.ps1"
Invoke-Expression (Read-Functions 'config/git/git.ps1')
$fixture=Join-Path ([IO.Path]::GetTempPath()) ('git config test '+[guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $fixture | Out-Null
$source=Join-Path $fixture 'shared config'; $destination=Join-Path $fixture '.gitconfig'
Copy-Item -LiteralPath (Join-Path $RepoRoot 'config\git\gitconfig') -Destination $source
& git config --file $destination user.name 'Fixture User'
& git config --file $destination user.email 'fixture@example.invalid'
& git config --file $destination credential.helper 'fixture-helper'
Install-GitConfig $source $destination
Assert-That ((& git config --file $destination user.name) -eq 'Fixture User') 'Name was changed.'
Assert-That ((& git config --file $destination user.email) -eq 'fixture@example.invalid') 'Email was changed.'
Assert-That ((& git config --file $destination credential.helper) -eq 'fixture-helper') 'Credential helper was changed.'
Assert-That ((& git config --file $destination --includes alias.st) -eq 'status --short --branch') 'Alias include was not loaded.'
Assert-That (@(Get-ChildItem -LiteralPath $fixture -Filter '.gitconfig.bak_*').Count -eq 1) 'Original global config was not backed up.'
Install-GitConfig $source $destination
Assert-That (@(& git config --file $destination --get-all include.path).Count -eq 1) 'Rerun duplicated include.'
Assert-That (@(Get-ChildItem -LiteralPath $fixture -Filter '.gitconfig.bak_*').Count -eq 1) 'Rerun created an unnecessary backup.'
$fresh=Join-Path $fixture 'fresh\config'
Install-GitConfig $source $fresh
Assert-That ((& git config --file $fresh --includes core.editor) -eq 'nvim') 'Fresh setup did not include shared config.'
$before=Get-Content -LiteralPath $destination -Raw
$threw=$false
try { Install-GitConfig (Join-Path $fixture 'missing') $destination } catch { $threw=$true }
Assert-That $threw 'Missing shared config was accepted.'
Assert-That ((Get-Content -LiteralPath $destination -Raw) -ceq $before) 'Failed install changed global config.'
$invalid=Join-Path $fixture 'invalid'; Set-Content -LiteralPath $invalid -Value '[broken'
$threw=$false
try { Install-GitConfig $invalid $destination } catch { $threw=$true }
Assert-That $threw 'Invalid shared config was accepted.'
Assert-That ((Get-Content -LiteralPath $destination -Raw) -ceq $before) 'Invalid config changed global config.'
Write-Host 'Git config tests passed.'
