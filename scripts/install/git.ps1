[CmdletBinding()]
param([string]$GlobalConfigPath)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot\..\..\lib\files.ps1"

function Install-GitConfig {
    param([string]$Source, [string]$Destination)
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw 'Git is missing. Run bootstrap.ps1 first.' }
    if (-not (Test-Path -LiteralPath $Source -PathType Leaf)) { throw "Shared Git config is missing: $Source" }
    $null = & git config --file $Source --list
    if ($LASTEXITCODE -ne 0) { throw 'Shared Git configuration is invalid.' }
    $sourcePath = [IO.Path]::GetFullPath($Source).Replace('\','/')
    if (Test-Path -LiteralPath $Destination) {
        $includes = @(& git config --file $Destination --get-all include.path)
        if ($LASTEXITCODE -notin @(0,1)) { throw "Cannot read Git config: $Destination" }
        foreach ($include in $includes) {
            $candidate = $include
            if ($candidate.StartsWith('~/')) { $candidate = Join-Path $env:USERPROFILE $candidate.Substring(2) }
            elseif (-not [IO.Path]::IsPathRooted($candidate)) { $candidate = Join-Path (Split-Path $Destination -Parent) $candidate }
            if ([IO.Path]::GetFullPath($candidate).Replace('\','/') -eq $sourcePath) {
                Write-Host 'Shared Git configuration is already included.'
                return
            }
        }
        $backup = New-ConfigBackup -Path $Destination
        Write-Host "Git config backup: $backup"
    }
    New-Item -ItemType Directory -Path (Split-Path $Destination -Parent) -Force | Out-Null
    & git config --file $Destination --add include.path $sourcePath
    if ($LASTEXITCODE -ne 0) { throw "Could not include shared Git configuration in $Destination" }
    Write-Host "Shared Git configuration included: $sourcePath"
}

if (-not $GlobalConfigPath) {
    $GlobalConfigPath = if ($env:GIT_CONFIG_GLOBAL) { $env:GIT_CONFIG_GLOBAL } else { Join-Path $env:USERPROFILE '.gitconfig' }
}
Install-GitConfig -Source (Join-Path $PSScriptRoot '../../config/git/gitconfig') -Destination ([IO.Path]::GetFullPath($GlobalConfigPath))
