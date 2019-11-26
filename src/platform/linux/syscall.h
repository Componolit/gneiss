
#ifndef _GNEISS_SYSCALL_H_
#define _GNEISS_SYSCALL_H_

void gneiss_socketpair(int *fd1, int *fd2);
void gneiss_fork(int *pid);
void gneiss_close(int fd);
void gneiss_waitpid(int pid, int *status);

#endif /* ifndef _GNEISS_SYSCALL_H_ */
