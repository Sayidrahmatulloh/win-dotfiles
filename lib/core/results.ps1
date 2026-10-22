# Result records and stage reporting shared by setup scripts.
# ── Result helpers ────────────────────────────────────────────────────────────

function New-Results {
    $results = [pscustomobject]@{ Entries = [Collections.Generic.List[object]]::new() }
    # Read-only views preserve the reporting API without storing duplicate lists.
    foreach ($status in @('Installed', 'Upgraded', 'Latest', 'Failed')) {
        $getter = { return , @($this.Entries | Where-Object Status -eq $status | ForEach-Object Name) }.GetNewClosure()
        $results | Add-Member -MemberType ScriptProperty -Name $status -Value $getter
    }
    return $results
}

function New-InstallResult {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][ValidateSet('Installed', 'Upgraded', 'Latest', 'Failed')][string]$Status,
        [string]$Message = '',
        [string]$BackupPath = '',
        [string]$RollbackError = ''
    )
    [pscustomobject]@{ PSTypeName = 'WinDotfiles.InstallResult'; Name = $Name; Status = $Status; Message = $Message; BackupPath = $BackupPath; RollbackError = $RollbackError }
}

function Add-InstallResult {
    param($Results, $Entry)
    $Results.Entries.Add($Entry)
}

function Merge-Results {
    param([Alias('A')]$Destination, [Alias('B')]$Source)
    foreach ($entry in $Source.Entries) { Add-InstallResult -Results $Destination -Entry $entry }
    return $Destination
}

# A stage reports once and propagates its aggregate failures to the installer.
function Complete-InstallResults {
    param([string]$Name, $Results, [string]$FailureLabel = $Name)
    Write-Summary $Name $Results
    if ($Results.Failed.Count) {
        $failure = [InvalidOperationException]::new("${FailureLabel} failed: $($Results.Failed -join ', ')")
        $failure.Data['InstallResults'] = $Results
        throw $failure
    }
}

# ── Step runner: report failures and allow later stages to continue ───────────

function Invoke-Step {
    param([string]$Name, [scriptblock]$Block)
    $stageIcon = if (Get-Variable -Name 'ICON_UP' -ValueOnly -ErrorAction SilentlyContinue) { $ICON_UP } else { '*' }
    Write-Stage $stageIcon $Name
    try {
        & $Block | Out-Host
        return [pscustomobject]@{ Name = $Name; Success = $true; Message = 'Completed'; Results = $null }
    }
    catch {
        $message = $_.Exception.Message
        Write-Fail "$Name failed: $message"
        return [pscustomobject]@{ Name = $Name; Success = $false; Message = $message; Results = $_.Exception.Data['InstallResults'] }
    }
}
