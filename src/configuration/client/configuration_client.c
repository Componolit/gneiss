
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdint.h>
#include <sys/mman.h>
#include <capability.h>

typedef struct session
{
    int fd;
    void *map;
    uint64_t size;
} session_t;

void configuration_client_initialize(session_t *session, capability_t *cap)
{
    struct stat st;
    if(cap->config_file){
        session->fd = open(cap->config_file, O_RDONLY | O_NOFOLLOW);
        if(session->fd > -1){
            if(!fstat(session->fd, &st)){
                session->map = mmap(0, st.st_size, PROT_READ, MAP_PRIVATE, session->fd, 0);
                if(session->map == MAP_FAILED || session->map == 0){
                    perror("map failed");
                    close(session->fd);
                    session->fd = -1;
                    session->map = 0;
                }else{
                    session->size = st.st_size;
                }
            }else{
                perror("stat failed");
                close(session->fd);
                session->fd = -1;
            }
        }else{
            perror(cap->config_file);
        }
    }
}

void configuration_client_finalize(session_t *session)
{
    munmap(session->map, session->size);
    close(session->fd);
    session->fd = -1;
    session->map = 0;
    session->size = 0;
}
