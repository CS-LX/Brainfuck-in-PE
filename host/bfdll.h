#ifndef BFDLL_H
#define BFDLL_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef void (__cdecl *BF_OutputCallback)(uint8_t byte, void* user);

__declspec(dllimport) int __cdecl BF_Ping(void);
__declspec(dllimport) void __cdecl BF_Hello(void);
__declspec(dllimport) int __cdecl BF_Add(int a, int b);
__declspec(dllimport) const char* __cdecl BF_GetLastOutput(void);
__declspec(dllimport) void __cdecl BF_SetOutputCallback(BF_OutputCallback callback, void* user);

#include "bf_exports.gen.h"

#ifdef __cplusplus
}
#endif

#endif
