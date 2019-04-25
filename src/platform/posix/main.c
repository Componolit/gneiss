
#include <signal.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <entrypoint.h>
#include <capability.h>


extern void adainit(void);
extern void cai_component_construct(void *);
extern void adafinal(void);

int sigloop(sigset_t *signal_set)
{
    int sig;
    for(;;){
        siginfo_t sig;
        if(sigwaitinfo(signal_set, &sig) == -1){
            perror("Failed to dispatch signal");
        }
        switch(sig.si_signo){
            case SIGINT:
                fprintf(stderr, "Received signal %d, exiting...\n", sig.si_signo);
                return 0;
            case SIGUSR1:
                entry_sigusr1(&sig);
                break;
            case SIGIO:
                entry_sigio(&sig);
                break;
            default:
                fprintf(stderr, "Received unhandled signal: %d\n", sig.si_signo);
                return 1;
        }
    }
    return 1;
}

static capability_t capability;

int main(int argc, char *argv[])
{
    sigset_t signal_set;
    int ret;
    memset(&capability, 0, sizeof(capability));
    if(argc == 2){
        capability.config_file = malloc(strlen(argv[1]) + 1);
        if(capability.config_file){
            strcpy(capability.config_file, argv[1]);
        }
    }
    sigemptyset(&signal_set);
    sigaddset(&signal_set, SIGINT);
    sigaddset(&signal_set, SIGUSR1);
    sigaddset(&signal_set, SIGIO);
    sigprocmask(SIG_BLOCK, &signal_set, NULL);
    adainit();
    cai_component_construct(&capability);
    ret = sigloop(&signal_set);
    adafinal();
    return ret;
}
