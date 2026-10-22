# winget installation functions. Importing this file performs no installation.
function Assert-WingetAvailable {
  if (-not (Get-Command 'winget' -ErrorAction SilentlyContinue)) {
    Write-Fail 'winget not found. Install App Installer from the Microsoft Store.'
    throw 'Required package manager is not available.'
  }
}

function Test-WingetPackageInstalled {
    param([string]$AppId)
    # 0x8A150014 = no applications found. Every other failure is an inventory error.
    $result = Invoke-PackageCommand winget @('list','--id',$AppId,'--exact','--accept-source-agreements') -AllowedExitCodes @(0,-1978335212)
    if ($result.ExitCode -eq -1978335212) { return $false }
    if (($result.Output | Out-String) -notmatch [regex]::Escape($AppId)) { throw "Winget inventory did not identify $AppId." }
    return $true
}

function Install-WingetPackage {
    param([string]$AppId)
    $null = Invoke-PackageCommand winget (@('install','--id',$AppId,'--exact','--source','winget') + @(Get-WingetAgreementFlags))
    New-InstallResult -Name $AppId -Status Installed
}

function Update-WingetPackage {
    param([string]$AppId)
    # 0x8A15002B = update not applicable; source/installer errors must remain failures.
    $result = Invoke-PackageCommand winget (@('upgrade','--id',$AppId,'--exact') + @(Get-WingetAgreementFlags)) -AllowedExitCodes @(0,-1978335189)
    if ($result.ExitCode -eq -1978335189) { return New-InstallResult -Name $AppId -Status Latest -Message 'up to date' }
    New-InstallResult -Name $AppId -Status Upgraded
}

function Sync-WingetPackages {
    param([string[]]$Apps, [switch]$Update)
    Write-Section 'Apps:'
    Sync-Packages -Names $Apps -Update:$Update `
        -IsInstalled { param($name) Test-WingetPackageInstalled $name } `
        -Install { param($name) Install-WingetPackage $name } `
        -Upgrade { param($name) Update-WingetPackage $name } `
        -Report { param($entry) Write-InstallResult $entry }
}

function Get-WingetAgreementFlags {
    @('--silent', '--accept-package-agreements', '--accept-source-agreements')
}

function Install-WingetApps {
    param([string[]]$Apps, [switch]$Update)
    Assert-WingetAvailable
    $results = Sync-WingetPackages -Apps $Apps -Update:$Update
    Complete-InstallResults -Name 'Winget' -Results $results -FailureLabel 'Winget packages'
}
