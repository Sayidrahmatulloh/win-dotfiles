# Scoop commands used by both tools and fonts. No commands run at load time.
function Assert-ScoopAvailable {
  if (-not (Get-Command 'scoop' -ErrorAction SilentlyContinue)) {
    Write-Fail 'scoop not found. Run install.ps1 first.'
    throw 'Required package manager is not available.'
  }
}

# ── Bucket helpers ─────────────────────────────────────────────────────────────

function Test-ScoopBucketAdded {
    param([string]$Name)
    $result = Invoke-PackageCommand scoop @('bucket','list') -AllowedExitCodes @(0,2)
    if ($result.ExitCode -eq 2) {
        if (($result.Output | Out-String) -notmatch 'No bucket found') { throw "Scoop bucket inventory failed: $($result.Output | Out-String)" }
        return $false
    }
    return [bool]($result.Output | Where-Object { $_.PSObject.Properties['Name'] -and $_.Name -eq $Name })
}

function Add-ScoopBucket {
    param([string]$Name)
    $null = Invoke-PackageCommand scoop @('bucket','add',$Name)
    New-InstallResult -Name $Name -Status Installed
}

function Test-ScoopPackageInstalled {
    param([string]$Name)
    $result = Invoke-PackageCommand scoop @('list') -AllowedExitCodes @(0,1)
    if ($result.ExitCode -eq 1) {
        if (($result.Output | Out-String) -notmatch "There aren't any apps installed") { throw "Scoop inventory failed: $($result.Output | Out-String)" }
        return $false
    }
    return [bool]($result.Output | Where-Object { $_.PSObject.Properties['Name'] -and $_.Name -eq $Name })
}

function Install-ScoopPackage {
    param([string]$Name)
    $null = Invoke-PackageCommand scoop @('install',$Name)
    New-InstallResult -Name $Name -Status Installed
}

function Update-ScoopPackage {
    param([string]$Name)
    $result = Invoke-PackageCommand scoop @('update',$Name)
    if (($result.Output | Out-String) -match 'Latest versions for all apps are installed|is already the newest version') {
        return New-InstallResult -Name $Name -Status Latest -Message 'up to date'
    }
    New-InstallResult -Name $Name -Status Upgraded
}

# ── Scoop root resolver ───────────────────────────────────────────────────────

function Get-ScoopRoot {
  $cmd = Get-Command 'scoop' -ErrorAction SilentlyContinue
  if ($cmd) {
    $candidate = Split-Path (Split-Path $cmd.Source -Parent) -Parent
    if (Test-Path "$candidate\buckets") { return $candidate }
  }
  if ($env:SCOOP -and (Test-Path "$env:SCOOP\buckets")) { return $env:SCOOP }
  @("$env:USERPROFILE\scoop", "$env:ProgramData\scoop") |
  Where-Object { Test-Path "$_\buckets" } |
  Select-Object -First 1
}

function Sync-ScoopBuckets {
    param([string[]]$Buckets)
    Write-Section 'Buckets:'
    $results = Sync-Packages -Names $Buckets `
        -IsInstalled { param($name) Test-ScoopBucketAdded $name } `
        -Install { param($name) Add-ScoopBucket $name } `
        -Report { param($entry) Write-InstallResult $entry }
    if ($results.Installed.Count) {
        $null = Invoke-PackageCommand scoop @('update')
        Write-Done 'index updated'
    }
    Complete-InstallResults -Name 'Scoop buckets' -Results $results
}

function Sync-ScoopPackages {
    param([string[]]$Tools, [switch]$Update)
    Write-Section 'Tools:'
    Sync-Packages -Names $Tools -Update:$Update `
        -IsInstalled { param($name) Test-ScoopPackageInstalled $name } `
        -Install { param($name) Install-ScoopPackage $name } `
        -Upgrade { param($name) Update-ScoopPackage $name } `
        -Report { param($entry) Write-InstallResult $entry }
}

function Install-ScoopPackages {
    param([string[]]$Buckets, [string[]]$Tools, [switch]$Update)
    Assert-ScoopAvailable
    Sync-ScoopBuckets $Buckets
    $results = Sync-ScoopPackages -Tools $Tools -Update:$Update
    Complete-InstallResults -Name 'Scoop' -Results $results -FailureLabel 'Scoop packages'
}
