param([string]$RepoRoot = (Split-Path $PSScriptRoot -Parent))
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$tokens=$null; $errors=$null
$ast=[Management.Automation.Language.Parser]::ParseFile((Join-Path $RepoRoot 'doctor.ps1'),[ref]$tokens,[ref]$errors)
if ($errors.Count) { throw ($errors | Out-String) }
foreach ($statement in $ast.EndBlock.Statements) {
    if ($statement -is [Management.Automation.Language.FunctionDefinitionAst]) { Invoke-Expression $statement.Extent.Text }
}
function Assert-That([bool]$Condition,[string]$Message) { if (-not $Condition) { throw $Message } }
$result=Invoke-DoctorCheck 'broken' { throw 'fixture error' }
Assert-That ($result.Status -eq 'FAIL' -and $result.Detail -eq 'fixture error') 'Check exception was not reported.'
$result=Invoke-DoctorCheck 'next' { New-DoctorResult 'next' OK 'continued' }
Assert-That ($result.Status -eq 'OK') 'Failed check prevented continuation.'
$fixture=Join-Path ([IO.Path]::GetTempPath()) ('doctor-test-'+[guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $fixture | Out-Null
$package=Join-Path $fixture 'package.json'; $lock=Join-Path $fixture 'bun.lock'
Set-Content $package '{"dependencies":{"zebar":"3.2.0"},"devDependencies":{"vite":"6.4.1"}}'
Set-Content $lock '{"workspaces":{"":{"devDependencies":{"vite":"6.4.1"},"dependencies":{"zebar":"3.2.0"}}}}'
Assert-That ((Test-DoctorLock $package $lock).Status -eq 'OK') 'Matching lockfile was rejected.'
Set-Content $lock '{"workspaces":{"":{"dependencies":{"zebar":"3.1.0"},"devDependencies":{"vite":"6.4.1"}}}}'
Assert-That ((Test-DoctorLock $package $lock).Status -eq 'FAIL') 'Version mismatch was missed.'
Set-Content $lock '{"workspaces":{"":{"dependencies":{"zebar":"3.2.0"}}}}'
Assert-That ((Test-DoctorLock $package $lock).Status -eq 'FAIL') 'Missing dev dependency was missed.'
Set-Content $lock '{"workspaces":{}}'
Assert-That ((Invoke-DoctorCheck 'lock' { Test-DoctorLock $package $lock }).Status -eq 'FAIL') 'Missing root workspace was missed.'
$result=Test-DoctorLink (Join-Path $fixture 'source') (Join-Path $fixture 'missing')
Assert-That ($result.Status -eq 'FAIL') 'Missing config destination was missed.'
$result=Test-DoctorLink $fixture $fixture
Assert-That ($result.Status -eq 'WARN') 'Separate copy was incorrectly reported as linked.'
$jsonOutput = & pwsh -NoProfile -File (Join-Path $RepoRoot 'doctor.ps1') -DotfilesPath $fixture -Json
$doctorExit = $LASTEXITCODE
$parsed = @($jsonOutput | ConvertFrom-Json)
Assert-That ($doctorExit -eq 1) 'Broken setup did not return exit 1.'
Assert-That (@($parsed | Where-Object Status -eq FAIL).Count -gt 0) 'JSON output lost failures.'
Assert-That (@($parsed | Where-Object Name -eq Scope).Count -eq 1) 'A failed check prevented later checks.'
Assert-That (-not (Test-Path (Join-Path $fixture 'config'))) 'Doctor modified the fixture checkout.'
# Mock link metadata: no real user links are modified.
function Get-Item { param($LiteralPath,[switch]$Force,$ErrorAction) [pscustomobject]@{LinkType='Junction';Target=$script:target} }
$script:target=$fixture
Assert-That ((Test-DoctorLink $fixture (Join-Path $fixture 'link')).Status -eq 'OK') 'Correct junction was rejected.'
$script:target=Join-Path $fixture 'other'
Assert-That ((Test-DoctorLink $fixture (Join-Path $fixture 'link')).Status -eq 'FAIL') 'Wrong checkout junction was accepted.'
Write-Host 'Doctor tests passed.'