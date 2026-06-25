#include <stdio.h>
#include <stdint.h>
#include <string.h>

#include "bfdll.h"

typedef struct {
    char bytes[64];
    size_t length;
} capture_t;

static void __cdecl capture_output(uint8_t byte, void* user)
{
    capture_t* capture = (capture_t*)user;
    if (capture->length + 1 >= sizeof(capture->bytes)) {
        return;
    }
    capture->bytes[capture->length++] = (char)byte;
    capture->bytes[capture->length] = '\0';
}

int main(void)
{
    if (BF_Ping() != 42) {
        printf("BF_Ping failed\n");
        return 1;
    }

    BF_Hello();
    if (strcmp(BF_GetLastOutput(), "Hi") != 0) {
        printf("BF_Hello failed: got \"%s\"\n", BF_GetLastOutput());
        return 1;
    }

    if (strcmp(BF_HelloWorld(), "Hello World!") != 0) {
        printf("BF_HelloWorld failed: got \"%s\"\n", BF_HelloWorld());
        return 1;
    }

    if (strcmp(BF_AutoMessage(), "Auto export works!") != 0) {
        printf("BF_AutoMessage failed: got \"%s\"\n", BF_AutoMessage());
        return 1;
    }

    capture_t capture = {{0}, 0};
    BF_SetOutputCallback(capture_output, &capture);
    BF_HelloWorld();
    BF_SetOutputCallback(NULL, NULL);
    if (strcmp(capture.bytes, "Hello World!\n") != 0) {
        printf("BF_SetOutputCallback failed: got \"%s\"\n", capture.bytes);
        return 1;
    }

    if (BF_Add(3, 5) != 8) {
        printf("BF_Add failed\n");
        return 1;
    }

    printf("All static-import tests passed.\n");
    return 0;
}
