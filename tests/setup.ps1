param([string]$RepoRoot = 'D:/win-dotfiles')
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
function Read-Functions([string]$RelativePath) {
    $tokens=$null; $errors=$null
    $ast=[Management.Automation.Language.Parser]::ParseFile((Join-Path $RepoRoot $RelativePath),[ref]$tokens,[ref]$errors)
    if ($errors.Count) { throw ($errors | Out-String) }
    return ($ast.EndBlock.Statements | Where-Object { $_ -is [Management.Automation.Language.FunctionDefinitionAst] } | ForEach-Object { $_.Extent.Text }) -join "`n"
}
function Assert-That([bool]$Condition,[string]$Message) { if (-not $Condition) { throw $Message } }

# Load functions, never entrypoints: no installs, registry changes or real links.
Invoke-Expression (Read-Functions 'lib/utils.ps1')
function Write-Stage {}
function Write-Fail {}
function Write-Skip {}
function Write-Done {}
function Write-Step {}
function Write-Section {}
function Write-Summary {}
$ok=Invoke-Step 'ok' { Write-Output 'native output'; }
$failure=Invoke-Step 'failure' { throw 'simulated error' }
Assert-That ($ok.Success -and $ok.Name -eq 'ok') 'Successful step was not reported correctly.'
Assert-That (-not $failure.Success -and $failure.Message -eq 'simulated error') 'Step exception was swallowed.'
$next=Invoke-Step 'next' { }
Assert-That $next.Success 'A failed stage prevented later stages.'

Invoke-Expression (Read-Functions 'packages/scoop.ps1')
$Update=$false
function Test-ToolInstalled { param($Name) return $Name -eq 'existing' }
function Install-Tool { param($Name) $script:installedTools.Add($Name); return $Name -ne 'broken' }
function Update-Tool { throw 'Existing tools must not be upgraded by default.' }
$script:installedTools=[Collections.Generic.List[string]]::new()
$result=Sync-Tools @('existing','missing','broken')
Assert-That ($result.Latest -contains 'existing') 'Existing Scoop tool was not skipped.'
Assert-That ($result.Installed -contains 'missing') 'Missing Scoop tool was not installed.'
Assert-That ($result.Failed -contains 'broken') 'Scoop failure was not captured.'
Assert-That ($script:installedTools.Count -eq 2) 'Existing Scoop tool was reinstalled.'
function Assert-ScoopAvailable {}
function Sync-Buckets {}
$BUCKETS=@(); $TOOLS=@('broken')
$threw=$false
try { Main } catch { $threw=$true }
Assert-That $threw 'Scoop package failure did not reach installer.'
$TOOLS=@('existing'); Main

Invoke-Expression (Read-Functions 'packages/winget.ps1')
function Test-AppInstalled { param($AppId) return $AppId -eq 'existing' }
function Install-App { param($AppId) return $AppId -ne 'broken' }
function Update-App { throw 'Existing apps must not be upgraded by default.' }
$result=Sync-Apps @('existing','missing','broken')
Assert-That ($result.Latest -contains 'existing') 'Existing Winget app was not skipped.'
Assert-That ($result.Installed -contains 'missing') 'Missing Winget app was not installed.'
Assert-That ($result.Failed -contains 'broken') 'Winget failure was not captured.'
function Assert-WingetAvailable {}
$APPS=@('broken'); $threw=$false
try { Main } catch { $threw=$true }
Assert-That $threw 'Winget package failure did not reach installer.'

Invoke-Expression (Read-Functions 'install.ps1')
$DOTFILES=$RepoRoot
$script:bunCalls=0
function bun { $script:bunCalls++; $global:LASTEXITCODE=1 }
$threw=$false
try { Build-Zebar } catch { $threw=$_.Exception.Message -like 'Zebar dependencies failed*' }
Assert-That ($threw -and $script:bunCalls -eq 1) 'Failed dependency install continued to build.'
$script:bunCalls=0
function bun { $script:bunCalls++; $global:LASTEXITCODE=if ($script:bunCalls -eq 1) {0} else {1} }
$threw=$false
try { Build-Zebar } catch { $threw=$_.Exception.Message -like 'Zebar build failed*' }
Assert-That $threw 'A stale dist directory hid build failure.'

