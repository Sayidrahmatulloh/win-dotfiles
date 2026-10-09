# scripts/install/winget.ps1 — Install and upgrade apps via Winget

param([switch]$Update)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\..\..\lib\utils.ps1"

# Package IDs live in setup.json; this file only knows Winget commands.
$configuration = Get-SetupConfig -RepoRoot (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)
$APPS = $configuration.winget

$WINGET_FLAGS = @(
  '--silent'
  '--accept-package-agreements'
  '--accept-source-agreements'
)

# Guards

function Assert-WingetAvailable {
  if (-not (Get-Command 'winget' -ErrorAction SilentlyContinue)) {
    Write-Fail 'winget not found. Install App Installer from the Microsoft Store.'
    throw 'Required package manager is not available.'
  }
}

# App helpers

function Test-AppInstalled {
    param([string]$AppId)
    # 0x8A150014 = no applications found. Every other failure is an inventory error.
    $result = Invoke-PackageCommand winget @('list','--id',$AppId,'--exact','--accept-source-agreements') -AllowedExitCodes @(0,-1978335212)
    if ($result.ExitCode -eq -1978335212) { return $false }
    if (($result.Output | Out-String) -notmatch [regex]::Escape($AppId)) { throw "Winget inventory did not identify $AppId." }
    return $true
}

function Install-App {
    param([string]$AppId)
    $null = Invoke-PackageCommand winget (@('install','--id',$AppId,'--exact','--source','winget') + $WINGET_FLAGS)
    return $true
}

function Update-App {
    param([string]$AppId)
    # 0x8A15002B = update not applicable; source/installer errors must remain failures.
    $result = Invoke-PackageCommand winget (@('upgrade','--id',$AppId,'--exact') + $WINGET_FLAGS) -AllowedExitCodes @(0,-1978335189)
    if ($result.ExitCode -eq -1978335189) { return 'latest' }
    return 'upgraded'
}

# Core logic

function Sync-Apps {
    param([string[]]$Apps)
    Write-Section 'Apps:'
    Sync-Packages -Names $Apps -Update:$Update `
        -IsInstalled { param($name) Test-AppInstalled $name } `
        -Install { param($name) Install-App $name } `
        -Upgrade { param($name) Update-App $name }
}

# Entry point

function Main {
  Assert-WingetAvailable
  $results = Sync-Apps $APPS
  Write-Summary 'Winget' $results
  if ($results.Failed.Count) { throw "Winget packages failed: $($results.Failed -join ', ')" }
}

Main
