
#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <sys/wait.h>

#define ENABLE_TRACE
#include <trace.h>

void gneiss_socketpair(int *fd1, int *fd2)
{
    int fds[2];

    if(socketpair(AF_UNIX, SOCK_SEQPACKET, 0, fds) < 0){
        perror("socketpair");
        *fd1 = -1;
        *fd2 = -1;
    }else{
        *fd1 = fds[0];
        *fd2 = fds[1];
    }
}

void gneiss_fork(int *pid)
{
    *pid = fork();
    if(*pid < 0){
        perror("fork");
    }
}

void gneiss_close (int *fd)
{
    if(*fd < 0){
        return;
    }
    TRACE("fd=%d\n", *fd);
    if(close(*fd)){
        perror("close");
    }
    *fd = -1;
}

void gneiss_waitpid(int pid, int *status)
{
    if(waitpid(pid, status, WNOHANG) < 0){
        perror("waitpid");
    }
    *status = WEXITSTATUS(*status);
}

void gneiss_dup(int oldfd, int *newfd)
{
    *newfd = dup(oldfd);
    if(*newfd < 0){
        perror("dup");
    }
}

void gneiss_write_message(int sock, void *msg, size_t size, int fd)
{
    TRACE("sock=%d msg=%p size=%zu\n", sock, msg, size);
    struct msghdr message;
    struct iovec iov;
    union {
        struct cmsghdr cmsghdr;
        char control[CMSG_SPACE(sizeof(int))];
    } cmsgu;
    struct cmsghdr *cmsg;

    iov.iov_base = msg;
    iov.iov_len = size;
    TRACE("message (%d):", size);
    for(int i = 0; i < size; i++){
        TRACE_CONT(" %02x", ((char *)msg)[i]);
    }
    TRACE_CONT("\n");

    message.msg_name = 0;
    message.msg_namelen = 0;
    message.msg_iov = &iov;
    message.msg_iovlen = 1;

    if(fd >= 0){
        message.msg_control = cmsgu.control;
        message.msg_controllen = sizeof(cmsgu.control);

        cmsg = CMSG_FIRSTHDR(&message);
        cmsg->cmsg_len = CMSG_LEN(sizeof(int));
        cmsg->cmsg_level = SOL_SOCKET;
        cmsg->cmsg_type = SCM_RIGHTS;
        *((int *)CMSG_DATA(cmsg)) = fd;
    }else{
        message.msg_control = 0;
        message.msg_controllen = 0;
    }
    if(sendmsg(sock, &message, 0) < 0){
        perror("sendmsg");
    }
}

void gneiss_peek_message(int sock, void *msg, size_t size, int *fd, int *length, int *trunc)
{
    TRACE("sock=%d msg=%p size=%zu fd=%p length=%p trunc=%p\n", sock, msg, size, fd, length, trunc);
    ssize_t ssize;
    struct msghdr message;
    struct iovec iov;
    union {
        struct cmsghdr cmsghdr;
        char control[CMSG_SPACE(sizeof(int))];
    } cmsgu;
    struct cmsghdr *cmsg;

    iov.iov_base = msg;
    iov.iov_len = size;

    message.msg_name = 0;
    message.msg_namelen = 0;
    message.msg_iov = &iov;
    message.msg_iovlen = 1;
    message.msg_control = cmsgu.control;
    message.msg_controllen = sizeof(cmsgu.control);
    *fd = -1;
    *length = recvmsg(sock, &message, MSG_PEEK | MSG_TRUNC);
    if(*length < 0){
        perror("recvmsg");
        *length = 0;
        return;
    }
    TRACE("message (%d):", *length);
    for(int i = 0; i < *length; i++){
        TRACE_CONT(" %02x", ((char *)msg)[i]);
    }
    TRACE_CONT("\n");
    *trunc = !!(message.msg_flags & MSG_TRUNC);
    cmsg = CMSG_FIRSTHDR(&message);
    if(cmsg && cmsg->cmsg_len == CMSG_LEN(sizeof(int))
            && cmsg->cmsg_level == SOL_SOCKET
            && cmsg->cmsg_type == SCM_RIGHTS){
        *fd = *((int *)CMSG_DATA(cmsg));
    }
}

void gneiss_drop_message(int sock)
{
    TRACE("sock=%d\n", sock);
    struct msghdr message;
    struct iovec iov;
    union {
        struct cmsghdr cmsghdr;
        char control[CMSG_SPACE(sizeof(int))];
    } cmsgu;
    struct cmsghdr *cmsg;

    iov.iov_base = 0;
    iov.iov_len = 0;

    message.msg_name = 0;
    message.msg_namelen = 0;
    message.msg_iov = &iov;
    message.msg_iovlen = 1;
    message.msg_control = cmsgu.control;
    message.msg_controllen = sizeof(cmsgu.control);
    if(recvmsg(sock, &message, MSG_TRUNC) < 0){
        perror("recvmsg");
        return;
    }
}
