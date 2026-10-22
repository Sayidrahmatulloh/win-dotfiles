param([string]$RepoRoot = (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent))
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
. "$PSScriptRoot/../support/powershell.ps1"
. "$RepoRoot\lib\utils.ps1"
function Write-Skip {}
function Write-Done {}
function Write-Fail {}
function Write-Step {}

# Update mode must distinguish upgraded/latest/failed and continue after exceptions.
$result = Sync-Packages -Names @('upgrade','latest','broken','throws','missing') -Update `
    -IsInstalled { param($name) $name -ne 'missing' } `
    -Install { param($name) New-InstallResult -Name $name -Status Installed } `
    -Upgrade {
        param($name)
        switch ($name) {
            upgrade { New-InstallResult -Name $name -Status Upgraded }
            latest { New-InstallResult -Name $name -Status Latest }
            broken { 'failed' }
            throws { throw 'manager exception' }
        }
    }
Assert-That ($result.Upgraded -contains 'upgrade') 'Upgrade success was lost.'
Assert-That ($result.Latest -contains 'latest') 'Already-latest result was lost.'
Assert-That ($result.Failed.Count -eq 2) 'Upgrade failures were not aggregated.'
Assert-That ($result.Installed -contains 'missing') 'A failed upgrade stopped later installs.'
Assert-That ($result.Entries.Count -eq 5 -and ($result.Entries | Where-Object Name -eq 'throws').Message -eq 'manager exception') 'Structured results lost a package or its error message.'

# Reject legacy booleans, mismatched names and mixed command output as successes.
$reported = [Collections.Generic.List[object]]::new()
$invalid = Sync-Packages -Names @('boolean', 'wrong-name', 'mixed', 'next') `
    -IsInstalled { $false } `
    -Install {
        param($name)
        switch ($name) {
            boolean { $true }
            wrong-name { New-InstallResult -Name 'another-package' -Status Installed }
            mixed { 'unexpected stdout'; New-InstallResult -Name $name -Status Installed }
            next { New-InstallResult -Name $name -Status Installed }
        }
    } `
    -Report { param($entry) $reported.Add($entry); 'reporter stdout must not enter the result' }
Assert-That ($invalid.Failed.Count -eq 3 -and $invalid.Installed -contains 'next') 'Invalid adapter output was accepted or stopped later packages.'
Assert-That ($reported.Count -eq 4 -and $invalid.Entries.Count -eq 4) 'Result reporting changed the operation output.'
$invalidInventory = Sync-Packages -Names @('ambiguous') -IsInstalled { 'inventory unavailable' } -Install { throw 'Must not install after invalid inventory.' }
Assert-That ($invalidInventory.Failed.Count -eq 1 -and $invalidInventory.Entries[0].Message -like 'Invalid inventory result*') 'Invalid inventory output was treated as an installed package.'
$invalidUpgrade = Sync-Packages -Names @('existing') -Update -IsInstalled { $true } -Upgrade { param($name) New-InstallResult -Name $name -Status Installed }
Assert-That ($invalidUpgrade.Failed.Count -eq 1) 'An install status was accepted as an upgrade result.'

