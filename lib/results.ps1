# Result records and stage reporting shared by setup scripts.
# ── Result helpers ────────────────────────────────────────────────────────────

function New-Results {
  return @{
    Installed = [System.Collections.Generic.List[string]]::new()
    Upgraded  = [System.Collections.Generic.List[string]]::new()
    Latest    = [System.Collections.Generic.List[string]]::new()
    Failed    = [System.Collections.Generic.List[string]]::new()
  }
}

function Merge-Results {
  param([Alias('A')]$Destination, [Alias('B')]$Source)
  foreach ($key in $Destination.Keys) {
    if ($Source.ContainsKey($key)) {
      foreach ($item in $Source[$key]) { $Destination[$key].Add($item) }
    }
  }
  return $Destination
}

# ── Step runner: report failures and allow later stages to continue ───────────

function Invoke-Step {
  param([string]$Name, [scriptblock]$Block)
  $stageIcon = if (Get-Variable -Name 'ICON_UP' -ValueOnly -ErrorAction SilentlyContinue) { $ICON_UP } else { '*' }
  Write-Stage $stageIcon $Name
  try {
    & $Block | Out-Host
    return [pscustomobject]@{ Name = $Name; Success = $true; Message = 'Completed' }
  }
  catch {
    $message = $_.Exception.Message
    Write-Fail "$Name failed: $message"
    return [pscustomobject]@{ Name = $Name; Success = $false; Message = $message }
  }
}
