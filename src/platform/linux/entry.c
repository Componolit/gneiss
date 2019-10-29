
#include <signal.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/signalfd.h>
#include <entrypoint.h>
#include <capability.h>
#include <list.h>

extern void adainit(void);
extern void componolit_interfaces_component_construct(void *);
extern void componolit_interfaces_component_destruct(void);
extern void adafinal(void);

struct isg
{
    int fd;
    void (*callback)(int, void *);
    void *context;
};

static capability_t capability;
static list_t signal_registry;
static fd_set fds;

void enlist(int fd, void (*callback)(int, void *), void *context)
{
    struct isg i;
    i.fd = fd;
    i.callback = callback;
    i.context = context;
    list_append(signal_registry, (void *)&i, sizeof(i));
}

static int is_fd(const void *i1, const void *i2, size_t size){
    return !(((struct isg*)i1)->fd == ((struct isg*)i2)->fd);
}

void withdraw(int fd)
{
    struct isg i;
    i.fd = fd;
    i.callback = 0;
    i.context = 0;
    list_remove(signal_registry, list_find(signal_registry, (void *)&i, sizeof(i), &is_fd));
}

static int initialize_fds(list_t *item, unsigned size, void *max)
{
    int fd = ((struct isg *)((*item)->content))->fd;
    FD_SET(fd, &fds);
    if(fd > *(int *)max){
        *(int *)max = fd;
    }
    return 0;
}

static int execute_events(list_t *item, unsigned size, void *arg)
{
    struct isg *i = (struct isg *)((*item)->content);
    if(FD_ISSET(i->fd, &fds)){
        if(i->callback){
            i->callback(i->fd, i->context);
        }
    }
}

static void event_loop()
{
    int max;
    while(capability.status == COMPONENT_RUNNING){
        FD_ZERO(&fds);
        max = 0;
        list_foreach(signal_registry, &initialize_fds, &max);
        select(max + 1, &fds, 0, 0, 0);
        list_foreach(signal_registry, &execute_events, 0);
    }
}

void vacate(int status)
{
    capability.status = status;
}

static void __attribute__((constructor)) component_init(void)
//int main_loop(int argc, char *argv[])
{
    sigset_t signal_set;
    memset(&capability, 0, sizeof(capability));

    signal_registry = list_new();
    capability.status = COMPONENT_RUNNING;
    capability.enlist = &enlist;
    capability.withdraw = &withdraw;

    //  if(argc == 2){
    //      capability.config_file = malloc(strlen(argv[1]) + 1);
    //      if(capability.config_file){
    //          strcpy(capability.config_file, argv[1]);
    //      }
    //  }
    sigemptyset(&signal_set);
    sigaddset(&signal_set, SIGINT);
    sigaddset(&signal_set, SIGUSR1);
    sigaddset(&signal_set, SIGIO);
    sigprocmask(SIG_BLOCK, &signal_set, NULL);
    enlist(signalfd(-1, &signal_set, 0), &entry_signal, 0);
    adainit();
    componolit_interfaces_component_construct(&capability);
    event_loop();
    componolit_interfaces_component_destruct();
    adafinal();
    list_delete(signal_registry);
    //  return capability.status;
}
