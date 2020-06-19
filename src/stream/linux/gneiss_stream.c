
#include <sys/types.h>
#include <sys/socket.h>
#include <err.h>

//#define ENABLE_TRACE
#include <trace.h>

void gneiss_stream_read(int fd, void *buf, unsigned *size)
{
    TRACE("socket=%d, buf=%p, size=%u\n", fd, buf, *size);
    ssize_t sz = recv(fd, buf, *size, MSG_DONTWAIT | MSG_PEEK);
    TRACE("sz=%zd\n", sz);
    if(sz < 0){
        warn("%s: recv(fd=%d, buf=%p, size=%u, MSG_DONTWAIT | MSG_PEEK)", __func__, fd, buf, *size);
        *size = 0;
        return;
    }
    *size = sz > *size ? *size : sz;
}

void gneiss_stream_drop(int fd, unsigned size)
{
    TRACE("socket=%d, size=%u\n", fd, size);
    unsigned char buf[size];
    if(recv(fd, &buf, size, MSG_DONTWAIT | MSG_TRUNC) < 0){
        warn("%s: recv(fd=%d, 0, size=%u, MSG_DONTWAIT | MSG_TRUNC)", __func__, fd, size);
    }
}

void gneiss_stream_write(int fd, void *buf, unsigned *size)
{
    TRACE("socket=%d, buf=%p, size=%u\n", fd, buf, *size);
    ssize_t sz = send(fd, buf, *size, MSG_DONTWAIT);
    TRACE("sz=%zd\n", sz);
    if(sz < 0){
        warn("%s: send(fd=%d, buf=%p, size=%u, MSG_DONTWAIT)", __func__, fd, buf, *size);
        *size = 0;
        return;
    }
    *size = sz > *size ? *size : sz;
}
