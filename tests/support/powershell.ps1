# Tests load function definitions without executing installer entry points.
function Read-Functions {
    param([string]$RelativePath)
    $tokens = $null
    $errors = $null
    $path = Join-Path $RepoRoot $RelativePath
    $ast = [Management.Automation.Language.Parser]::ParseFile($path, [ref]$tokens, [ref]$errors)
    if ($errors.Count) { throw ($errors | Out-String) }
    $definitions = $ast.EndBlock.Statements | Where-Object {
        $_ -is [Management.Automation.Language.FunctionDefinitionAst]
    } | ForEach-Object { $_.Extent.Text }
    return $definitions -join "`n"
}

function Assert-That {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
}
