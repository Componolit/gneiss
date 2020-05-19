
#include <err.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/ioctl.h>

//#define ENABLE_TRACE
#include <trace.h>

void gneiss_packet_allocate(void **addr, unsigned size)
{
    TRACE("*addr=%p, size=%u\n", *addr, size);
    *addr = malloc(size);
    if(!*addr){
        warn("%s: malloc(size=%u)", __func__, size);
    }
    TRACE("allocated=%p\n", *addr);
}

void gneiss_packet_free(void **addr)
{
    TRACE("*addr=%p\n", *addr);
    free(*addr);
    *addr = 0;
    TRACE("*addr=%p\n", *addr);
}

void gneiss_packet_send(int socket, void *addr, unsigned size)
{
    TRACE("socket=%d, addr=%p, size=%u\n", socket, addr, size);
    struct msghdr message;
    struct iovec iov;

    iov.iov_base = addr;
    iov.iov_len = size;

    TRACE("msg: %s\n", addr);

    message.msg_name = 0;
    message.msg_namelen = 0;
    message.msg_control = 0;
    message.msg_controllen = 0;
    message.msg_iov = &iov;
    message.msg_iovlen = 1;

    if(sendmsg(socket, &message, MSG_DONTWAIT) < 0){
        warn("%s: sendmsg(socket=%d, message=%p, MSG_DONTWAIT)", __func__, socket, &message);
    }
}

void gneiss_packet_receive(int socket, void **addr, unsigned *size)
{
    TRACE("socket=%d, *addr=%p, size=%p\n", socket, *addr, size);
    struct msghdr message;
    struct iovec iov;
    ssize_t recv_len;

    *addr = 0;
    if(ioctl(socket, FIONREAD, size) < 0){
        warn("%s: ioctl(socket=%d, FIONREAD, size=%p)", __func__, socket, size);
        return;
    }
    TRACE("size=%u\n", *size);
    if((int)*size < 1){
        return;
    }
    *addr = malloc(*size);
    if(!*addr){
        warn("%s: malloc(size=%u)", __func__, *size);
        return;
    }
    TRACE("recv addr=%p\n", *addr);
    iov.iov_base = *addr;
    iov.iov_len = *size;

    message.msg_name = 0;
    message.msg_namelen = 0;
    message.msg_control = 0;
    message.msg_controllen = 0;
    message.msg_iov = &iov;
    message.msg_iovlen = 1;

    recv_len = recvmsg(socket, &message, MSG_DONTWAIT | MSG_TRUNC);
    if(recv_len < 0){
        warn("%s: recvmsg(socket=%d, message=%p, MSG_DONTWAIT | MSG_TRUNC)", __func__, socket, &message);
        free(*addr);
        *addr = 0;
        return;
    }
    TRACE("msg: %s\n", *addr);
    if(recv_len < *size){
        *size = recv_len;
    }
}
