# Interactive development commands. Definitions only.
function which {
  param([Parameter(Mandatory)] [string] $command)
  Get-Command -Name $command -ErrorAction SilentlyContinue |
  Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

function Start-Neovide { neovide --frame none @args }

function New-TempBuildDirectory {
  $path = Join-Path ([IO.Path]::GetTempPath()) ('dotfiles-build-' + [guid]::NewGuid().ToString('N'))
  New-Item -ItemType Directory -Path $path | Out-Null
  return $path
}

function Remove-TempBuildDirectory {
  param([string]$Path)
  $resolved = [IO.Path]::GetFullPath($Path)
  $root = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\')
  if (-not $resolved.StartsWith($root + '\', [StringComparison]::OrdinalIgnoreCase) -or (Split-Path $resolved -Leaf) -notlike 'dotfiles-build-*') {
    throw 'Build directory is outside the expected temporary location.'
  }
  if (Test-Path -LiteralPath $resolved) { Remove-Item -LiteralPath $resolved -Recurse -Force }
}

function Invoke-Cpp {
  param([Parameter(Mandatory)] [string] $cppFilePath)
  $source = (Resolve-Path -LiteralPath $cppFilePath -ErrorAction Stop).Path
  $directory = New-TempBuildDirectory
  $exe = Join-Path $directory 'program.exe'
  try {
    $out = & g++ $source -o $exe 2>&1
    if ($LASTEXITCODE -ne 0) { Write-Error "Compilation failed:`n$out"; return }
    & $exe
  } finally { Remove-TempBuildDirectory $directory }
}

function Invoke-Zig {
  param([Parameter(Mandatory)] [string] $zigFilePath)
  $source = (Resolve-Path -LiteralPath $zigFilePath -ErrorAction Stop).Path
  $directory = New-TempBuildDirectory
  $exe = Join-Path $directory 'program.exe'
  try {
    $out = & zig build-exe $source "-femit-bin=$exe" 2>&1
    if ($LASTEXITCODE -ne 0) { Write-Error "Compilation failed:`n$out"; return }
    & $exe
  } finally { Remove-TempBuildDirectory $directory }
}

function Invoke-Swift {
  param([string] $appName = 'app')
  # Capture both stdout and stderr so the error message is actually useful
  $out = & swift build 2>&1
  if ($LASTEXITCODE -ne 0) { Write-Error "Compilation failed:`n$out"; return }
  Write-Host "Compilation successful. Running '$appName'..."
  & "./.build/debug/$appName"
}

function Get-NpmPackageVersion {
  param([Parameter(Mandatory)] [string] $PackageName)
  try {
    $r = Invoke-RestMethod -Uri "https://registry.npmjs.org/$PackageName/latest" -Method Get -ErrorAction Stop
    if ($r.version) { Write-Host "Package: $PackageName`nLatest Version: $($r.version)" }
    else { Write-Host 'Version not found.' }
  }
  catch { Write-Host "Error: '$PackageName' not found or network issue." }
}

function Connect-Bandit {
  param([Parameter(Mandatory)] [int] $Level)
  $user = "bandit$Level"
  $server = 'bandit.labs.overthewire.org'
  $port = 2220
  Write-Host "Connecting to Bandit Level $Level..." -ForegroundColor Cyan
  Write-Host "ssh $user@$server -p $port" -ForegroundColor Yellow
  # Direct call instead of Invoke-Expression — avoids injection risk
  & ssh "$user@$server" -p $port
}
