param([string]$RepoRoot = (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent))
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/../support/powershell.ps1"

foreach ($directory in @('lib/core', 'lib/setup', 'lib/zebar', 'scripts/install', 'scripts/theme', 'apps/walnut-lock',
    'tests/powershell', 'tests/neovim', 'tests/support', 'docs/history')) {
    Assert-That (Test-Path -LiteralPath (Join-Path $RepoRoot $directory) -PathType Container) "Missing architecture directory: $directory"
}
$flatSuites = @(Get-ChildItem -LiteralPath (Join-Path $RepoRoot 'tests') -File |
    Where-Object { $_.Extension -eq '.lua' -or ($_.Extension -eq '.ps1' -and $_.Name -ne 'run.ps1') })
Assert-That ($flatSuites.Count -eq 0) 'Place test suites under powershell/ or neovim/, and support code under support/.'

# Catch documentation links left pointing to old locations after folder moves.
$documents = @(Get-ChildItem -LiteralPath (Join-Path $RepoRoot 'docs') -Recurse -Filter '*.md' -File)
$documents += Get-Item -LiteralPath (Join-Path $RepoRoot 'README.md'), (Join-Path $RepoRoot 'CONTRIBUTING.md')
$documents += Get-ChildItem -LiteralPath (Join-Path $RepoRoot 'apps'), (Join-Path $RepoRoot 'tools') -Recurse -Filter '*.md' -File
foreach ($document in $documents) {
    $content = Get-Content -LiteralPath $document.FullName -Raw
    foreach ($link in [regex]::Matches($content, '\[[^\]]*\]\(([^)]+)\)')) {
        $target = $link.Groups[1].Value
        if ($target -match '^(https?://|mailto:|#)') { continue }
        $target = ($target -split '#', 2)[0]
        Assert-That (Test-Path -LiteralPath (Join-Path $document.DirectoryName $target)) "Broken link in $($document.Name): $target"
    }
}

# Resolve authored dot-source imports without executing installers or applications.
$sources = @(Get-ChildItem -LiteralPath $RepoRoot -Filter '*.ps1' -File)
foreach ($directory in @('lib', 'scripts', 'tools', 'apps', 'config/powershell', 'tests')) {
    $sources += Get-ChildItem -LiteralPath (Join-Path $RepoRoot $directory) -Filter '*.ps1' -File -Recurse
}
$sources += Get-Item -LiteralPath (Join-Path $RepoRoot 'config/symlinks.ps1')
foreach ($source in $sources) {
    $tokens = $null; $errors = $null
    $ast = [Management.Automation.Language.Parser]::ParseFile($source.FullName, [ref]$tokens, [ref]$errors)
    Assert-That ($errors.Count -eq 0) "Invalid PowerShell source: $($source.FullName)"
    foreach ($command in $ast.FindAll({
        param($node)
        $node -is [Management.Automation.Language.CommandAst] -and
            $node.InvocationOperator -eq [Management.Automation.Language.TokenKind]::Dot
    }, $true)) {
        $target = $command.CommandElements[0]
        if ($target -isnot [Management.Automation.Language.StringConstantExpressionAst] -and
            $target -isnot [Management.Automation.Language.ExpandableStringExpressionAst]) { continue }
        $path = $target.Value
        if ($path -notmatch '^\$(PSScriptRoot|RepoRoot)[/\\]') { continue }
        $path = $path -ireplace '\$PSScriptRoot', $source.DirectoryName.Replace('$', '$$')
        $path = $path -ireplace '\$RepoRoot', $RepoRoot.Replace('$', '$$')
        if ($path.Contains('$')) { continue } # A deliberately dynamic import.
        Assert-That (Test-Path -LiteralPath $path -PathType Leaf) "Missing import in $($source.FullName): $path"
    }
}

# Public library loaders stay compatible and must not start setup on import.
. "$RepoRoot/lib/utils.ps1"
. "$RepoRoot/lib/setup.ps1"
foreach ($function in @('Get-SetupConfig', 'Invoke-PackageCommand', 'Sync-Packages', 'Invoke-Step',
    'New-ConfigBackup', 'Install-PSModules', 'Assert-ZebarDesktopAssets', 'Build-Zebar', 'Initialize-ZebarRuntime')) {
    Assert-That ($null -ne (Get-Command $function -CommandType Function -ErrorAction SilentlyContinue)) "Missing helper: $function"
}
$wrapper = Get-Content -LiteralPath (Join-Path $RepoRoot 'config/symlinks.ps1') -Raw
Assert-That ($wrapper -match 'scripts/install/links\.ps1') 'Legacy symlink entry no longer forwards to its installation stage.'
# Domain files can be imported directly; they must contain no entry-point work.
foreach ($name in @('scoop', 'winget', 'fonts', 'links', 'git', 'terminal', 'stages')) {
    $path = Join-Path $RepoRoot "lib/setup/$name.ps1"
    $tokens = $null; $errors = $null
    $ast = [Management.Automation.Language.Parser]::ParseFile($path, [ref]$tokens, [ref]$errors)
    $work = @($ast.EndBlock.Statements | Where-Object { $_ -isnot [Management.Automation.Language.FunctionDefinitionAst] })
    Assert-That ($work.Count -eq 0) "Importing $name can perform setup work. Keep only function definitions in domain libraries."
}
foreach ($source in Get-ChildItem -LiteralPath (Join-Path $RepoRoot 'lib') -Recurse -Filter '*.ps1' -File) {
    $content = Get-Content -LiteralPath $source.FullName -Raw
    Assert-That ($content -notmatch '(?i)\$(?:RepoRoot|PSScriptRoot)[/\\](?:\.\.[/\\])*tools[/\\]') "Library depends on developer tools: $($source.Name)"
}
Write-Host 'Architecture: PowerShell imports resolve, library entry points load, and legacy link command forwards correctly.'
