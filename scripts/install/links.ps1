# Link application configs and register the PowerShell profile.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/../../lib/setup/links.ps1"

. "$PSScriptRoot/../../lib/utils.ps1"
. "$PSScriptRoot/../../lib/setup.ps1"

# ── Constants ──────────────────────────────────────────────────────────────────

$DOTFILES = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$PROFILE_PATH = if ($PROFILE -and (Test-Path (Split-Path $PROFILE -Parent))) {
  $PROFILE
} elseif ($PROFILE.CurrentUserCurrentHost) {
  $PROFILE.CurrentUserCurrentHost
} else {
  "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
}
Install-ConfigLinks -RepoRoot $DOTFILES -ProfilePath $PROFILE_PATH
