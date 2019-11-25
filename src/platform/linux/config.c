
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>

#include <config.h>

void gneiss_load_config(const char *file, char **content)
{
    struct stat st;
    char *file_content;
    int fd;

    *content = 0;

    if(stat(file, &st) < 0){
        perror("stat");
        return;
    }

    file_content = malloc(st.st_size);
    if(!file_content){
        perror("malloc");
        return;
    }

    fd = open(file, O_RDONLY);
    if(fd < 0){
        perror("open");
        free(file_content);
        return;
    }
    if(read(fd, file_content, st.st_size) < 0){
        perror("read");
        free(file_content);
        return;
    }
    close(fd);
    *content = file_content;
}
