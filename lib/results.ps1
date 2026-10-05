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
  param($A, $B)
  foreach ($key in $A.Keys) {
    if ($B.ContainsKey($key)) {
      foreach ($item in $B[$key]) { $A[$key].Add($item) }
    }
  }
  return $A
}

# ── Step runner: report failures and allow later stages to continue ───────────

function Invoke-Step {
  param([string]$Name, [scriptblock]$Block)
  Write-Stage '*' $Name
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
