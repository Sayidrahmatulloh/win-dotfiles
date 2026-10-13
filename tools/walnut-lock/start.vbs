Option Explicit
Dim shell, files, folder, script, command
Set shell = CreateObject("WScript.Shell")
Set files = CreateObject("Scripting.FileSystemObject")
folder = files.GetParentFolderName(WScript.ScriptFullName)
script = files.BuildPath(folder, "start.ps1")
command = "powershell.exe -NoProfile -STA -ExecutionPolicy Bypass -WindowStyle Hidden -File " & Chr(34) & script & Chr(34)
If WScript.Arguments.Count > 0 Then
  If WScript.Arguments(0) = "selftest" Then command = command & " -SelfTest"
End If
shell.Run command, 0, False
