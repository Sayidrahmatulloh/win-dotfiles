# Importing these functions does not install modules.
function Test-PSModuleInstalled {
    param([Parameter(Mandatory)][string]$Name)
    return @(Get-Module -ListAvailable -Name $Name -ErrorAction Stop).Count -gt 0
}

function Install-PSModule {
    param([Parameter(Mandatory)][string]$Name, [string]$Repository = 'PSGallery')
    Install-Module -Name $Name -Repository $Repository -Scope CurrentUser -Force -ErrorAction Stop
    if (-not (Test-PSModuleInstalled -Name $Name)) { throw 'Module not found after installation.' }
    New-InstallResult -Name $Name -Status Installed
}

function Install-PSModules {
    param([Parameter(Mandatory)][string]$RepoRoot, [string]$Repository = 'PSGallery')
    $results = Sync-Packages -Names (Get-PowerShellModules -RepoRoot $RepoRoot) `
        -IsInstalled { param($name) Test-PSModuleInstalled -Name $name } `
        -Install { param($name) Install-PSModule -Name $name -Repository $Repository } `
        -Report { param($entry) Write-InstallResult $entry }
    Complete-InstallResults -Name 'PowerShell modules' -Results $results
}
