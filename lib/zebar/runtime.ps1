# Migrate runtime files and widget links with rollback on failure.
function Initialize-ZebarRuntime {
    param([Parameter(Mandatory)][string]$RepoRoot, [Parameter(Mandatory)][string]$Destination)
    $Destination = [IO.Path]::GetFullPath($Destination)
    $configuration = Get-SetupConfig -RepoRoot $RepoRoot
    $links = @($configuration.links | Where-Object destination -Like '.glzr/zebar/*')
    $files = @(@('config/glzr/zebar/settings.json','settings.json'), @('widgets/zebar/normalize.css','normalize.css'))
    # Validate every source before changing the existing runtime directory.
    foreach ($pair in $files) {
        if (-not (Test-Path -LiteralPath (Join-Path $RepoRoot $pair[0]) -PathType Leaf)) { throw "Runtime source is missing: $($pair[0])" }
    }
    foreach ($link in $links) {
        if (-not (Test-Path -LiteralPath (Join-Path $RepoRoot $link.source) -PathType Container)) { throw "Widget source is missing: $($link.source)" }
        if (($link.destination -replace '\\','/') -ne ('.glzr/zebar/' + (Split-Path $link.destination -Leaf))) { throw 'Widget runtime links must be direct children of the Zebar directory.' }
    }
    $existing = Get-Item -LiteralPath $Destination -Force -ErrorAction SilentlyContinue
    $parentBackup = $null
    $newParent = -not $existing
    $changes = [Collections.Generic.List[object]]::new()
    try {
        if ($existing -and $existing.LinkType -in @('Junction','SymbolicLink')) {
            $parentBackup = $Destination + '.bak_' + [guid]::NewGuid().ToString('N')
            Move-Item -LiteralPath $Destination -Destination $parentBackup -ErrorAction Stop
            $newParent = $true
        }
        New-Item -ItemType Directory -Path $Destination -Force | Out-Null
        foreach ($pair in $files) {
            $source = Join-Path $RepoRoot $pair[0]
            $target = Join-Path $Destination $pair[1]
            if ((Test-Path -LiteralPath $target -PathType Leaf) -and (Get-FileHash $source).Hash -eq (Get-FileHash $target).Hash) { continue }
            $change = [pscustomobject]@{Target=$target; Backup=(Move-ConfigEntryToBackup -Path $target)}
            $changes.Add($change)
            Copy-Item -LiteralPath $source -Destination $target -Force -ErrorAction Stop
        }
        foreach ($link in $links) {
            $source = Join-Path $RepoRoot $link.source
            $target = Join-Path $Destination (Split-Path $link.destination -Leaf)
            if (Test-ConfigLink -Source $source -Destination $target) { continue }
            $change = [pscustomobject]@{Target=$target; Backup=(Move-ConfigEntryToBackup -Path $target)}
            $changes.Add($change)
            New-DirectoryLink -Source $source -Destination $target
        }
    } catch {
        $failure = $_
        try {
            if ($newParent) {
                # Rename the partial directory; never recurse through its widget links.
                if (Get-Item -LiteralPath $Destination -Force -ErrorAction SilentlyContinue) {
                    Move-Item -LiteralPath $Destination -Destination ($Destination + '.failed_' + [guid]::NewGuid().ToString('N')) -ErrorAction Stop
                }
                if ($parentBackup) { Move-Item -LiteralPath $parentBackup -Destination $Destination -ErrorAction Stop }
            } else {
                for ($i = $changes.Count - 1; $i -ge 0; $i--) {
                    $change = $changes[$i]
                    if (Get-Item -LiteralPath $change.Target -Force -ErrorAction SilentlyContinue) {
                        Move-Item -LiteralPath $change.Target -Destination ($change.Target + '.failed_' + [guid]::NewGuid().ToString('N')) -ErrorAction Stop
                    }
                    if ($change.Backup) { Move-Item -LiteralPath $change.Backup -Destination $change.Target -ErrorAction Stop }
                }
            }
        } catch { throw "Zebar migration failed: $($failure.Exception.Message). Rollback failed: $($_.Exception.Message). Parent backup: $parentBackup" }
        throw $failure
    }
    if ($parentBackup) { Write-Warn "Previous Zebar directory link retained: $parentBackup" }
}
