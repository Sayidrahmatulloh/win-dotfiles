param(
    [Parameter(Mandatory=$true)]
    [string]$Theme,
    [string]$ConfigPath = (Join-Path $env:USERPROFILE '.glzr/glazewm/config.yaml')
)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'ThemeConfig.ps1')
. (Join-Path $PSScriptRoot 'SetWallpaper.ps1')
. (Join-Path $PSScriptRoot 'SetCursor.ps1')
function Reload-GlazeConfig {
    $socket = [Net.WebSockets.ClientWebSocket]::new()
    $timeout = [Threading.CancellationTokenSource]::new(10000)
    try {
        $socket.ConnectAsync([Uri]'ws://127.0.0.1:6123', $timeout.Token).GetAwaiter().GetResult() | Out-Null
        $command = 'command wm-reload-config'
        $bytes = [Text.Encoding]::UTF8.GetBytes($command)
        $socket.SendAsync([ArraySegment[byte]]::new($bytes), [Net.WebSockets.WebSocketMessageType]::Text, $true, $timeout.Token).GetAwaiter().GetResult() | Out-Null
        $buffer = New-Object byte[] 16384
        while ($true) {
            $stream = [IO.MemoryStream]::new()
            try {
                do {
                    $received = $socket.ReceiveAsync([ArraySegment[byte]]::new($buffer), $timeout.Token).GetAwaiter().GetResult()
                    if ($received.MessageType -eq [Net.WebSockets.WebSocketMessageType]::Close) { throw 'GlazeWM disconnected.' }
                    $stream.Write($buffer, 0, $received.Count)
                } until ($received.EndOfMessage)
                $reply = [Text.Encoding]::UTF8.GetString($stream.ToArray()) | ConvertFrom-Json
            } finally { $stream.Dispose() }
            if ($reply.messageType -eq 'client_response' -and $reply.clientMessage -eq $command) {
                if (-not $reply.success) { throw ('GlazeWM reload: ' + $reply.error) }
                return
            }
        }
    } finally { $socket.Dispose(); $timeout.Dispose() }
}
$mutex = New-Object System.Threading.Mutex($false, 'Local\ZebarGlazeTheme')
$locked = $false
try {
    $locked = $mutex.WaitOne(10000)
    if (-not $locked) { throw 'Another theme update is still running.' }
    $selectedTheme = Get-DesktopTheme -Theme $Theme
    $config = (Resolve-Path -LiteralPath $ConfigPath).Path
    $original = [IO.File]::ReadAllText($config)
    $pattern = '(?ms)(^  focused_window:\r?\n(?:(?!^  \S).)*?^    border:\r?\n(?:(?!^    \S).)*?^      color:[ \t]*)["'']?#[0-9a-fA-F]{6}["'']?'
    $matches = [regex]::Matches($original, $pattern)
    if ($matches.Count -ne 1) { throw 'Could not locate the focused window border color safely.' }
    $color = $selectedTheme.accent
    $updated = [regex]::Replace($original, $pattern, {param($match) $match.Groups[1].Value + '"' + $color + '"'})
    if ($updated -ceq $original) { Set-ThemeWallpaper -Theme $Theme; Set-ThemeCursor -Theme $Theme; exit 0 }
    $backup = $config + '.bak-theme'
    if (-not (Test-Path -LiteralPath $backup)) { Copy-Item -LiteralPath $config -Destination $backup }
    [IO.File]::WriteAllText($config, $updated, (New-Object System.Text.UTF8Encoding($false)))
    try {
        Reload-GlazeConfig
    } catch {
        [IO.File]::WriteAllText($config, $original, (New-Object System.Text.UTF8Encoding($false)))
        try { Reload-GlazeConfig } catch { }
        throw
    }
    Set-ThemeWallpaper -Theme $Theme
    Set-ThemeCursor -Theme $Theme
} catch {
    [Console]::Error.WriteLine($_.Exception.Message)
    exit 1
} finally {
    if ($locked) { $mutex.ReleaseMutex() }
    $mutex.Dispose()
}
