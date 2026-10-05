# Read data shared by setup and doctor. Loading this file changes nothing.
function Assert-ConfigList {
    param($Value, [string]$Name)
    if ($Value -isnot [array]) { throw "$Name must be a JSON array." }
    foreach ($item in $Value) {
        if ($item -isnot [string] -or [string]::IsNullOrWhiteSpace($item)) { throw "$Name must contain non-empty strings." }
    }
    if (@($Value | Group-Object | Where-Object Count -gt 1).Count) { throw "$Name contains duplicate entries." }
}

function Get-ConfigProperty {
    param($Object, [string]$Name)
    $property = $Object.PSObject.Properties[$Name]
    if (-not $property -or $null -eq $property.Value) { throw "Missing required configuration field: $Name" }
    return $property.Value
}

function Assert-RelativeConfigPath {
    param($Value, [string]$Name)
    if ($Value -isnot [string] -or [string]::IsNullOrWhiteSpace($Value) -or [IO.Path]::IsPathRooted($Value) -or ($Value -split '[/\\]') -contains '..') {
        throw "$Name must be a non-empty relative path without '..'."
    }
}

function Get-SetupConfig {
    param([string]$RepoRoot)
    $configuration = Get-Content -LiteralPath (Join-Path $RepoRoot 'setup.json') -Raw | ConvertFrom-Json
    foreach ($key in @('scoop','winget','links','requiredCommands','zebar')) { $null = Get-ConfigProperty $configuration $key }
    foreach ($key in @('buckets','packages','fonts')) {
        $null = Get-ConfigProperty $configuration.scoop $key
        Assert-ConfigList -Value $configuration.scoop.$key -Name "scoop.$key"
    }
    Assert-ConfigList $configuration.winget 'winget'
    Assert-ConfigList $configuration.requiredCommands 'requiredCommands'
    if ($configuration.links -isnot [array]) { throw 'links must be a JSON array.' }
    foreach ($link in $configuration.links) {
        foreach ($key in @('source','root','destination')) { $null = Get-ConfigProperty $link $key }
        if ($link.root -notin @('USERPROFILE','LOCALAPPDATA')) { throw 'Link root must be USERPROFILE or LOCALAPPDATA.' }
        Assert-RelativeConfigPath $link.source 'links.source'
        Assert-RelativeConfigPath $link.destination 'links.destination'
    }
    foreach ($key in @('widget','fontPackage','fontFile')) {
        $null = Get-ConfigProperty $configuration.zebar $key
        Assert-RelativeConfigPath $configuration.zebar.$key "zebar.$key"
    }
    return $configuration
}

function Get-PowerShellModules {
    param([string]$RepoRoot)
    $text = Get-Content -LiteralPath (Join-Path $RepoRoot 'config/powershell/modules.json') -Raw
    # A wrapper preserves an array with zero or one item in both PowerShell 5.1 and 7.
    $data = ('{"items":' + $text + '}') | ConvertFrom-Json
    Assert-ConfigList $data.items 'PowerShell modules'
    return $data.items
}

function Get-ConfigLinks {
    param([string]$RepoRoot, $Configuration)
    foreach ($link in $Configuration.links) {
        $root = [Environment]::GetEnvironmentVariable($link.root)
        if (-not $root) { throw "Environment variable is missing: $($link.root)" }
        @{
            Src = Join-Path $RepoRoot $link.source
            Dst = Join-Path $root $link.destination
        }
    }
}

function Get-PowerShellProfileLine {
    return '. $env:USERPROFILE\.config\powershell\user_profile.ps1'
}
