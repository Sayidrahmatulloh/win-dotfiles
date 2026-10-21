param([string]$RepoRoot = (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent))
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
. "$PSScriptRoot/../support/powershell.ps1"
. "$RepoRoot\lib\core\files.ps1"
. "$RepoRoot\lib\setup\settings.ps1"
Invoke-Expression (Read-Functions 'scripts/install/terminal.ps1')
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('terminal-test-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $fixture | Out-Null
$packaged = Join-Path $fixture 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'
$unpackaged = Join-Path $fixture 'Microsoft\Windows Terminal\settings.json'
Assert-That ((Get-TerminalSettingsPath $fixture) -eq $packaged) 'Fresh setup must select stable packaged Terminal.'
New-Item -ItemType Directory -Path (Split-Path $unpackaged -Parent) -Force | Out-Null
Set-Content -LiteralPath $unpackaged -Value '{"profiles":{}}'
Assert-That ((Get-TerminalSettingsPath $fixture) -eq $unpackaged) 'Unpackaged Terminal was not detected.'
$source = Join-Path $fixture 'source.json'
Set-Content -LiteralPath $source -Value '{"profiles":{"defaults":{"font":{"face":"JetBrainsMono Nerd Font"}}},"schemes":[]}'
Copy-TerminalSettings -Source $source -Destination $packaged
Assert-That ((Get-Content $packaged -Raw) -ceq (Get-Content $source -Raw)) 'Restore changed the source settings.'
Assert-That ((Get-TerminalSettingsPath $fixture) -eq $packaged) 'Stable Terminal must take precedence.'
Copy-TerminalSettings -Source $source -Destination $packaged
Assert-That (@(Get-ChildItem (Split-Path $packaged -Parent) -Filter '*.bak_*').Count -eq 0) 'Identical settings created an unnecessary backup.'
Set-Content -LiteralPath $source -Value '{"profiles":{"list":[]}}'
Copy-TerminalSettings -Source $source -Destination $packaged
$backups = @(Get-ChildItem (Split-Path $packaged -Parent) -Filter '*.bak_*')
Assert-That ($backups.Count -eq 1) 'Changed settings were not backed up.'
Assert-That ((Get-Content $backups[0].FullName -Raw) -match 'JetBrainsMono') 'Backup lost the prior font setting.'
$before = Get-Content $packaged -Raw
Set-Content -LiteralPath $source -Value 'invalid JSON'
$threw = $false
try { Copy-TerminalSettings -Source $source -Destination $packaged } catch { $threw = $true }
Assert-That $threw 'Invalid JSON was accepted.'
Assert-That ((Get-Content $packaged -Raw) -ceq $before) 'Invalid source overwrote working settings.'
Write-Host 'Terminal tests passed.'
$entrySettings = Join-Path $fixture 'entrypoint/settings.json'
& "$RepoRoot/scripts/install/terminal.ps1" -SettingsPath $entrySettings
Assert-That ((Get-FileHash $entrySettings).Hash -eq (Get-FileHash "$RepoRoot/config/terminal/settings.json").Hash) 'Moved Terminal entrypoint did not find the saved settings.'
