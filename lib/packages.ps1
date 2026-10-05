# One install/update loop for Scoop tools, Winget apps and Scoop fonts.
# Adapters provide only manager-specific commands; results and errors are shared.
function Sync-Packages {
    param(
        [string[]]$Names,
        [scriptblock]$IsInstalled,
        [scriptblock]$Install,
        [scriptblock]$Upgrade,
        [switch]$Update
    )
    $results = New-Results
    $index = 0
    foreach ($name in $Names) {
        $index++
        try {
            if (& $IsInstalled $name) {
                if (-not $Update) {
                    Write-Skip "already installed: $name"
                    $results.Latest.Add($name)
                    continue
                }
                Write-Step "[$index/$($Names.Count)]" $name 'upgrading'
                $status = & $Upgrade $name
                switch ($status) {
                    'upgraded' { Write-Done "upgraded: $name"; $results.Upgraded.Add($name) }
                    'latest' { Write-Skip "up to date: $name"; $results.Latest.Add($name) }
                    default { throw "Upgrade failed: $name" }
                }
            } else {
                Write-Step "[$index/$($Names.Count)]" $name 'installing'
                if (-not (& $Install $name)) { throw "Install failed: $name" }
                Write-Done "installed: $name"
                $results.Installed.Add($name)
            }
        } catch {
            Write-Fail "$name : $($_.Exception.Message)"
            $results.Failed.Add($name)
        }
    }
    return $results
}
