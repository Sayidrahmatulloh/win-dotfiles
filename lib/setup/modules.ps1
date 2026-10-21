# Install only missing modules from the shared profile module list.
function Install-PSModules {
    param([Parameter(Mandatory)][string]$RepoRoot)
    $failed = [Collections.Generic.List[string]]::new()
    foreach ($module in (Get-PowerShellModules -RepoRoot $RepoRoot)) {
        if (Get-Module -ListAvailable -Name $module) { Write-Skip "$module already installed"; continue }
        try {
            Install-Module -Name $module -Repository PSGallery -Scope CurrentUser -Force -ErrorAction Stop
            if (-not (Get-Module -ListAvailable -Name $module)) { throw 'Module not found after installation.' }
            Write-Done "installed: $module"
        } catch { $failed.Add($module); Write-Fail "$module : $($_.Exception.Message)" }
    }
    if ($failed.Count) { throw "Modules not installed: $($failed -join ', ')" }
}
