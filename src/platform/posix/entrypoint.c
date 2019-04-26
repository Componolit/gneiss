
#include <stdio.h>
#include <unistd.h>
#include <sys/signalfd.h>
#include <entrypoint.h>
#include <block_client.h>

void entry_signal(int fd, void *context)
{
    struct signalfd_siginfo sfdsi;
    read(fd, &sfdsi, sizeof(struct signalfd_siginfo));
    switch(sfdsi.ssi_signo){
        case SIGIO:
            if(sfdsi.ssi_code == -4 && sfdsi.ssi_ptr){
                ((block_client_t *)(sfdsi.ssi_ptr))->event();
            }
            break;
        case SIGINT:
            fprintf(stderr, "Received signal %d, exiting...\n", sfdsi.ssi_signo);
            _exit(0);
            break;
        default:
            fprintf(stderr, "Received unhandled signal: %d\n", sfdsi.ssi_signo);
            _exit(1);
            break;
    }
}
