# packages/scoop.ps1 — Install and upgrade packages via Scoop

param([switch]$Update)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\..\lib\utils.ps1"

# Package names live in setup.json; this file only knows Scoop commands.
$configuration = Get-SetupConfig -RepoRoot (Split-Path $PSScriptRoot -Parent)
$BUCKETS = $configuration.scoop.buckets
$TOOLS = $configuration.scoop.packages

function Sync-Buckets {
  param([string[]]$Buckets)
  Write-Section 'Buckets:'

  $anyAdded = $false
  $failedBuckets = [Collections.Generic.List[string]]::new()
  $i = 0

  foreach ($bucket in $Buckets) {
    $i++
    $pfx = "  [$i/$($Buckets.Count)]"

    if (Test-BucketAdded $bucket) {
      Write-Skip "bucket: $bucket"
      continue
    }

    Write-Step $pfx $bucket 'adding'

    if (Add-Bucket $bucket) {
      Write-Done "bucket added: $bucket"
      $anyAdded = $true
    }
    else {
      Write-Fail "bucket failed: $bucket"
      $failedBuckets.Add($bucket)
    }
  }

  if ($anyAdded) {
    Write-Step '  ' 'scoop' 'updating index'
    $null = Invoke-PackageCommand scoop @('update')
    Write-Done 'index updated'
  }
  if ($failedBuckets.Count) { throw "Scoop buckets failed: $($failedBuckets -join ', ')" }
}

function Sync-Tools {
    param([string[]]$Tools)
    Write-Section 'Tools:'
    Sync-Packages -Names $Tools -Update:$Update `
        -IsInstalled { param($name) Test-ToolInstalled $name } `
        -Install { param($name) Install-Tool $name } `
        -Upgrade { param($name) Update-Tool $name }
}

# Entry point

function Main {
  Assert-ScoopAvailable
  Sync-Buckets $BUCKETS
  $results = Sync-Tools $TOOLS
  Write-Summary 'Scoop' $results
  if ($results.Failed.Count) { throw "Scoop packages failed: $($results.Failed -join ', ')" }
}

Main
