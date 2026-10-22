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

function Assert-SetupConfig {
    param($Configuration)
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
        if ($link.root -notin @('USERPROFILE','LOCALAPPDATA','APPDATA')) { throw 'Link root must be USERPROFILE, LOCALAPPDATA or APPDATA.' }
        Assert-RelativeConfigPath $link.source 'links.source'
        Assert-RelativeConfigPath $link.destination 'links.destination'
    }
    foreach ($key in @('widget','fontPackage','fontFile')) {
        $null = Get-ConfigProperty $configuration.zebar $key
        Assert-RelativeConfigPath $configuration.zebar.$key "zebar.$key"
    }
}

function Get-SetupConfig {
    param([string]$RepoRoot)
    $configuration = Get-Content -LiteralPath (Join-Path $RepoRoot 'setup.json') -Raw | ConvertFrom-Json
    Assert-SetupConfig -Configuration $configuration
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
# Check the selected build, runtime startup and deployed widget link together.
function Assert-ZebarConfiguration {
    param([Parameter(Mandatory)][string]$RepoRoot, $Configuration = (Get-SetupConfig -RepoRoot $RepoRoot), [string]$SettingsPath)
    $widgetPath = $Configuration.zebar.widget
    $pack = Split-Path $widgetPath -Leaf
    $manifest = Get-Content (Join-Path $RepoRoot "$widgetPath/zpack.json") -Raw | ConvertFrom-Json
    if (-not $SettingsPath) { $SettingsPath = Join-Path $RepoRoot 'config/glzr/zebar/settings.json' }
    $settings = Get-Content -LiteralPath $SettingsPath -Raw | ConvertFrom-Json
    $startup = @($settings.startupConfigs | Where-Object pack -EQ $pack)
    if (-not $startup.Count) { throw "Zebar startupConfigs must select configured widget: $pack" }
    foreach ($entry in $startup) {
        $widget = @($manifest.widgets | Where-Object name -EQ $entry.widget)
        if ($widget.Count -ne 1) { throw "Zebar startup widget is missing from zpack.json: $($entry.widget)" }
        if ($entry.preset -notin @($widget[0].presets.name)) { throw "Zebar startup preset is missing from zpack.json: $($entry.preset)" }
    }
    $link = @($Configuration.links | Where-Object { $_.source -eq $widgetPath -and $_.root -eq 'USERPROFILE' -and $_.destination -eq ".glzr/zebar/$pack" })
    if ($link.Count -ne 1) { throw "Zebar selected widget must have one matching runtime link: $pack" }
}
