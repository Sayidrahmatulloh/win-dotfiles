#Requires AutoHotkey v2.0
#SingleInstance Force
if A_Args.Length < 1 || !RegExMatch(A_Args[1], "^\d+$")
    ExitApp
try {
    if WinExist("ahk_id " A_Args[1])
        WinActivate("ahk_id " A_Args[1])
}
ExitApp
