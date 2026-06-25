#include <stdio.h>
#include <string.h>
#include <windows.h>

typedef int (__cdecl *BF_Ping_fn)(void);
typedef void (__cdecl *BF_Hello_fn)(void);
typedef int (__cdecl *BF_Add_fn)(int, int);
typedef const char* (__cdecl *BF_HelloWorld_fn)(void);
typedef const char* (__cdecl *BF_GetLastOutput_fn)(void);

static HMODULE load_bfdll(void)
{
    HMODULE mod = LoadLibraryA("bfdll.dll");
    if (!mod) {
        mod = LoadLibraryA("..\\lib\\bfdll.dll");
    }
    if (!mod) {
        mod = LoadLibraryA("..\\bfdll.dll");
    }
    return mod;
}

int main(void)
{
    HMODULE mod = load_bfdll();
    if (!mod) {
        printf("LoadLibrary failed: %lu\n", GetLastError());
        return 1;
    }

    BF_Ping_fn ping = (BF_Ping_fn)GetProcAddress(mod, "BF_Ping");
    BF_Hello_fn hello = (BF_Hello_fn)GetProcAddress(mod, "BF_Hello");
    BF_Add_fn add = (BF_Add_fn)GetProcAddress(mod, "BF_Add");
    BF_HelloWorld_fn hello_world = (BF_HelloWorld_fn)GetProcAddress(mod, "BF_HelloWorld");
    BF_GetLastOutput_fn get_output = (BF_GetLastOutput_fn)GetProcAddress(mod, "BF_GetLastOutput");

    if (!ping || !hello || !add || !hello_world || !get_output) {
        printf("GetProcAddress failed\n");
        FreeLibrary(mod);
        return 1;
    }

    int ping_result = ping();
    printf("BF_Ping() = %d (expected 42)\n", ping_result);
    if (ping_result != 42) {
        FreeLibrary(mod);
        return 1;
    }

    hello();
    const char* hi = get_output();
    printf("BF_Hello() output = \"%s\" (expected \"Hi\")\n", hi);
    if (strcmp(hi, "Hi") != 0) {
        FreeLibrary(mod);
        return 1;
    }

    const char* message = hello_world();
    printf("BF_HelloWorld() = \"%s\"\n", message);
    if (strcmp(message, "Hello World!") != 0) {
        FreeLibrary(mod);
        return 1;
    }

    int sum = add(3, 5);
    printf("BF_Add(3, 5) = %d (expected 8)\n", sum);
    if (sum != 8) {
        FreeLibrary(mod);
        return 1;
    }

    FreeLibrary(mod);
    printf("All dynamic-load tests passed.\n");
    return 0;
}
