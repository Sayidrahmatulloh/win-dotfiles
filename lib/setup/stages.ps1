# Post-clone stage validation and execution.
function Assert-SetupStageConfiguration {
    param([string]$RepoRoot, [string[]]$StageIds)
    $null = Get-SetupConfig -RepoRoot $RepoRoot
    if ('Zebar' -in $StageIds -or 'Symlinks' -in $StageIds) { Assert-ZebarConfiguration -RepoRoot $RepoRoot }
    if ('Modules' -in $StageIds) { $null = Get-PowerShellModules -RepoRoot $RepoRoot }
    if ('Cursors' -in $StageIds -or 'Zebar' -in $StageIds) {
        . "$RepoRoot/scripts/theme/ThemeConfig.ps1"
        $null = Get-ThemeCatalog -Root $RepoRoot
    }
}

function Invoke-SetupStages {
    param([object[]]$Stages, [Parameter(Mandatory)][scriptblock]$RefreshEnvironment)
    foreach ($stage in $Stages) {
        Invoke-Step -Name $stage.Name -Block { & $stage.Action $stage.RepoRoot }
        if ($stage.Id -in @('Scoop', 'Winget')) { & $RefreshEnvironment }
    }
}
