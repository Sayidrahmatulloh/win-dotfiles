# Compatible with Windows PowerShell 5.1.
[CmdletBinding()]
param([string]$DotfilesPath, [string[]]$Only = @(), [string[]]$Skip = @())
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Find-PowerShell7 {
    $command = Get-Command pwsh.exe -ErrorAction SilentlyContinue
    $candidates = @()
    if ($command) { $candidates += $command.Source }
    $candidates += @((Join-Path $env:ProgramFiles 'PowerShell\7\pwsh.exe'), (Join-Path $env:LOCALAPPDATA 'Microsoft\PowerShell\7\pwsh.exe'))
    foreach ($candidate in $candidates | Select-Object -Unique) {
        if (Test-Path -LiteralPath $candidate -PathType Leaf) {
            $version = & $candidate -NoProfile -NonInteractive -Command '$PSVersionTable.PSVersion.Major'
            if ($LASTEXITCODE -eq 0 -and [int]$version -ge 7) { return $candidate }
        }
    }
    return $null
}

function Start-DotfilesSetup {
    if ($Only.Count -and $Skip.Count) { throw 'Use either -Only or -Skip, not both.' }
    $principal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    if ($principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw 'Open a normal PowerShell window. Individual app installers request elevation when needed.'
    }
    $repoAvailable = $PSScriptRoot -and (Test-Path -LiteralPath (Join-Path $PSScriptRoot 'lib\utils.ps1'))
    if ([string]::IsNullOrWhiteSpace($DotfilesPath)) {
        $DotfilesPath = if ($repoAvailable) { $PSScriptRoot } else { Join-Path $env:USERPROFILE 'win-dotfiles' }
    }
    $DotfilesPath = [IO.Path]::GetFullPath($DotfilesPath)
    $pwsh = Find-PowerShell7
    if (-not $pwsh) {
        if (-not (Get-Command winget.exe -ErrorAction SilentlyContinue)) {
            throw 'WinGet was not found. Install or update App Installer from Microsoft Store, reopen PowerShell, and retry.'
        }
        Write-Host 'Installing PowerShell 7 using WinGet...'
        & winget.exe install --id Microsoft.PowerShell --exact --source winget --silent --accept-package-agreements --accept-source-agreements
        if ($LASTEXITCODE -ne 0) { throw "PowerShell installation failed (exit $LASTEXITCODE)." }
        $env:PATH = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User') + ';' + $env:PATH
        $pwsh = Find-PowerShell7
        if (-not $pwsh) { throw 'PowerShell 7 was not found after installation. Reopen your terminal and retry.' }
    } else { Write-Host 'PowerShell 7 is already installed.' }
    $installer = Join-Path $DotfilesPath 'install.ps1'
    $temporaryInstaller = $null
    try {
        if (-not (Test-Path -LiteralPath $installer -PathType Leaf)) {
            $temporaryInstaller = Join-Path $env:TEMP ('win-dotfiles-install-' + [guid]::NewGuid().ToString('N') + '.ps1')
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            Invoke-WebRequest -UseBasicParsing -Uri 'https://raw.githubusercontent.com/Sayidrahmatulloh/win-dotfiles/main/install.ps1' -OutFile $temporaryInstaller
            $installer = $temporaryInstaller
        }
        $childArguments = @('-NoProfile','-ExecutionPolicy','Bypass','-File',$installer,'-DotfilesPath',$DotfilesPath)
        # -File accepts one string for an array parameter; the installer splits commas.
        if ($Only.Count) { $childArguments += @('-Only',($Only -join ',')) }
        if ($Skip.Count) { $childArguments += @('-Skip',($Skip -join ',')) }
        & $pwsh @childArguments
        if ($LASTEXITCODE -ne 0) { throw "Setup has unfinished steps (exit $LASTEXITCODE). Review its log and retry." }
    } finally {
        if ($temporaryInstaller -and (Test-Path -LiteralPath $temporaryInstaller)) { Remove-Item -LiteralPath $temporaryInstaller -Force }
    }
}
Start-DotfilesSetup
