using System;
using System.Text;

internal static class Program
{
    private static readonly StringBuilder CallbackCapture = new();
    private static BfdllNative.OutputCallback? s_outputCallback;

    private static int Main()
    {
        try
        {
            RunAcceptanceTests();
        }
        catch (DllNotFoundException ex)
        {
            Console.Error.WriteLine("bfdll.dll not found. Build BFDll first, then rebuild this project.");
            Console.Error.WriteLine(ex.Message);
            return 1;
        }
        catch (BadImageFormatException)
        {
            Console.Error.WriteLine("Architecture mismatch. Set PlatformTarget to x64 for this project.");
            return 1;
        }

        Console.WriteLine("All C# acceptance tests passed.");
        return 0;
    }

    private static void RunAcceptanceTests()
    {
        int ping = BfdllNative.BF_Ping();
        Console.WriteLine($"BF_Ping() = {ping} (expected 42)");
        if (ping != 42)
        {
            throw new InvalidOperationException("BF_Ping failed.");
        }

        BfdllNative.BF_Hello();
        string hi = BfdllNative.ReadAnsiString(BfdllNative.BF_GetLastOutput());
        Console.WriteLine($"BF_Hello() output = \"{hi}\" (expected \"Hi\")");
        if (hi != "Hi")
        {
            throw new InvalidOperationException("BF_Hello failed.");
        }

        string helloWorld = BfdllNative.ReadAnsiString(BfdllNative.BF_HelloWorld());
        Console.WriteLine($"BF_HelloWorld() = \"{helloWorld}\"");
        if (helloWorld != "Hello World!")
        {
            throw new InvalidOperationException("BF_HelloWorld failed.");
        }

        string autoMessage = BfdllNative.ReadAnsiString(BfdllNative.BF_AutoMessage());
        Console.WriteLine($"BF_AutoMessage() = \"{autoMessage}\"");
        if (autoMessage != "Auto export works!")
        {
            throw new InvalidOperationException("BF_AutoMessage failed.");
        }

        CallbackCapture.Clear();
        s_outputCallback = OnOutput;
        BfdllNative.BF_SetOutputCallback(s_outputCallback, IntPtr.Zero);
        BfdllNative.BF_HelloWorld();
        BfdllNative.BF_SetOutputCallback(null!, IntPtr.Zero);
        s_outputCallback = null;

        string captured = CallbackCapture.ToString();
        Console.WriteLine($"I/O callback captured = \"{captured.Replace("\n", "\\n")}\"");
        if (captured != "Hello World!\n")
        {
            throw new InvalidOperationException("BF_SetOutputCallback failed.");
        }

        int sum = BfdllNative.BF_Add(3, 5);
        Console.WriteLine($"BF_Add(3, 5) = {sum} (expected 8)");
        if (sum != 8)
        {
            throw new InvalidOperationException("BF_Add failed.");
        }
    }

    private static void OnOutput(byte b, IntPtr user)
    {
        CallbackCapture.Append((char)b);
    }
}
