#define _GNU_SOURCE

#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <sys/wait.h>
#include <sys/stat.h>
#include <sys/fcntl.h>
#include <sys/mman.h>

//#define ENABLE_TRACE
#include <trace.h>

#ifndef min
#define min(a,b)            (((a) < (b)) ? (a) : (b))
#endif

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

void gneiss_write_message(int sock, void *msg, size_t size, int *fd, int num)
{
    TRACE("sock=%d msg=%p size=%zu fd=%p num=%d\n", sock, msg, size, fd, num);
    struct msghdr message;
    struct iovec iov;
    union {
        struct cmsghdr cmsghdr;
        char control[CMSG_SPACE(sizeof(int) * num)];
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

    if(num > 0){
        message.msg_control = cmsgu.control;
        message.msg_controllen = sizeof(cmsgu.control);

        cmsg = CMSG_FIRSTHDR(&message);
        cmsg->cmsg_len = CMSG_LEN(sizeof(int) * num);
        cmsg->cmsg_level = SOL_SOCKET;
        cmsg->cmsg_type = SCM_RIGHTS;
        memcpy(CMSG_DATA(cmsg), fd, sizeof(int) * num);
    }else{
        message.msg_control = 0;
        message.msg_controllen = 0;
    }
    if(sendmsg(sock, &message, 0) < 0){
        perror("sendmsg");
    }
}

void gneiss_peek_message(int sock, void *msg, size_t size, int *fd, int num, int *length, int *trunc)
{
    TRACE("sock=%d msg=%p size=%zu fd=%p num=%d length=%p trunc=%p\n", sock, msg, size, fd, num, length, trunc);
    ssize_t ssize;
    struct msghdr message;
    struct iovec iov;
    union {
        struct cmsghdr cmsghdr;
        char control[CMSG_SPACE(sizeof(int) * num)];
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
    for(int i = 0; i < num; i++){
        fd[i] = -1;
    }
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
    if(cmsg && cmsg->cmsg_level == SOL_SOCKET
            && cmsg->cmsg_type == SCM_RIGHTS){
        memcpy(fd, CMSG_DATA(cmsg), min(sizeof(int) * num, cmsg->cmsg_len));
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

void gneiss_fputs(char *str)
{
    fputs(str, stderr);
}

void gneiss_open(char *path, int *fd, int writable)
{
    *fd = open(path, writable ? O_RDWR : O_RDONLY);
    if(*fd < 0){
        perror("open");
    }
}

void gneiss_memfd_create(char *name, int *fd, int size)
{
    *fd = memfd_create(name, MFD_ALLOW_SEALING);
    if(*fd < 0){
        perror("memfd_create");
        return;
    }
    if(ftruncate(*fd, size) < 0){
        perror("ftruncate");
        close(*fd);
        *fd = -1;
        return;
    }
    if(fcntl(*fd, F_ADD_SEALS, F_SEAL_SHRINK) < 0){
        perror("fcntl(F_SEAL_SHRINK)");
        close(*fd);
        *fd = -1;
        return;
    }
    if(fcntl(*fd, F_ADD_SEALS, F_SEAL_GROW) < 0){
        perror("fcntl(F_SEAL_GROW)");
        close(*fd);
        *fd = -1;
        return;
    }
    if(fcntl(*fd, F_ADD_SEALS, F_SEAL_SEAL) < 0){
        perror("fcntl(F_SEAL_SEAL)");
        close(*fd);
        *fd = -1;
        return;
    }
}
