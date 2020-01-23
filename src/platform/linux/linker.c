
#include <stdio.h>
#include <dlfcn.h>

void gneiss_dlopen(char *file, void **handle)
{
    *handle = dlopen(file, RTLD_LAZY);
    if(!*handle){
        fprintf(stderr, "dlopen: file=%s: %s\n", file, dlerror());
    }
}

void *gneiss_dlsym(void *handle, char *name)
{
    return dlsym(handle, name);
}