Invoke-Expression (Read-Functions 'config/symlinks.ps1')
$threw=$false
try { Initialize-SourceDirs @(@{Src=(Join-Path $env:TEMP ('missing-dotfiles-'+[guid]::NewGuid()))}) } catch { $threw=$true }
Assert-That $threw 'Missing config source was silently replaced with an empty folder.'
$testDir=Join-Path $env:TEMP ('dotfiles-tests-'+[guid]::NewGuid().ToString('N'))
$fontName='CaskaydiaMonoNerdFont-Regular.ttf'
$script:testScoopRoot=Join-Path $testDir 'scoop'
$widgetDir=Join-Path $testDir 'widget'
$fontDir=Join-Path $script:testScoopRoot 'apps/CascadiaMono-NF/current'
New-Item -ItemType Directory -Path $fontDir -Force | Out-Null
[IO.File]::WriteAllText((Join-Path $fontDir $fontName),'fixture-font')
function Get-ScoopRoot { return $script:testScoopRoot }
Ensure-ZebarFont -WidgetDir $widgetDir
$targetFont=Join-Path $widgetDir "src/fonts/$fontName"
Assert-That ((Get-Content -LiteralPath $targetFont -Raw) -eq 'fixture-font') 'Font was not restored from Scoop.'
[IO.File]::WriteAllText($targetFont,'existing-font')
Ensure-ZebarFont -WidgetDir $widgetDir
Assert-That ((Get-Content -LiteralPath $targetFont -Raw) -eq 'existing-font') 'Existing font was overwritten.'

Invoke-Expression (Read-Functions 'bootstrap.ps1')
$pwshPath=Find-PowerShell7
Assert-That (-not [string]::IsNullOrWhiteSpace($pwshPath)) 'Existing PowerShell 7 was not discovered.'
$principal=[Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    function Find-PowerShell7 { return 'Invoke-TestPwsh' }
    function Invoke-TestPwsh { $script:childArguments=@($args); $global:LASTEXITCODE=0 }
    $DotfilesPath=$RepoRoot
    Start-DotfilesSetup
    Assert-That ($script:childArguments -contains '-NoProfile') 'User profile was loaded during setup.'
    Assert-That ($script:childArguments -contains [IO.Path]::GetFullPath($RepoRoot)) 'Repository path was not passed to child process.'
    function Invoke-TestPwsh { $global:LASTEXITCODE=1 }
    $threw=$false
    try { Start-DotfilesSetup } catch { $threw=$_.Exception.Message -like 'Setup has unfinished steps*' }
    Assert-That $threw 'Bootstrap ignored child setup failure.'
    function Find-PowerShell7 { return $null }
    function Get-Command { param([string]$Name) if ($Name -eq 'winget.exe') { return $null }; Microsoft.PowerShell.Core\Get-Command $Name -ErrorAction SilentlyContinue }
    $threw=$false
    try { Start-DotfilesSetup } catch { $threw=$_.Exception.Message -like 'WinGet was not found*' }
    Assert-That $threw 'Missing WinGet did not produce actionable failure.'
    function Get-Command { param([string]$Name) if ($Name -eq 'winget.exe') { return [pscustomobject]@{Source='mock-winget'} }; Microsoft.PowerShell.Core\Get-Command $Name -ErrorAction SilentlyContinue }
    $script:findCalls=0
    function Find-PowerShell7 { $script:findCalls++; if ($script:findCalls -eq 1) { return $null }; return 'Invoke-TestPwsh' }
    $script:wingetCalls=0
    function winget.exe { $script:wingetCalls++; Assert-That ($args -contains 'Microsoft.PowerShell') 'Bootstrap installed wrong package.'; $global:LASTEXITCODE=0 }
    function Invoke-TestPwsh { $global:LASTEXITCODE=0 }
    Start-DotfilesSetup
    Assert-That ($script:wingetCalls -eq 1) 'PowerShell was not bootstrapped through Winget.'
    function Find-PowerShell7 { return $null }
    function winget.exe { $global:LASTEXITCODE=2 }
    $threw=$false
    try { Start-DotfilesSetup } catch { $threw=$_.Exception.Message -like 'PowerShell installation failed*' }
    Assert-That $threw 'Bootstrap ignored PowerShell installation failure.'
} else { Write-Host 'Bootstrap non-admin scenarios skipped in elevated test process.' }
Write-Host 'PASS: stages, package failures, rerun skipping, build failures, missing config sources, bootstrap.'
