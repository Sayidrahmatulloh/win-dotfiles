# This file is deployed with the GlazeWM configuration directory junction.
$ErrorActionPreference = 'Stop'
$configurationDir = Get-Item -LiteralPath $PSScriptRoot -Force
$realDirectory = if ($configurationDir.Target) { @($configurationDir.Target)[0] } else { $PSScriptRoot }
$repoRoot = [IO.Path]::GetFullPath((Join-Path $realDirectory '../../..'))
$lockScript = Join-Path $repoRoot 'apps/walnut-lock/watch.ps1'
if (-not (Test-Path -LiteralPath $lockScript)) { throw "Walnut lock script missing: $lockScript" }
Start-Process -FilePath 'powershell.exe' -WindowStyle Hidden -ArgumentList @('-NoProfile','-STA','-ExecutionPolicy','Bypass','-WindowStyle','Hidden','-File',('"' + $lockScript + '"'))
