. (Join-Path $PSScriptRoot 'ThemeConfig.ps1')
function Get-CursorRoles {
    [ordered]@{
        Arrow='Pointer.cur'; Help='Help.cur'; AppStarting='Work.ani'; Wait='Busy.ani'
        Crosshair='Cross.cur'; IBeam='Text.cur'; NWPen='Handwriting.cur'; No='Unavailable.cur'
        SizeNS='Vert.cur'; SizeWE='Horz.cur'; SizeNWSE='Dgn1.cur'; SizeNESW='Dgn2.cur'
        SizeAll='Move.cur'; UpArrow='Alternate.cur'; Hand='Link.cur'; Pin='Pin.cur'; Person='Person.cur'
    }
}

function Expand-ThemeCursors {
    param([Parameter(Mandatory=$true)][string]$Destination)
    $archive = Join-Path (Get-DesktopRoot) 'assets/cursors/Bibata-Modern-Zebar.zip'
    if (-not (Test-Path -LiteralPath $archive -PathType Leaf)) { throw 'Bundled Bibata ZIP is missing.' }
    New-Item -ItemType Directory -Path $Destination -Force | Out-Null
    Expand-Archive -LiteralPath $archive -DestinationPath $Destination -Force
    foreach ($theme in (Get-ThemeCatalog).themes) {
        foreach ($file in (Get-CursorRoles).Values) {
            if (-not (Test-Path -LiteralPath (Join-Path $Destination "$($theme.cursor)/$file") -PathType Leaf)) { throw "Incomplete Bibata cursor set: $($theme.id)/$file" }
        }
    }
}

function Update-DesktopCursors {
    if (-not ('ZebarDesktopCursor' -as [type])) {
        Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class ZebarDesktopCursor {
    [DllImport("user32.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool SystemParametersInfoW(uint action, uint parameter, IntPtr value, uint flags);
}
'@
    }
    # SPI_SETCURSORS reloads the persisted registry values; its flags must be zero.
    if (-not [ZebarDesktopCursor]::SystemParametersInfoW(0x57, 0, [IntPtr]::Zero, 0)) {
        $nativeError = [Runtime.InteropServices.Marshal]::GetLastWin32Error()
        if ($nativeError -eq 0) { throw 'Windows could not reload the mouse cursors (no error code was provided).' }
        throw [ComponentModel.Win32Exception]::new($nativeError)
    }
}

function Set-ThemeCursor {
    param(
        [Parameter(Mandatory=$true)][string]$Theme,
        [string]$CursorRoot
    )
    $selectedTheme = Get-DesktopTheme -Theme $Theme
    $roles = Get-CursorRoles
    if (-not $CursorRoot) {
        $CursorRoot = Join-Path $env:LOCALAPPDATA 'win-dotfiles/cursors/Bibata-Modern-Zebar'
        $missing = @($roles.Values | Where-Object { -not (Test-Path -LiteralPath (Join-Path $CursorRoot "$($selectedTheme.cursor)/$_") -PathType Leaf) })
        if ($missing.Count) { Expand-ThemeCursors -Destination $CursorRoot }
    }
    $paths = @($roles.Values | ForEach-Object {
        (Resolve-Path -LiteralPath (Join-Path $CursorRoot "$($selectedTheme.cursor)/$_") -ErrorAction Stop).Path
    })
    $key = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Control Panel\Cursors', $true)
    if (-not $key) { throw 'Windows cursor registry key is missing.' }
    try {
        $backup = Join-Path $env:LOCALAPPDATA 'win-dotfiles/cursors/original.clixml'
        if (-not (Test-Path -LiteralPath $backup)) {
            $values = @('') + @($roles.Keys) + @('Scheme Source')
            $snapshot = @($values | ForEach-Object {
                $exists = $_ -in $key.GetValueNames()
                [pscustomobject]@{
                    Name=$_; Exists=$exists
                    Value=if ($exists) { $key.GetValue($_, $null, [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames) } else { $null }
                    Kind=if ($exists) { [string]$key.GetValueKind($_) } else { $null }
                }
            })
            New-Item -ItemType Directory -Path (Split-Path $backup) -Force | Out-Null
            $snapshot | Export-Clixml -LiteralPath $backup
        }
        $scheme = "Bibata Modern Zebar $Theme"
        $schemes = $key.CreateSubKey('Schemes')
        try { $schemes.SetValue($scheme, ($paths -join ','), [Microsoft.Win32.RegistryValueKind]::String) }
        finally { $schemes.Dispose() }
        $index = 0
        foreach ($role in $roles.Keys) {
            $key.SetValue($role, $paths[$index++], [Microsoft.Win32.RegistryValueKind]::ExpandString)
        }
        $key.SetValue('', $scheme, [Microsoft.Win32.RegistryValueKind]::String)
        $key.SetValue('Scheme Source', 1, [Microsoft.Win32.RegistryValueKind]::DWord)
    } finally { $key.Dispose() }
    Update-DesktopCursors
}

function Restore-ThemeCursor {
    $backup = Join-Path $env:LOCALAPPDATA 'win-dotfiles/cursors/original.clixml'
    $snapshot = Import-Clixml -LiteralPath $backup -ErrorAction Stop
    $key = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Control Panel\Cursors', $true)
    if (-not $key) { throw 'Windows cursor registry key is missing.' }
    try {
        foreach ($value in $snapshot) {
            if ($value.Exists) { $key.SetValue($value.Name, $value.Value, [Microsoft.Win32.RegistryValueKind]$value.Kind) }
            else { $key.DeleteValue($value.Name, $false) }
        }
    } finally { $key.Dispose() }
    Update-DesktopCursors
}
