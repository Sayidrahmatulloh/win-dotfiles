# File helpers shared by Git, Terminal, setup and doctor.
function New-ConfigBackup {
    param([string]$Path)
    $backup = $Path + '.bak_' + [guid]::NewGuid().ToString('N')
    Copy-Item -LiteralPath $Path -Destination $backup -ErrorAction Stop
    return $backup
}

function Get-TerminalSettingsPath {
    param([string]$LocalAppData)
    $packaged = Join-Path $LocalAppData 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'
    $unpackaged = Join-Path $LocalAppData 'Microsoft\Windows Terminal\settings.json'
    if (Test-Path -LiteralPath $packaged) { return $packaged }
    if (Test-Path -LiteralPath $unpackaged) { return $unpackaged }
    return $packaged
}

function Test-ConfigLink {
    param([string]$Source, [string]$Destination)
    $item = Get-Item -LiteralPath $Destination -Force -ErrorAction SilentlyContinue
    if (-not $item -or $item.LinkType -notin @('Junction', 'SymbolicLink')) { return $false }
    $target = @($item.Target)[0]
    if (-not $target) { return $false }
    if (-not [IO.Path]::IsPathRooted($target)) { $target = Join-Path (Split-Path $Destination -Parent) $target }
    return [IO.Path]::GetFullPath($target).TrimEnd('\') -eq [IO.Path]::GetFullPath($Source).TrimEnd('\')
}
