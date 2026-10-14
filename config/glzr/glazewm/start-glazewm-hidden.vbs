Option Explicit
Dim shell, files, launcher
Set shell = CreateObject("WScript.Shell")
Set files = CreateObject("Scripting.FileSystemObject")
launcher = shell.ExpandEnvironmentStrings("%ProgramFiles%\glzr.io\GlazeWM\cli\glazewm.exe")
If Not files.FileExists(launcher) Then
  WScript.Quit 2
End If
shell.CurrentDirectory = files.GetParentFolderName(launcher)
shell.Run Chr(34) & launcher & Chr(34) & " start", 0, False
