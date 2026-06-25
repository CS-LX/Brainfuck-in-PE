#pragma code_seg(".text$a")

#include <string.h>

#include "bf_abi.h"
#include "bf_io.h"

extern const char BF_Prog_Hello[];
extern const char BF_Prog_Add[];

static __declspec(thread) uint8_t g_tape[BFDLL_TAPE_SIZE];

__declspec(dllexport) int __cdecl BF_Ping(void)
{
    return 42;
}

__declspec(dllexport) void __cdecl BF_Hello(void)
{
    bf_vm_t vm = bf_vm_default(g_tape);
    memset(g_tape, 0, sizeof(g_tape));

    bf_io_reset();
    if (bf_vm_run(&vm, BF_Prog_Hello) == BF_OK) {
        bf_io_flush();
    }
}

__declspec(dllexport) int __cdecl BF_Add(int a, int b)
{
    bf_vm_t vm = bf_vm_default(g_tape);
    memset(g_tape, 0, sizeof(g_tape));

    g_tape[0] = (uint8_t)a;
    g_tape[1] = (uint8_t)b;

    if (bf_vm_run(&vm, BF_Prog_Add) != BF_OK) {
        return -1;
    }

    return (int)g_tape[0];
}
