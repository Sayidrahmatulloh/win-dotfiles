# One install/update loop for Scoop tools, Winget apps and Scoop fonts.
# Adapters return install records or throw. Presentation is supplied by the caller.
function Assert-PackageResult {
    param($Result, [string]$Name, [string[]]$AllowedStatuses)
    if ($null -eq $Result -or $Result -is [array] -or
        $Result.PSObject.TypeNames -notcontains 'WinDotfiles.InstallResult' -or
        $Result.Name -cne $Name -or $Result.Status -notin $AllowedStatuses) {
        throw "Invalid package result for $Name. Expected: $($AllowedStatuses -join ', ')."
    }
}

function Sync-Packages {
    param(
        [string[]]$Names,
        [scriptblock]$IsInstalled,
        [scriptblock]$Install,
        [scriptblock]$Upgrade,
        [switch]$Update,
        [scriptblock]$Report
    )
    $results = New-Results
    foreach ($name in $Names) {
        try {
            $installed = & $IsInstalled $name
            if ($installed -isnot [bool]) { throw "Invalid inventory result for $name. Expected a boolean." }
            if (-not $installed) {
                $entry = & $Install $name
                Assert-PackageResult -Result $entry -Name $name -AllowedStatuses Installed
            } elseif (-not $Update) {
                $entry = New-InstallResult -Name $name -Status Latest -Message 'already installed'
            } else {
                $entry = & $Upgrade $name
                Assert-PackageResult -Result $entry -Name $name -AllowedStatuses Upgraded,Latest
            }
        } catch {
            $entry = New-InstallResult -Name $name -Status Failed -Message $_.Exception.Message
        }
        Add-InstallResult -Results $results -Entry $entry
        if ($Report) { & $Report $entry | Out-Null }
    }
    return $results
}
