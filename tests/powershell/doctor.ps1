param([string]$RepoRoot = (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent))
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
. "$PSScriptRoot/../support/powershell.ps1"
. "$RepoRoot\lib\core\files.ps1"
. "$RepoRoot\lib\setup\settings.ps1"
Invoke-Expression (Read-Functions 'lib/diagnostics.ps1')
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
# A different checkout must use its own requiredCommands, not the runner's manifest.
$configuration = Get-SetupConfig $RepoRoot
$configuration.requiredCommands = @('dotfiles-fixture-command-does-not-exist')
$configuration | ConvertTo-Json -Depth 10 | Set-Content (Join-Path $fixture 'setup.json')
$jsonOutput = & pwsh -NoProfile -File (Join-Path $RepoRoot 'doctor.ps1') -DotfilesPath $fixture -Json
$parsed = @($jsonOutput | ConvertFrom-Json)
Assert-That (@($parsed | Where-Object Name -eq 'Command: dotfiles-fixture-command-does-not-exist').Count -eq 1) 'Doctor ignored the selected checkout manifest.'
Assert-That (@($parsed | Where-Object Name -eq 'Command: pwsh').Count -eq 0) 'Doctor used the runner checkout manifest.'

# Mock link metadata: no real user links are modified.
function Get-Item { param($LiteralPath,[switch]$Force,$ErrorAction) [pscustomobject]@{LinkType='Junction';Target=$script:target} }
$script:target=$fixture
Assert-That ((Test-DoctorLink $fixture (Join-Path $fixture 'link')).Status -eq 'OK') 'Correct junction was rejected.'
$script:target=Join-Path $fixture 'other'
Assert-That ((Test-DoctorLink $fixture (Join-Path $fixture 'link')).Status -eq 'FAIL') 'Wrong checkout junction was accepted.'
Write-Host 'Doctor tests passed.'

# Real runtime checks: matching, stale, invalid selection and missing files.
$runtimeFixture = Join-Path $fixture 'runtime'
New-Item -ItemType Directory -Path $runtimeFixture | Out-Null
Copy-Item "$RepoRoot/config/glzr/zebar/settings.json" "$runtimeFixture/settings.json"
Copy-Item "$RepoRoot/widgets/zebar/normalize.css" "$runtimeFixture/normalize.css"
$config = Get-SetupConfig $RepoRoot
$result = @(Test-DoctorZebarRuntime -RepoRoot $RepoRoot -Configuration $config -RuntimeDirectory $runtimeFixture)
Assert-That (@($result | Where-Object Status -ne OK).Count -eq 0) 'Matching runtime files were rejected.'
Add-Content "$runtimeFixture/settings.json" ' '
$result = @(Test-DoctorZebarRuntime -RepoRoot $RepoRoot -Configuration $config -RuntimeDirectory $runtimeFixture)
Assert-That (@($result | Where-Object Status -eq WARN).Count -eq 1) 'Stale runtime settings were missed.'
$settings = Get-Content "$RepoRoot/config/glzr/zebar/settings.json" -Raw | ConvertFrom-Json
$settings.startupConfigs[0].pack = 'missing'
$settings | ConvertTo-Json -Depth 10 | Set-Content "$runtimeFixture/settings.json"
$result = Invoke-DoctorCheck 'runtime' { Test-DoctorZebarRuntime -RepoRoot $RepoRoot -Configuration $config -RuntimeDirectory $runtimeFixture }
Assert-That ($result.Status -eq 'FAIL') 'Wrong runtime startup pack was accepted.'
Set-Content "$runtimeFixture/settings.json" '{invalid'
$result = Invoke-DoctorCheck 'runtime' { Test-DoctorZebarRuntime -RepoRoot $RepoRoot -Configuration $config -RuntimeDirectory $runtimeFixture }
Assert-That ($result.Status -eq 'FAIL') 'Malformed runtime JSON was accepted.'
Remove-Item -LiteralPath "$runtimeFixture/settings.json"
$result = Invoke-DoctorCheck 'runtime' { Test-DoctorZebarRuntime -RepoRoot $RepoRoot -Configuration $config -RuntimeDirectory $runtimeFixture }
Assert-That ($result.Status -eq 'FAIL') 'Missing runtime settings were accepted.'
