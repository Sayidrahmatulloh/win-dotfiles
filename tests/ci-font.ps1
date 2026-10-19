param([string]$RepoRoot = (Split-Path $PSScriptRoot -Parent))
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/helpers.ps1"
. "$RepoRoot/lib/settings.ps1"
$fontName = (Get-SetupConfig -RepoRoot $RepoRoot).zebar.fontFile
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('ci-font-test-' + [guid]::NewGuid().ToString('N'))
$downloads = [Collections.Generic.List[string]]::new()
function Invoke-RestMethod {
    [pscustomobject]@{ assets = @([pscustomobject]@{ name = 'CascadiaMono.zip'; browser_download_url = 'https://fixture.invalid/font.zip' }) }
}
function Invoke-WebRequest {
    param($Uri, $OutFile)
    $downloads.Add($Uri)
    Set-Content -LiteralPath $OutFile 'fixture archive'
}
function Expand-Archive {
    param($LiteralPath, $DestinationPath)
    New-Item -ItemType Directory -Path $DestinationPath -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $DestinationPath $fontName) 'fixture font'
}
& "$RepoRoot/tools/prepare-ci-font.ps1" -FontDirectory $fixture
$target = Join-Path $fixture $fontName
Assert-That ((Get-Content -LiteralPath $target -Raw).Trim() -eq 'fixture font') 'Font was not copied to the selected widget directory.'
& "$RepoRoot/tools/prepare-ci-font.ps1" -FontDirectory $fixture
Assert-That ($downloads.Count -eq 1) 'Existing font was downloaded again.'
Write-Host 'CI font destination and repeat-run checks passed without network access.'
