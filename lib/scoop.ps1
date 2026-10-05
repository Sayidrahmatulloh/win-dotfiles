# Scoop commands used by both tools and fonts. No commands run at load time.
function Assert-ScoopAvailable {
  if (-not (Get-Command 'scoop' -ErrorAction SilentlyContinue)) {
    Write-Fail 'scoop not found. Run install.ps1 first.'
    throw 'Required package manager is not available.'
  }
}

# ── Bucket helpers ─────────────────────────────────────────────────────────────

function Test-BucketAdded {
    param([string]$Name)
    $result = Invoke-PackageCommand scoop @('bucket','list') -AllowedExitCodes @(0,2)
    if ($result.ExitCode -eq 2) {
        if (($result.Output | Out-String) -notmatch 'No bucket found') { throw "Scoop bucket inventory failed: $($result.Output | Out-String)" }
        return $false
    }
    return [bool]($result.Output | Where-Object { $_.PSObject.Properties['Name'] -and $_.Name -eq $Name })
}

function Add-Bucket {
    param([string]$Name)
    $null = Invoke-PackageCommand scoop @('bucket','add',$Name)
    return $true
}

function Test-ToolInstalled {
    param([string]$Name)
    $result = Invoke-PackageCommand scoop @('list') -AllowedExitCodes @(0,1)
    if ($result.ExitCode -eq 1) {
        if (($result.Output | Out-String) -notmatch "There aren't any apps installed") { throw "Scoop inventory failed: $($result.Output | Out-String)" }
        return $false
    }
    return [bool]($result.Output | Where-Object { $_.PSObject.Properties['Name'] -and $_.Name -eq $Name })
}

function Install-Tool {
    param([string]$Name)
    $null = Invoke-PackageCommand scoop @('install',$Name)
    return $true
}

function Update-Tool {
    param([string]$Name)
    $result = Invoke-PackageCommand scoop @('update',$Name)
    if (($result.Output | Out-String) -match 'Latest versions for all apps are installed|is already the newest version') { return 'latest' }
    return 'upgraded'
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
