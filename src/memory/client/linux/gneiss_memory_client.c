#define _GNU_SOURCE

#include <err.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/mman.h>

//#define ENABLE_TRACE
#include <trace.h>

void gneiss_memfd_create(const char *name, unsigned long long size, int *fd)
{
    TRACE("name=%p size=%llu fd=%p\n", name, size, fd);
    *fd = memfd_create(name, MFD_ALLOW_SEALING);
    if(*fd < 0){
        warn("name=%s size=%llu fd=%p\n", name, size, fd);
        return;
    }
    if(ftruncate(*fd, size) < 0){
        warn("name=%s size=%llu fd=%p\n", name, size, fd);
        close(*fd);
        *fd = -1;
    }
}
