# Maintenance commands run only when explicitly invoked.
function Clear-System {
  $isAdmin = ([Security.Principal.WindowsPrincipal] `
      [Security.Principal.WindowsIdentity]::GetCurrent() `
  ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

  Write-Host "`nCleaning system..." -ForegroundColor Cyan

  Write-Host 'Temp files...' -NoNewline
  $tempPaths = @("$env:TEMP\*", "$env:LOCALAPPDATA\Temp\*")
  # C:\Windows\Temp requires admin — only include when elevated
  if ($isAdmin) { $tempPaths += 'C:\Windows\Temp\*' }
  $cleanupErrors = @()
  Remove-Item $tempPaths -Recurse -Force -ErrorAction SilentlyContinue -ErrorVariable +cleanupErrors
  if ($cleanupErrors.Count) {
    Write-Host " partial ($($cleanupErrors.Count) errors; some files could not be removed)" -ForegroundColor Yellow
  } else { Write-Host ' done' -ForegroundColor Green }

  Write-Host 'Recycle Bin...' -NoNewline
  try { Clear-RecycleBin -Force -ErrorAction Stop; Write-Host ' done' -ForegroundColor Green }
  catch { Write-Host ' failed' -ForegroundColor Yellow }

  if ($isAdmin) {
    Write-Host 'Disk Cleanup...' -NoNewline
    try { Start-Process 'cleanmgr.exe' -ArgumentList '/sagerun:1' -Wait -NoNewWindow; Write-Host ' done' -ForegroundColor Green }
    catch { Write-Host ' failed' -ForegroundColor Yellow }
  }
  else {
    Write-Host 'Disk Cleanup skipped (requires admin).' -ForegroundColor DarkGray
  }

  Write-Host "`nDone!" -ForegroundColor Green
}

function Update-Scoop {
  try {
    $PSNativeCommandUseErrorActionPreference = $false
    foreach ($arguments in @(@('update','*'), @('cleanup','*'), @('cache','rm','*'))) {
      $global:LASTEXITCODE = 0
      & scoop @arguments
      if ($LASTEXITCODE -ne 0) { throw "scoop $($arguments -join ' ') failed (exit $LASTEXITCODE). Later cleanup steps were skipped." }
    }
    Write-Host 'Scoop update and cleanup completed.' -ForegroundColor Green
  } catch { Write-Error $_ -ErrorAction Continue }
}
