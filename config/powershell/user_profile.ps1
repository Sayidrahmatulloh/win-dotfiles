# Profile entry point; load each responsibility in a visible, fixed order.
. "$PSScriptRoot/profile/interactive.ps1"
. "$PSScriptRoot/profile/environment.ps1"
. "$PSScriptRoot/profile/development.ps1"
. "$PSScriptRoot/profile/maintenance.ps1"