# An inventory error must not be treated as a missing package and trigger installation.
$script:installed = @()
$result = Sync-Packages -Names @('inventory-error','next') `
    -IsInstalled { param($name) if ($name -eq 'inventory-error') { throw 'inventory failed' }; $false } `
    -Install { param($name) $script:installed += $name; New-InstallResult -Name $name -Status Installed } `
    -Upgrade { throw 'Update was not requested.' }
Assert-That ($result.Failed -contains 'inventory-error') 'Inventory failure was hidden.'
Assert-That ($script:installed.Count -eq 1 -and $script:installed[0] -eq 'next') 'Failed inventory caused an install or blocked the next item.'

# Scoop fonts use the same loop as tools. No real package manager runs.
. "$RepoRoot/lib/setup/fonts.ps1"
$Update = $true # An unrelated caller variable must never enable upgrades.
function Ensure-NerdFontsBucket {}
function Test-ScoopFontInstalled { param($Name, $ScoopRoot) $Name -eq 'existing' }
function Install-ScoopPackage { param($Name) if ($Name -eq 'broken') { throw 'simulated package failure' }; New-InstallResult -Name $Name -Status Installed }
function Update-ScoopPackage { throw 'Update was not requested.' }
$result = Install-ScoopFonts @('existing','missing','broken') -ScoopRoot 'fixture scoop root'
Assert-That ($result.Latest -contains 'existing') 'Existing font was reinstalled.'
Assert-That ($result.Installed -contains 'missing') 'Missing font was not installed.'
Assert-That ($result.Failed -contains 'broken') 'Font failure was not captured.'
function Update-ScoopPackage { param($Name) New-InstallResult -Name $Name -Status Upgraded }
$result = Install-ScoopFonts @('existing') -ScoopRoot 'fixture scoop root' -Update
Assert-That ($result.Upgraded -contains 'existing') 'The explicit font Update switch was not forwarded.'
Write-Host 'Package loop and font adapter tests passed.'

# Shared summary handling must preserve aggregate failures for every stage type.
function Write-Summary { param($Name, $Results) }
$failed = New-Results
Add-InstallResult -Results $failed -Entry (New-InstallResult -Name 'fixture-font' -Status Failed)
$message = $null
try { Complete-InstallResults -Name 'Fonts' -Results $failed }
catch { $message = $_.Exception.Message }
Assert-That ($message -eq 'Fonts failed: fixture-font') 'Shared summary lost its default failure label or failed items.'
Complete-InstallResults -Name 'Fonts' -Results (New-Results)

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
function Install-FontFile { param($FontPath, $SystemFonts) New-InstallResult -Name (Split-Path $FontPath -Leaf) -Status Installed }
$result = Install-ZipFonts -FilesDir $archiveDir -TempDir $tempDir
Assert-That ($result.Installed -contains 'fixture.ttf') 'ZIP font was not passed to the font installer.'
Assert-That (Test-Path -LiteralPath $sentinel) 'Unrelated temp file was deleted.'
Assert-That (@(Get-ChildItem -LiteralPath $tempDir -Directory).Count -eq 0) 'Private extraction directory was not cleaned.'
function Install-FontFile { throw 'simulated font failure' }
$result = Install-ZipFonts -FilesDir $archiveDir -TempDir $tempDir
Assert-That ($result.Failed -contains 'fixture.ttf' -and $result.Entries[0].Message -eq 'simulated font failure') 'Font installation failure was hidden.'
Assert-That (Test-Path -LiteralPath $sentinel) 'Failed extraction deleted unrelated files.'
Assert-That (@(Get-ChildItem -LiteralPath $tempDir -Directory).Count -eq 0) 'Failed extraction did not clean its private directory.'
Write-Host 'Font extraction isolation tests passed.'

# Bucket setup shares the package loop and refreshes the index only after additions.
$bucketAdds = [Collections.Generic.List[string]]::new()
$indexUpdates = [Collections.Generic.List[string]]::new()
function Test-ScoopBucketAdded { param($Name) $Name -eq 'existing' }
function Add-ScoopBucket {
    param($Name)
    $bucketAdds.Add($Name)
    if ($Name -eq 'broken') { throw 'bucket source unavailable' }
    New-InstallResult -Name $Name -Status Installed
}
function Invoke-PackageCommand { param($Command, $Arguments) $indexUpdates.Add($Command + ' ' + ($Arguments -join ' ')) }
Sync-ScoopBuckets @('existing')
Assert-That ($bucketAdds.Count -eq 0 -and $indexUpdates.Count -eq 0) 'An existing bucket was added again or refreshed the index.'
$message = $null
try { Sync-ScoopBuckets @('existing', 'broken', 'next') } catch { $message = $_.Exception.Message }
Assert-That ($message -eq 'Scoop buckets failed: broken') 'Bucket errors did not reach the installer.'
Assert-That (($bucketAdds -join ',') -eq 'broken,next' -and $indexUpdates.Count -eq 1 -and $indexUpdates[0] -eq 'scoop update') 'A failed bucket blocked the next bucket or changed index refresh behavior.'
Write-Host 'Bucket retries, aggregate failures and conditional index refresh passed.'
