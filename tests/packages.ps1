param([string]$RepoRoot = (Split-Path $PSScriptRoot -Parent))
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
. "$PSScriptRoot\helpers.ps1"
. "$RepoRoot\lib\utils.ps1"
function Write-Skip {}
function Write-Done {}
function Write-Fail {}
function Write-Step {}

# Update mode must distinguish upgraded/latest/failed and continue after exceptions.
$result = Sync-Packages -Names @('upgrade','latest','broken','throws','missing') -Update `
    -IsInstalled { param($name) $name -ne 'missing' } `
    -Install { param($name) $true } `
    -Upgrade {
        param($name)
        switch ($name) {
            upgrade { 'upgraded' }
            latest { 'latest' }
            broken { 'failed' }
            throws { throw 'manager exception' }
        }
    }
Assert-That ($result.Upgraded -contains 'upgrade') 'Upgrade success was lost.'
Assert-That ($result.Latest -contains 'latest') 'Already-latest result was lost.'
Assert-That ($result.Failed.Count -eq 2) 'Upgrade failures were not aggregated.'
Assert-That ($result.Installed -contains 'missing') 'A failed upgrade stopped later installs.'

# An inventory error must not be treated as a missing package and trigger installation.
$script:installed = @()
$result = Sync-Packages -Names @('inventory-error','next') `
    -IsInstalled { param($name) if ($name -eq 'inventory-error') { throw 'inventory failed' }; $false } `
    -Install { param($name) $script:installed += $name; $true } `
    -Upgrade { throw 'Update was not requested.' }
Assert-That ($result.Failed -contains 'inventory-error') 'Inventory failure was hidden.'
Assert-That ($script:installed.Count -eq 1 -and $script:installed[0] -eq 'next') 'Failed inventory caused an install or blocked the next item.'

# Scoop fonts use the same loop as tools. No real package manager runs.
Invoke-Expression (Read-Functions 'fonts/fonts.ps1')
$Update = $false
function Ensure-NerdFontsBucket {}
function Test-ScoopFontInstalled { param($Name) $Name -eq 'existing' }
function Install-Tool { param($Name) $Name -ne 'broken' }
function Update-Tool { throw 'Update was not requested.' }
$result = Install-ScoopFonts @('existing','missing','broken')
Assert-That ($result.Latest -contains 'existing') 'Existing font was reinstalled.'
Assert-That ($result.Installed -contains 'missing') 'Missing font was not installed.'
Assert-That ($result.Failed -contains 'broken') 'Font failure was not captured.'
Write-Host 'Package loop and font adapter tests passed.'

# ZIP extraction must preserve unrelated files in the shared temp directory.
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('font-test-' + [guid]::NewGuid().ToString('N'))
$archiveDir = Join-Path $fixture 'archives'
$tempDir = Join-Path $fixture 'shared-temp'
$sourceDir = Join-Path $fixture 'font-source'
New-Item -ItemType Directory -Path $archiveDir, $tempDir, $sourceDir -Force | Out-Null
$sentinel = Join-Path $tempDir 'keep.txt'
Set-Content -LiteralPath $sentinel -Value 'unrelated file'
Set-Content -LiteralPath (Join-Path $sourceDir 'fixture.ttf') -Value 'fixture font'
Compress-Archive -LiteralPath (Join-Path $sourceDir 'fixture.ttf') -DestinationPath (Join-Path $archiveDir 'fixture.zip')
function Install-FontFile { param($FontPath, $Installed, $Failed) $Installed.Add((Split-Path $FontPath -Leaf)) }
$result = Install-ZipFonts -FilesDir $archiveDir -TempDir $tempDir
Assert-That ($result.Installed -contains 'fixture.ttf') 'ZIP font was not passed to the font installer.'
Assert-That (Test-Path -LiteralPath $sentinel) 'Unrelated temp file was deleted.'
Assert-That (@(Get-ChildItem -LiteralPath $tempDir -Directory).Count -eq 0) 'Private extraction directory was not cleaned.'
function Install-FontFile { throw 'simulated font failure' }
$threw = $false
try { Install-ZipFonts -FilesDir $archiveDir -TempDir $tempDir } catch { $threw = $true }
Assert-That $threw 'Font extraction failure was hidden.'
Assert-That (Test-Path -LiteralPath $sentinel) 'Failed extraction deleted unrelated files.'
Assert-That (@(Get-ChildItem -LiteralPath $tempDir -Directory).Count -eq 0) 'Failed extraction did not clean its private directory.'
Write-Host 'Font extraction isolation tests passed.'
