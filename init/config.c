
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/mman.h>

//#define ENABLE_TRACE
#include <trace.h>

void gneiss_load_config(const char *file, void (*parse)(char *, int size))
{
    struct stat st;
    int fd;
    char *file_content;
    TRACE("file=%p\n", file);

    if(stat(file, &st) < 0){
        perror("stat");
        return;
    }
    TRACE("st.st_size=%d\n", st.st_size);

    fd = open(file, O_RDONLY);
    if(fd < 0){
        perror("open");
        return;
    }

    file_content = mmap(0, st.st_size, PROT_READ, MAP_SHARED, fd, 0);
    if(file_content == MAP_FAILED){
        perror("mmap");
        close(fd);
        return;
    }

    parse(file_content, st.st_size);
    munmap(file_content, st.st_size);
    close(fd);
}
