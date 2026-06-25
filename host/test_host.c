#include <stdio.h>
#include <windows.h>

typedef int (__cdecl *BF_Ping_fn)(void);
typedef void (__cdecl *BF_Hello_fn)(void);
typedef int (__cdecl *BF_Add_fn)(int, int);

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

    if (!ping || !hello || !add) {
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
    printf("BF_Hello() called (check OutputDebugString for 'Hi')\n");

    int sum = add(3, 5);
    printf("BF_Add(3, 5) = %d (expected 8)\n", sum);
    if (sum != 8) {
        FreeLibrary(mod);
        return 1;
    }

    FreeLibrary(mod);
    printf("All tests passed.\n");
    return 0;
}
