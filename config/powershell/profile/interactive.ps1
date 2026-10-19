$configurationDirectory = Split-Path $PSScriptRoot -Parent
# Set PowerShell to UTF-8
[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

# ── Module imports ────────────────────────────────────────────
# Wrapped individually so a missing module doesn't break the entire profile

# Scoop modules live outside PowerShell's default module folders.
$scoopModuleRoot = if ($env:SCOOP) {
  Join-Path $env:SCOOP 'modules'
} else {
  Join-Path $env:USERPROFILE 'scoop/modules'
}
$modulePaths = @($env:PSModulePath -split [IO.Path]::PathSeparator)
if ((Test-Path -LiteralPath $scoopModuleRoot) -and $modulePaths -notcontains $scoopModuleRoot) {
  $env:PSModulePath = ($modulePaths + $scoopModuleRoot) -join [IO.Path]::PathSeparator
}

$modules = @()
try { $modules = Get-Content -LiteralPath (Join-Path $configurationDirectory 'modules.json') -Raw | ConvertFrom-Json -ErrorAction Stop }
catch { Write-Warning "Module list could not be read: $($_.Exception.Message)" }
foreach ($module in $modules) {
  try { Import-Module -Name $module -ErrorAction Stop }
  catch { Write-Warning "Module '$module' could not load: $($_.Exception.Message)" }
}

# Oh My Posh
$omp_config = Join-Path $configurationDirectory "dev.omp.json"
if ((Test-Path $omp_config) -and (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
  oh-my-posh --init --shell pwsh --config $omp_config | Invoke-Expression
}
else {
  Write-Warning "Oh My Posh command or config is unavailable: $omp_config"
}

# PSReadLine
Set-PSReadLineOption -EditMode Vi
Set-PSReadLineOption -BellStyle None
Set-PSReadLineOption -ViModeIndicator Cursor
Set-PSReadLineOption -Colors @{
  Command = '#A6E22E'; Parameter = '#AAB4C2'; Operator = '#CDD3DC'
  Variable = '#CDD3DC'; String = '#F9E2AF'; Number = '#C4A7E7'
  Type = '#89B4FA'; Member = '#CDD3DC'; Comment = '#929DAB'
  Keyword = '#C4A7E7'; Error = '#F38BA8'; Selection = "$([char]27)[48;2;41;51;64m"
  InlinePrediction = '#929DAB'; ListPrediction = '#AAB4C2'
}
Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
if ($Host.UI.SupportsVirtualTerminal) {
  try { Set-PSReadLineOption -PredictionSource History -ErrorAction SilentlyContinue } catch {}
}

# Fzf
$env:FZF_DEFAULT_OPTS = ($env:FZF_DEFAULT_OPTS + ' --color=bg:#0b1015,bg+:#293340,fg:#cdd3dc,fg+:#cdd3dc,hl:#a6e22e,hl+:#a6e22e,info:#aab4c2,prompt:#a6e22e,pointer:#a6e22e,marker:#a6e22e,spinner:#a6e22e,header:#aab4c2,border:#293340').Trim()
if (Get-Command Set-PsFzfOption -ErrorAction SilentlyContinue) {
  Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'
}
