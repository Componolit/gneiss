
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

void initialize(const char *str, void **label)
{
    const size_t len = strlen(str) + 1;
    *label = malloc(len);
    if(label){
        memcpy(*label, str, len);
    }
}

void finalize(void *label)
{
    free(label);
}

void print(const char *msg)
{
    fputs(msg, stderr);
}
