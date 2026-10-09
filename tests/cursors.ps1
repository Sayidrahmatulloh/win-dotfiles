param([string]$RepoRoot = (Split-Path $PSScriptRoot -Parent))
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/helpers.ps1"
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('bibata-test-' + [guid]::NewGuid().ToString('N'))
& "$RepoRoot/scripts/install/cursors.ps1" -Destination $fixture -ExtractOnly
. "$RepoRoot/scripts/theme/SetCursor.ps1"
$catalog = Get-ThemeCatalog -Root $RepoRoot
Add-Type @'
using System;
using System.Runtime.InteropServices;
public static class CursorAssetTest {
    [DllImport("user32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
    public static extern IntPtr LoadCursorFromFileW(string path);
    [DllImport("user32.dll")]
    public static extern bool DestroyCursor(IntPtr cursor);
}
'@
foreach ($theme in @($catalog.themes.cursor)) {
    $files = @(Get-ChildItem "$fixture/$theme" -File)
    Assert-That ($files.Count -eq 17) "Missing cursor roles for $theme."
    foreach ($file in $files) {
        $handle = [CursorAssetTest]::LoadCursorFromFileW($file.FullName)
        Assert-That ($handle -ne [IntPtr]::Zero) "Windows rejected $($file.FullName)."
        [CursorAssetTest]::DestroyCursor($handle) | Out-Null
    }
}
$pointer = Join-Path $fixture 'amber/Pointer.cur'
$originalHash = (Get-FileHash $pointer).Hash
[IO.File]::WriteAllText($pointer, 'damaged')
& "$RepoRoot/scripts/install/cursors.ps1" -Destination $fixture -ExtractOnly
Assert-That ((Get-FileHash $pointer).Hash -eq $originalHash) 'Reinstall did not repair the cursor.'
foreach ($file in Get-ChildItem "$RepoRoot/scripts" -Filter '*.ps1' -Recurse) {
    $tokens = $null; $errors = $null
    $null = [Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$tokens, [ref]$errors)
    Assert-That ($errors.Count -eq 0) "PowerShell syntax error in $($file.Name)."
}
. "$RepoRoot/lib/diagnostics.ps1"
$active = [pscustomobject]@{'(default)'='Bibata Modern Zebar green'}
foreach ($role in (Get-CursorRoles).GetEnumerator()) {
    $active | Add-Member -NotePropertyName $role.Key -NotePropertyValue (Join-Path $fixture "amber/$($role.Value)")
}
$results = @(Test-DoctorCursors -RepoRoot $RepoRoot -InstalledRoot $fixture -ActiveValues $active)
Assert-That (@($results | Where-Object Status -NE OK).Count -eq 0) 'Doctor rejected valid installed cursors.'
$active.Arrow = 'C:\missing.cur'
$threw = $false
try { Test-DoctorCursors -RepoRoot $RepoRoot -InstalledRoot $fixture -ActiveValues $active | Out-Null } catch { $threw = $true }
Assert-That $threw 'Doctor missed a stale cursor registry path.'
$active.Arrow = Join-Path $fixture 'amber/Pointer.cur'
[IO.File]::WriteAllText($pointer, 'corrupt')
$threw = $false
try { Test-DoctorCursors -RepoRoot $RepoRoot -InstalledRoot $fixture -ActiveValues $active | Out-Null } catch { $threw = $true }
Assert-That $threw 'Doctor missed corrupted installed cursor bytes.'
# Test the Win32 refresh call with a fake native class: no desktop changes.
Add-Type @'
using System;
public static class ZebarDesktopCursor {
    public static bool Success = true;
    public static uint Action;
    public static uint Flags;
    public static bool SystemParametersInfoW(uint action, uint parameter, IntPtr value, uint flags) {
        Action = action; Flags = flags; return Success;
    }
}
'@
. "$RepoRoot/scripts/theme/SetCursor.ps1"
Update-DesktopCursors
Assert-That ([ZebarDesktopCursor]::Action -eq 0x57) 'Wrong cursor refresh action.'
Assert-That ([ZebarDesktopCursor]::Flags -eq 0) 'Cursor refresh used unsupported flags.'
[ZebarDesktopCursor]::Success = $false
$threw = $false
try { Update-DesktopCursors } catch { $threw = $true }
Assert-That $threw 'Failed cursor refresh was silently accepted.'
Write-Host 'All 51 cursor assets load in Windows; scripts parse and refresh errors propagate.'
