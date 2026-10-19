function Reload-GlazeConfig {
    $socket = [Net.WebSockets.ClientWebSocket]::new()
    $timeout = [Threading.CancellationTokenSource]::new(10000)
    try {
        $socket.ConnectAsync([Uri]'ws://127.0.0.1:6123', $timeout.Token).GetAwaiter().GetResult() | Out-Null
        $command = 'command wm-reload-config'
        $bytes = [Text.Encoding]::UTF8.GetBytes($command)
        $socket.SendAsync([ArraySegment[byte]]::new($bytes), [Net.WebSockets.WebSocketMessageType]::Text, $true, $timeout.Token).GetAwaiter().GetResult() | Out-Null
        $buffer = New-Object byte[] 16384
        $maxMessages = 50
        $messageCount = 0
        while ($messageCount -lt $maxMessages) {
            $messageCount++
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
        throw 'GlazeWM reload timed out waiting for response.'
    } finally { $socket.Dispose(); $timeout.Dispose() }
}
# Change only the focused border; leave the surrounding YAML byte-for-byte intact.
function Set-GlazeBorderColor {
    param([string]$Content, [ValidatePattern('^#[0-9a-fA-F]{6}$')][string]$Accent)
    $pattern = '(?ms)(^  focused_window:\r?\n(?:(?!^  \S).)*?^    border:\r?\n(?:(?!^    \S).)*?^      color:[ \t]*)["'']?#[0-9a-fA-F]{6}["'']?'
    $regexMatches = [regex]::Matches($Content, $pattern)
    if ($regexMatches.Count -ne 1) { throw 'Could not locate the focused window border color safely.' }
    $color = $Accent
    $updated = [regex]::Replace($Content, $pattern, {param($match) $match.Groups[1].Value + '"' + $color + '"'})
    return $updated
}
