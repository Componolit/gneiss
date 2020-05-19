#define _GNU_SOURCE

#include <err.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <sys/wait.h>
#include <sys/stat.h>
#include <sys/fcntl.h>
#include <sys/mman.h>
#include <sys/timerfd.h>

//#define ENABLE_TRACE
#include <trace.h>

#ifndef min
#define min(a,b)            (((a) < (b)) ? (a) : (b))
#endif

void gneiss_socketpair(int *fd1, int *fd2)
{
    int fds[2];

    if(socketpair(AF_UNIX, SOCK_SEQPACKET, 0, fds) < 0){
        warn("%s: socketpair(AF_UNIX, SOCK_SEQPACKET, 0, fds=%p)", __func__, fds);
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
        warn("%s: fork()", __func__);
    }
}

void gneiss_close (int *fd)
{
    if(*fd < 0){
        return;
    }
    TRACE("fd=%d\n", *fd);
    if(close(*fd)){
        warn("%s: close(fd=%d)", __func__, *fd);
    }
    *fd = -1;
}

void gneiss_waitpid(int pid, int *status)
{
    if(waitpid(pid, status, WNOHANG) < 0){
        warn("%s: waitpid(pid=%d, status=%p, WNOHANG)", __func__, pid, status);
    }
    *status = WEXITSTATUS(*status);
}

void gneiss_dup(int oldfd, int *newfd)
{
    *newfd = dup(oldfd);
    if(*newfd < 0){
        warn("%s: dup(oldfd=%d)", __func__, oldfd);
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
    if(sendmsg(sock, &message, MSG_DONTWAIT) < 0){
        warn("%s: sendmsg(sock=%d)", __func__, sock);
    }
}

static void read_message(int sock, void *msg, size_t size, int *fd, int num, int *length, int *trunc, int flags)
{
    TRACE("sock=%d msg=%p size=%zu fd=%p num=%d length=%p trunc=%p flags=%u\n", sock, msg, size, fd, num, length, trunc, flags);
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
    *length = recvmsg(sock, &message, flags);
    if(*length < 0){
        warn("%s: recvmsg(sock=%d, message=%p, flags=%d)", __func__, sock, &message, flags);
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

void gneiss_peek_message(int sock, void *msg, size_t size, int *fd, int num, int *length, int *trunc)
{
    TRACE("\n");
    read_message(sock, msg, size, fd, num, length, trunc, MSG_PEEK | MSG_TRUNC | MSG_DONTWAIT);
}

void gneiss_read_message(int sock, void *msg, size_t size, int *fd, int num, int *length, int *trunc, int block)
{
    TRACE("\n");
    read_message(sock, msg, size, fd, num, length, trunc, MSG_TRUNC | (block ? 0 : MSG_DONTWAIT));
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
        warn("%s: recvmsg(sock=%d, message=%p, MSG_TRUNC)", __func__, sock, &message);
    }
}

void gneiss_fputs(char *str)
{
    fputs(str, stderr);
}

void gneiss_open(const char *path, int *fd, int writable)
{
    TRACE("path=%s fd=%p writable=%d\n", path, fd, writable);
    *fd = open(path, writable ? O_RDWR : O_RDONLY);
    if(*fd < 0){
        warn("%s: open(path=%s, writable=%d)", __func__, path, writable);
    }
}

void gneiss_memfd_seal(int fd, int *success)
{
    TRACE("fd=%d success=%p\n", fd, success);
    *success = 0;
    if(fcntl(fd, F_ADD_SEALS, F_SEAL_SHRINK) < 0){
        warn("%s: fcntl(fd=%d, F_ADD_SEALS, F_SEAL_SHRINK)", __func__, fd);
        return;
    }
    if(fcntl(fd, F_ADD_SEALS, F_SEAL_GROW) < 0){
        warn("%s: fcntl(fd=%d, F_ADD_SEALS, F_SEAL_GROW)", __func__, fd);
        return;
    }
    if(fcntl(fd, F_ADD_SEALS, F_SEAL_SEAL) < 0){
        warn("%s: fcntl(fd=%d, F_ADD_SEALS, F_SEAL_SEAL)", __func__, fd);
        return;
    }
    *success = 1;
}

int gneiss_fstat_size(int fd)
{
    TRACE("fd=%d\n", fd);
    struct stat st;
    if(fstat(fd, &st) < 0){
        warn("%s: fstat(fd=%d, st=%p)", __func__, fd, &st);
        return 0;
    }
    return st.st_size;
}

void gneiss_mmap(int fd, void **map, int writable)
{
    TRACE("fd=%d *map=%p writable=%d\n", fd, *map, writable);
    const int size = gneiss_fstat_size(fd);
    *map = mmap(0, size, writable ? PROT_READ | PROT_WRITE : PROT_READ, MAP_SHARED, fd, 0);
    if(*map == MAP_FAILED){
        warn("%s: mmap(0, size=%d, writable=%d, MAP_SHARED, fd=%d, 0)", __func__, size, writable, fd);
        *map = 0x0;
    }
}

void gneiss_munmap(int fd, void **map)
{
    TRACE("fd=%d *map=%p\n", fd, *map);
    const int size = gneiss_fstat_size(fd);
    if(munmap(*map, size) < 0){
        warn("%s: munmap(fd=%d size=%d)", __func__, fd, gneiss_fstat_size(fd));
    }
    *map = 0x0;
}

void gneiss_timerfd_create(int *fd)
{
    TRACE("fd=%p\n", fd);
    *fd = timerfd_create(CLOCK_MONOTONIC, TFD_NONBLOCK);
    if(*fd < 0){
        warn("%s: timerfd_create(CLOCK_MONOTONIC, TFD_NONBLOCK)", __func__);
    }
}
