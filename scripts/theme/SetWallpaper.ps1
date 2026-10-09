. (Join-Path $PSScriptRoot 'ThemeConfig.ps1')
function Set-ThemeWallpaper {
    param([Parameter(Mandatory=$true)][string]$Theme)

    $selectedTheme = Get-DesktopTheme -Theme $Theme
    $wallpaper = (Resolve-Path -LiteralPath (Join-Path (Get-DesktopRoot) $selectedTheme.wallpaper)).Path
    $current = (Get-ItemProperty -LiteralPath 'HKCU:\Control Panel\Desktop' -Name WallPaper).WallPaper
    if ($current -ieq $wallpaper) { return }

    if (-not ('ZebarDesktopWallpaper' -as [type])) {
        Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class ZebarDesktopWallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool SystemParametersInfoW(uint action, uint parameter, string value, uint flags);
}
'@
    }
    # Persist the selected wallpaper and notify the Windows desktop.
    if (-not [ZebarDesktopWallpaper]::SystemParametersInfoW(20, 0, $wallpaper, 3)) {
        throw [ComponentModel.Win32Exception]::new([Runtime.InteropServices.Marshal]::GetLastWin32Error())
    }
}
