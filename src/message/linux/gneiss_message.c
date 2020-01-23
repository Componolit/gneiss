
#include <err.h>
#include <sys/types.h>
#include <sys/socket.h>

//#define ENABLE_TRACE
#include <trace.h>

void gneiss_message_write(int fd, void *msg, int size)
{
    TRACE("fd=%d msg=%p size=%d\n", fd, msg, size);
    if(send(fd, msg, size, MSG_DONTWAIT) < 0){
        warn("fd=%d msg=%p size=%d", fd, msg, size);
    }
}

void gneiss_message_read(int fd, void *msg, int size)
{
    TRACE("fd=%d msg=%p size=%d\n", fd, msg, size);
    if(recv(fd, msg, size, MSG_DONTWAIT | MSG_TRUNC) < 0){
        warn("fd=%d msg=%p size=%d", fd, msg, size);
    }
}

int gneiss_message_peek(int fd)
{
    TRACE("fd=%d\n", fd);
    return recv(fd, 0, 0, MSG_DONTWAIT | MSG_TRUNC | MSG_PEEK);
}
