# Separate supervisor: each interval starts after the previous lock closes.
param([ValidateRange(0,600)][int]$InitialDelaySeconds=0, [switch]$CheckOnly)
$ErrorActionPreference='Stop'
$lockScript=Join-Path $PSScriptRoot 'start.ps1'
$powerShell=Join-Path $env:WINDIR 'System32/WindowsPowerShell/v1.0/powershell.exe'
if (-not (Test-Path -LiteralPath $lockScript)) { throw 'Lock script missing.' }
if ($CheckOnly) { Write-Host 'Supervisor paths verified; interval is 600 seconds.'; return }
$created=$false
$supervisorMutex=[Threading.Mutex]::new($false,('Local\WalnutLockSupervisor-'+$env:USERNAME),[ref]$created)
if (-not $created) { $supervisorMutex.Dispose(); return }
try {
    if ($InitialDelaySeconds) { Start-Sleep -Seconds $InitialDelaySeconds }
    $firstRun=$true
    while ($true) {
        $arguments=@('-NoProfile','-STA','-ExecutionPolicy','Bypass','-WindowStyle','Hidden','-File',('"'+$lockScript+'"'))
        if ($firstRun) { $arguments += @('-StartupDelaySeconds','5'); $firstRun=$false }
        $child=Start-Process -FilePath $powerShell -ArgumentList $arguments -WindowStyle Hidden -PassThru
        $child.WaitForExit()
        $child.Dispose()
        Start-Sleep -Seconds 600
    }
} finally { $supervisorMutex.Dispose() }
