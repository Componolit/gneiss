
#include <sys/epoll.h>
#include <err.h>

//#define ENABLE_TRACE
#include <trace.h>

void gneiss_epoll_create(int *efd)
{
    *efd = epoll_create1(0);
    TRACE("efd=%d\n", *efd);
    if(*efd < 0){
        warn("%s: epoll_create1(0)", __func__);
    }
}

#define gneiss_epoll_add(name, type) \
    void gneiss_epoll_add_##name(int efd, int fd, type priv, int *success) \
{ \
    TRACE("efd=%d fd=%d\n", efd, fd); \
    struct epoll_event eev; \
    eev.events = EPOLLRDHUP | EPOLLIN; \
    eev.data.name = priv; \
    *success = epoll_ctl(efd, EPOLL_CTL_ADD, fd, &eev); \
    if(*success < 0){ \
        warn("%s: epoll_ctl(efd=%d, EPOLL_CTL_ADD, fd=%d, eev=%p)", __func__, efd, fd, &eev); \
    } \
}

gneiss_epoll_add(fd, int)
gneiss_epoll_add(ptr, void *)

void gneiss_epoll_remove(int efd, int fd, int *success)
{
    TRACE("efd=%d fd=%d\n", efd, fd);
    *success = epoll_ctl(efd, EPOLL_CTL_DEL, fd, 0);
    if(*success < 0){
        warn("%s: epoll_ctl(efd=%d, EPOLL_CTL_DEL, fd=%d, 0)", __func__, efd, fd);
    }
}

#define gneiss_epoll_wait(name, type) \
    void gneiss_epoll_wait_##name(int efd, uint32_t *event, type *priv) \
{ \
    TRACE("efd=%d\n", efd); \
    struct epoll_event eev; \
    eev.events = 0; \
    eev.data.name = 0; \
    if(epoll_wait(efd, &eev, 1, -1) < 0){ \
        warn("%s: epoll_wait(efd=%d, eev=%p, 1, -1)", efd, &eev); \
    } \
    *priv = eev.data.name; \
    *event = eev.events; \
}

gneiss_epoll_wait(fd, int)
gneiss_epoll_wait(ptr, void *)
