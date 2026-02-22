# ============================================================
#  config/powershell/user_profile.ps1
# ============================================================

# Set PowerShell to UTF-8
[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

Import-Module posh-git

# Oh My Posh
$omp_config = Join-Path $PSScriptRoot "dev.omp.json"
oh-my-posh --init --shell pwsh --config $omp_config | Invoke-Expression

Import-Module -Name Terminal-Icons
Import-Module -Name Microsoft.WinGet.CommandNotFound

# PSReadLine
Set-PSReadLineOption -EditMode Vi
Set-PSReadLineOption -BellStyle None
Set-PSReadLineOption -ViModeIndicator Cursor
Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
Set-PSReadLineOption -PredictionSource History

# Fzf
Import-Module PSFzf
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'

# Env
$env:GIT_SSH = "C:\Windows\system32\OpenSSH\ssh.exe"
$env:CC  = "gcc"
$env:CXX = "clang"

# Aliases
Set-Alias -Name vim -Value nvim
Set-Alias ll       ls
Set-Alias g        git
Set-Alias lg       lazygit
Set-Alias py       python
Set-Alias grep     rg
Set-Alias cs       Clear-System
Set-Alias su       Update-Scoop

# Dynamic git bin path (works on any machine)
$gitBin = "$env:USERPROFILE\scoop\apps\git\current\usr\bin"
if (Test-Path $gitBin) {
    Set-Alias tig  "$gitBin\tig.exe"
    Set-Alias less "$gitBin\less.exe"
}

# ── Functions ────────────────────────────────────────────────

function which {
    param([Parameter(Mandatory)] [string] $command)
    Get-Command -Name $command -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

function Start-Neovide { neovide --frame none @args }

function Invoke-Cpp {
    param([Parameter(Mandatory)] [string] $cppFilePath)
    if (-not (Test-Path $cppFilePath)) { Write-Error "Error: '$cppFilePath' not found."; return }
    $exe = [IO.Path]::ChangeExtension($cppFilePath, ".exe")
    $out = & g++ "$cppFilePath" -o "$exe" 2>&1
    if ($LastExitCode -ne 0) { Write-Error "Compilation failed:`n$out"; return }
    Write-Host "Compilation successful. Running '$exe'..."
    & $exe
    Remove-Item $exe -Force
}

function Invoke-Zig {
    param([Parameter(Mandatory)] [string] $zigFilePath)
    if (-not (Test-Path $zigFilePath)) { Write-Error "Error: '$zigFilePath' not found."; return }
    $exe    = [IO.Path]::ChangeExtension($zigFilePath, ".exe")
    $exeObj = [IO.Path]::ChangeExtension($zigFilePath, ".exe.obj")
    $pdb    = [IO.Path]::ChangeExtension($zigFilePath, ".pdb")
    $out = & zig build-exe "$zigFilePath" 2>&1
    if ($LastExitCode -ne 0) { Write-Error "Compilation failed:`n$out"; return }
    Write-Host "Compilation successful. Running '$exe'..."
    & $exe
    Remove-Item $exe, $exeObj, $pdb -Force
}

function Invoke-Swift {
    param([string] $appName = "app")
    $out = & swift build
    if ($LastExitCode -ne 0) { Write-Error "Compilation failed:`n$out"; return }
    Write-Host "Compilation successful. Running '$appName'..."
    & "./.build/debug/$appName"
}

function Get-NpmPackageVersion {
    param([Parameter(Mandatory)] [string] $PackageName)
    try {
        $r = Invoke-RestMethod -Uri "https://registry.npmjs.org/$PackageName/latest" -Method Get -ErrorAction Stop
        if ($r.version) { Write-Host "Package: $PackageName`nLatest Version: $($r.version)" }
        else { Write-Host "Version not found." }
    } catch { Write-Host "Error: '$PackageName' not found or network issue." }
}

function Clear-System {
    Write-Host "`nCleaning system..." -ForegroundColor Cyan
    Write-Host "Temp files..." -NoNewline
    try {
        Remove-Item "$env:TEMP\*", "$env:LOCALAPPDATA\Temp\*", "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host " done" -ForegroundColor Green
    } catch { Write-Host " partial" -ForegroundColor Yellow }
    Write-Host "Recycle Bin..." -NoNewline
    try { Clear-RecycleBin -Force -ErrorAction SilentlyContinue; Write-Host " done" -ForegroundColor Green }
    catch { Write-Host " failed" -ForegroundColor Yellow }
    Write-Host "Disk Cleanup..." -NoNewline
    try { Start-Process "cleanmgr.exe" -ArgumentList "/sagerun:1" -Wait -NoNewWindow; Write-Host " done" -ForegroundColor Green }
    catch { Write-Host " failed" -ForegroundColor Yellow }
    Write-Host "`nDone!" -ForegroundColor Green
}

function Connect-Bandit {
    param([Parameter(Mandatory)] [int] $Level)
    $cmd = "ssh bandit$Level@bandit.labs.overthewire.org -p 2220"
    Write-Host "Connecting to Bandit Level $Level..." -ForegroundColor Cyan
    Write-Host "$cmd" -ForegroundColor Yellow
    Invoke-Expression $cmd
}

function Update-Scoop {
    try {
        Write-Host "`nUpdating packages..."     -ForegroundColor Yellow; scoop update -a
        Write-Host "`nCleaning old versions..." -ForegroundColor Yellow; scoop cleanup *
        Write-Host "`nClearing cache..."        -ForegroundColor Yellow; scoop cache rm *
        Write-Host "`nDone!" -ForegroundColor Green
    } catch { Write-Host "`nError: $($_.Exception.Message)" -ForegroundColor Red }
}
