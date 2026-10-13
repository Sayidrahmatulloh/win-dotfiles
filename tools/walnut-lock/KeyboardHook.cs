using System;
using System.Runtime.InteropServices;
public static class WalnutKeys {
    private delegate IntPtr Hook(int code, IntPtr message, IntPtr data);
    private static Hook callback = Filter;
    private static IntPtr handle;
    public static Action Escape;
    [DllImport("user32.dll")] private static extern IntPtr SetThreadDpiAwarenessContext(IntPtr context);
    public static void UsePhysicalPixels() {
        if (SetThreadDpiAwarenessContext(new IntPtr(-4)) == IntPtr.Zero)
            throw new System.ComponentModel.Win32Exception();
    }
    [DllImport("user32.dll", SetLastError=true)] private static extern IntPtr SetWindowsHookEx(int id, Hook fn, IntPtr module, uint thread);
    [DllImport("user32.dll")] private static extern bool UnhookWindowsHookEx(IntPtr hook);
    [DllImport("user32.dll")] private static extern IntPtr CallNextHookEx(IntPtr hook,int code,IntPtr message,IntPtr data);
    [DllImport("user32.dll")] private static extern short GetAsyncKeyState(int key);
    [DllImport("kernel32.dll",CharSet=CharSet.Auto)] private static extern IntPtr GetModuleHandle(string name);
    private static bool Down(int key) { return (GetAsyncKeyState(key) & 0x8000) != 0; }
    public static void Start() {
        handle = SetWindowsHookEx(13, callback, GetModuleHandle(null), 0);
        if(handle == IntPtr.Zero) throw new System.ComponentModel.Win32Exception();
    }
    public static void Stop() { if(handle != IntPtr.Zero) { UnhookWindowsHookEx(handle); handle=IntPtr.Zero; } }
    private static IntPtr Filter(int code,IntPtr message,IntPtr data) {
        if(code < 0) return CallNextHookEx(handle,code,message,data);
        int key = Marshal.ReadInt32(data);
        bool pressed = message.ToInt32() == 0x100 || message.ToInt32() == 0x104;
        if(key == 123 && Down(17) && Down(16)) {
            if(pressed && Escape != null) Escape();
            return new IntPtr(1);
        }
        return IsBlockedKey(key) ? new IntPtr(1) : CallNextHookEx(handle,code,message,data);
    }
    public static bool IsBlockedKey(int key) {
        return key == 9 || key == 20 || key == 16 || key == 17 || key == 18 ||
            key == 91 || key == 92 || (key >= 112 && key <= 123) ||
            (key >= 160 && key <= 165);
    }
}
