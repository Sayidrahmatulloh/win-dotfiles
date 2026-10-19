# ── Env ───────────────────────────────────────────────────────

$gitSsh = Join-Path $env:SystemRoot 'System32\OpenSSH\ssh.exe'
if (Test-Path $gitSsh) {
  $env:GIT_SSH = $gitSsh
}
else {
  Write-Warning "OpenSSH not found at '$gitSsh'. GIT_SSH not set."
}

$env:CC = 'gcc'
$env:CXX = 'g++'

# ── Aliases ───────────────────────────────────────────────────

Set-Alias -Name vim   -Value nvim
Set-Alias -Name ll    -Value ls
Set-Alias -Name g     -Value git
Set-Alias -Name lg    -Value lazygit
Set-Alias -Name py    -Value python
Set-Alias -Name grep  -Value rg
Set-Alias -Name cs    -Value Clear-System
Set-Alias -Name su    -Value Update-Scoop

# Dynamic git bin path (works on any machine)
$gitCmd = Get-Command 'git' -ErrorAction SilentlyContinue
if ($gitCmd) {
  $gitRoot = Split-Path (Split-Path $gitCmd.Source -Parent) -Parent
  $gitBin = "$gitRoot\usr\bin"
  if (Test-Path $gitBin) {
    Set-Alias -Name tig  -Value "$gitBin\tig.exe"
    Set-Alias -Name less -Value "$gitBin\less.exe"
  }
}
elseif (Test-Path "$env:USERPROFILE\scoop\apps\git\current\usr\bin") {
  $gitBin = "$env:USERPROFILE\scoop\apps\git\current\usr\bin"
  Set-Alias -Name tig  -Value "$gitBin\tig.exe"
  Set-Alias -Name less -Value "$gitBin\less.exe"
}
