
#include <signal.h>
#include <entrypoint.h>
#include <stdio.h>

extern void adainit(void);
extern void cai_component_construct(void);
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

int main(int argc, char *argv[])
{
    sigset_t signal_set;
    int ret;
    sigemptyset(&signal_set);
    sigaddset(&signal_set, SIGINT);
    sigaddset(&signal_set, SIGUSR1);
    sigaddset(&signal_set, SIGIO);
    sigprocmask(SIG_BLOCK, &signal_set, NULL);
    adainit();
    cai_component_construct();
    ret = sigloop(&signal_set);
    adafinal();
    return ret;
}
