
#include <err.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/ioctl.h>

void gneiss_packet_allocate(void **addr, unsigned size)
{
    *addr = malloc(size);
    if(!*addr){
        warn("%s: malloc(size=%u)", __func__, size);
    }
}

void gneiss_packet_free(void **addr)
{
    free(*addr);
    *addr = 0;
}

void gneiss_packet_send(int socket, void *addr, unsigned size)
{
    struct msghdr message;
    struct iovec iov;

    iov.iov_base = addr;
    iov.iov_len = size;

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
    struct msghdr message;
    struct iovec iov;
    ssize_t recv_len;

    if(ioctl(socket, FIONREAD, size) < 0){
        warn("%s: ioctl(socket=%d, FIONREAD, size=%p)", __func__, socket, size);
        return;
    }
    if((int)*size < 0){
        return;
    }
    *addr = malloc(*size);
    if(!*addr){
        warn("%s: malloc(size=%u)", __func__, *size);
        return;
    }
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
    if(recv_len < *size){
        *size = recv_len;
    }
}
