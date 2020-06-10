
#include <err.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/ioctl.h>

//#define ENABLE_TRACE
#include <trace.h>

void gneiss_packet_send(int socket, void *addr, unsigned *size)
{
    TRACE("socket=%d, addr=%p, size=%u\n", socket, addr, *size);
    struct msghdr message;
    struct iovec iov;
    ssize_t result;

    iov.iov_base = addr;
    iov.iov_len = *size;

    TRACE("msg: %s\n", addr);

    message.msg_name = 0;
    message.msg_namelen = 0;
    message.msg_control = 0;
    message.msg_controllen = 0;
    message.msg_iov = &iov;
    message.msg_iovlen = 1;

    result = sendmsg(socket, &message, MSG_DONTWAIT);
    if(result >= 0){
        *size = result;
    }else{
        warn("%s: sendmsg(socket=%d, message=%p, MSG_DONTWAIT)", __func__, socket, &message);
        *size = 0;
    }
}

void gneiss_packet_receive(int socket, void *addr, unsigned *size)
{
    TRACE("socket=%d, *addr=%p, size=%u\n", socket, addr, *size);
    struct msghdr message;
    struct iovec iov;
    ssize_t recv_len;

    if((int)*size < 1){
        *size = 0;
        return;
    }
    iov.iov_base = addr;
    iov.iov_len = *size;

    message.msg_name = 0;
    message.msg_namelen = 0;
    message.msg_control = 0;
    message.msg_controllen = 0;
    message.msg_iov = &iov;
    message.msg_iovlen = 1;

    recv_len = recvmsg(socket, &message, MSG_DONTWAIT | MSG_TRUNC);
    if(recv_len >= 0){
        *size = recv_len;
    }else{
        warn("%s: recvmsg(socket=%d, message=%p, MSG_DONTWAIT | MSG_TRUNC)", __func__, socket, &message);
        *size = 0;
    }
}
