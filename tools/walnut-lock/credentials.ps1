# Salted credential hashing and per-user encryption. Definitions only.
function Get-CodeHash([string]$Code, [byte[]]$Salt) {
    $derive = [Security.Cryptography.Rfc2898DeriveBytes]::new($Code, $Salt, 100000)
    try { return [Convert]::ToBase64String($derive.GetBytes(32)) } finally { $derive.Dispose() }
}

function Read-Credential {
    param([Parameter(Mandatory=$true)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return $null }
    $bytes = [IO.File]::ReadAllBytes($Path)
    $plain = [Security.Cryptography.ProtectedData]::Unprotect($bytes, $null, [Security.Cryptography.DataProtectionScope]::CurrentUser)
    return [Text.Encoding]::UTF8.GetString($plain) | ConvertFrom-Json
}

function Save-Credential([string]$Code, [string]$Path) {
    $salt = New-Object byte[] 24
    $rng = [Security.Cryptography.RandomNumberGenerator]::Create()
    try { $rng.GetBytes($salt) } finally { $rng.Dispose() }
    $record = @{ salt=[Convert]::ToBase64String($salt); hash=(Get-CodeHash $Code $salt) } | ConvertTo-Json -Compress
    $bytes = [Security.Cryptography.ProtectedData]::Protect([Text.Encoding]::UTF8.GetBytes($record), $null, [Security.Cryptography.DataProtectionScope]::CurrentUser)
    [IO.Directory]::CreateDirectory((Split-Path $Path)) | Out-Null
    [IO.File]::WriteAllBytes($Path, $bytes)
}
