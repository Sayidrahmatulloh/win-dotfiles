# Capture output and native exit codes together so failures remain visible in logs.
function Invoke-PackageCommand {
    param([string]$Command, [string[]]$Arguments, [int[]]$AllowedExitCodes = @(0))
    $PSNativeCommandUseErrorActionPreference = $false
    $global:LASTEXITCODE = 0
    try { $output = @(& $Command @Arguments *>&1) }
    catch { throw "$Command $($Arguments -join ' ') failed: $($_.Exception.Message)" }
    $exitCode = $LASTEXITCODE
    if ($exitCode -notin $AllowedExitCodes) {
        throw "$Command $($Arguments -join ' ') failed (exit $exitCode):`n$($output | Out-String)"
    }
    [pscustomobject]@{ ExitCode = $exitCode; Output = $output }
}
