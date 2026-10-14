using System;
using System.Runtime.InteropServices;
using System.Collections.Generic;
public static class WalnutKeys {
    private delegate IntPtr Hook(int code, IntPtr message, IntPtr data);
    private static Hook callback = Filter;
    private static IntPtr handle;
    private static Hook mouseCallback = FilterMouse;
    private static IntPtr mouseHandle;
    private static readonly HashSet<int> held = new HashSet<int>();
    private static bool draining;
    public static bool InputReleased { get { return held.Count == 0; } }
    public static void BeginDrain() { draining = true; }
    [DllImport("user32.dll")] private static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] private static extern uint GetWindowThreadProcessId(IntPtr window, out uint process);
    private static bool OwnsForeground() {
        uint process;
        GetWindowThreadProcessId(GetForegroundWindow(), out process);
        return process == (uint)System.Diagnostics.Process.GetCurrentProcess().Id;
    }
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
        held.Clear();
        draining = false;
        handle = SetWindowsHookEx(13, callback, GetModuleHandle(null), 0);
        if(handle == IntPtr.Zero) throw new System.ComponentModel.Win32Exception();
        mouseHandle = SetWindowsHookEx(14, mouseCallback, GetModuleHandle(null), 0);
        if(mouseHandle == IntPtr.Zero) { Stop(); throw new System.ComponentModel.Win32Exception(); }
    }
    public static void Stop() {
        if(mouseHandle != IntPtr.Zero) { UnhookWindowsHookEx(mouseHandle); mouseHandle=IntPtr.Zero; }
        if(handle != IntPtr.Zero) { UnhookWindowsHookEx(handle); handle=IntPtr.Zero; }
        held.Clear();
    }
    private static IntPtr FilterMouse(int code, IntPtr message, IntPtr data) {
        if(code < 0) return CallNextHookEx(mouseHandle,code,message,data);
        int msg = message.ToInt32();
        int button = 0;
        bool pressed = false;
        switch(msg) {
            case 0x201: button=1; pressed=true; break;
            case 0x202: button=1; break;
            case 0x204: button=2; pressed=true; break;
            case 0x205: button=2; break;
            case 0x207: button=4; pressed=true; break;
            case 0x208: button=4; break;
            case 0x20B: case 0x20C:
                button = ((Marshal.ReadInt32(data, 8) >> 16) & 0xffff) == 1 ? 5 : 6;
                pressed = msg == 0x20B;
                break;
        }
        if(button != 0) { if(pressed) held.Add(-button); else held.Remove(-button); }
        // Allow cursor motion, consume clicks and both scroll directions globally.
        return msg == 0x200 ? CallNextHookEx(mouseHandle,code,message,data) : new IntPtr(1);
    }
    private static IntPtr Filter(int code,IntPtr message,IntPtr data) {
        if(code < 0) return CallNextHookEx(handle,code,message,data);
        int key = Marshal.ReadInt32(data);
        bool pressed = message.ToInt32() == 0x100 || message.ToInt32() == 0x104;
        if(pressed) held.Add(key); else held.Remove(key);
        if(draining || !OwnsForeground()) return new IntPtr(1);
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
