using System;
using System.Runtime.InteropServices;

internal static class BfdllNative
{
    private const string DllName = "bfdll.dll";

    [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
    public delegate void OutputCallback(byte b, IntPtr user);

    [DllImport(DllName, CallingConvention = CallingConvention.Cdecl)]
    public static extern int BF_Ping();

    [DllImport(DllName, CallingConvention = CallingConvention.Cdecl)]
    public static extern void BF_Hello();

    [DllImport(DllName, CallingConvention = CallingConvention.Cdecl)]
    public static extern int BF_Add(int a, int b);

    [DllImport(DllName, CallingConvention = CallingConvention.Cdecl)]
    public static extern IntPtr BF_GetLastOutput();

    [DllImport(DllName, CallingConvention = CallingConvention.Cdecl)]
    public static extern IntPtr BF_HelloWorld();

    [DllImport(DllName, CallingConvention = CallingConvention.Cdecl)]
    public static extern IntPtr BF_AutoMessage();

    [DllImport(DllName, CallingConvention = CallingConvention.Cdecl)]
    public static extern void BF_SetOutputCallback(OutputCallback callback, IntPtr user);

    public static string ReadAnsiString(IntPtr ptr) =>
        ptr == IntPtr.Zero ? string.Empty : Marshal.PtrToStringAnsi(ptr) ?? string.Empty;
}
