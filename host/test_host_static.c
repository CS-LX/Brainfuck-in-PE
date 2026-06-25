#include <stdio.h>
#include <string.h>

#include "bfdll.h"

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

    if (BF_Add(3, 5) != 8) {
        printf("BF_Add failed\n");
        return 1;
    }

    printf("All static-import tests passed.\n");
    return 0;
}
