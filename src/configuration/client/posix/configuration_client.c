
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdint.h>
#include <sys/mman.h>
#include <sys/inotify.h>
#include <capability.h>

typedef struct session session_t;

struct session
{
    int fd;
    void *map;
    uint64_t size;
    int ifd;
    void (*load)(session_t*);
    capability_t *cap;
};

void set_zero(session_t *session)
{
    session->fd = -1;
    session->map = 0;
    session->size = 0;
    session->ifd = -1;
    session->load = 0;
    session->cap = 0;
}

void handle_change(int fd, void *session)
{
    struct inotify_event ie;
    read(fd, &ie, sizeof(struct inotify_event));
    ((session_t *)session)->load((session_t *)session);
}

void configuration_client_initialize(session_t *session, capability_t *cap, void (*load)(session_t *))
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
                    set_zero(session);
                }else{
                    session->ifd = inotify_init();
                    if(session->ifd > -1){
                        if(inotify_add_watch(session->ifd, cap->config_file, IN_MODIFY) > -1){
                            session->size = st.st_size;
                            session->load = load;
                            session->cap = cap;
                            cap->enlist(session->ifd, &handle_change, session);
                        }else{
                            perror("watch failed");
                            close(session->fd);
                            set_zero(session);
                        }
                    }else{
                        perror("inotify failed");
                        close(session->fd);
                        set_zero(session);
                    }
                }
            }else{
                perror("stat failed");
                close(session->fd);
                session->map = 0;
            }
        }else{
            perror(cap->config_file);
        }
    }
}

void configuration_client_finalize(session_t *session)
{
    session->cap->withdraw(session->ifd);
    munmap(session->map, session->size);
    close(session->fd);
    set_zero(session);
}
