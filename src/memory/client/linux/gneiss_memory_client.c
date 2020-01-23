
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <stdio.h>
#include <sys/mman.h>

//#define ENABLE_TRACE
#include <trace.h>

int stat_size(int fd)
{
    TRACE("fd=%d\n", fd);
    struct stat st;
    if(fstat(fd, &st) < 0){
        perror("fstat");
        return 0;
    }
    return st.st_size;
}

void map_file(int fd, void **map, int writable)
{
    TRACE("fd=%d *map=%p writable=%d\n", fd, *map, writable);
    *map = mmap(0, stat_size(fd), writable ? PROT_READ | PROT_WRITE : PROT_READ, MAP_SHARED, fd, 0);
    if(*map == MAP_FAILED){
        perror("mmap");
        *map = 0x0;
    }
}

void unmap_file(int fd, void **map)
{
    TRACE("fd=%d *map=%p\n", fd, *map);
    if(munmap(*map, stat_size(fd)) < 0){
        perror("munmap");
    }
    *map = 0x0;
}
