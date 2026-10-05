function Set-ThemeWallpaper {
    param([Parameter(Mandatory=$true)][string]$Theme)

    $mappingFile = Join-Path $PSScriptRoot 'theme-wallpapers.json'
    $mapping = Get-Content -LiteralPath $mappingFile -Raw | ConvertFrom-Json
    $relativePath = $mapping.$Theme
    if ([string]::IsNullOrWhiteSpace($relativePath)) { return }
    $wallpaper = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot $relativePath)).Path
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
