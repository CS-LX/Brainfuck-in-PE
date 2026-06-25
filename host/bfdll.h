#ifndef BFDLL_H
#define BFDLL_H

#ifdef __cplusplus
extern "C" {
#endif

__declspec(dllimport) int __cdecl BF_Ping(void);
__declspec(dllimport) void __cdecl BF_Hello(void);
__declspec(dllimport) int __cdecl BF_Add(int a, int b);
__declspec(dllimport) const char* __cdecl BF_HelloWorld(void);
__declspec(dllimport) const char* __cdecl BF_GetLastOutput(void);

#ifdef __cplusplus
}
#endif

#endif
