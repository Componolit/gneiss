
#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/un.h>

void gneiss_socketpair(int *fd1, int *fd2)
{
    int fds[2];

    if(socketpair(AF_UNIX, SOCK_STREAM, 0, fds) < 0){
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
    close(*fd);
    *fd = -1;
}
