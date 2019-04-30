
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
    int ifd;
    void (*parse)(void *, uint64_t);
    capability_t *cap;
};

void set_zero(session_t *session)
{
    session->ifd = -1;
    session->parse = 0;
    session->cap = 0;
}

void configuration_client_load(session_t *session)
{
    struct stat st;
    void *map;
    int fd = open(session->cap->config_file, O_RDONLY | O_NOFOLLOW);
    if(fd > -1){
        if(!fstat(fd, &st)){
            map = mmap(0, st.st_size, PROT_READ, MAP_PRIVATE, fd, 0);
            if(map == MAP_FAILED || map == 0){
                perror("map failed");
                session->parse(0, 0);
            }else{
                session->parse(map, st.st_size);
                munmap(map, st.st_size);
                close(fd);
            }
        }else{
            close(fd);
            session->parse(0, 0);
            perror("stat failed");
        }
    }else{
        session->parse(0, 0);
        perror(session->cap->config_file);
    }
}

void handle_change(int fd, void *session)
{
    struct inotify_event ie;
    read(fd, &ie, sizeof(struct inotify_event));
    configuration_client_load((session_t *)session);
}

void configuration_client_initialize(session_t *session, capability_t *cap, void (*parse)(void *, uint64_t))
{
    session->ifd = inotify_init();
    if(session->ifd > -1){
        if(inotify_add_watch(session->ifd, cap->config_file,
                             IN_MODIFY | IN_DELETE_SELF | IN_CLOSE_WRITE) > -1){
            session->parse = parse;
            session->cap = cap;
            cap->enlist(session->ifd, &handle_change, session);
        }else{
            perror("watch failed");
            set_zero(session);
        }
    }else{
        perror("inotify failed");
        set_zero(session);
    }
}

void configuration_client_finalize(session_t *session)
{
    session->cap->withdraw(session->ifd);
    close(session->ifd);
    set_zero(session);
}
