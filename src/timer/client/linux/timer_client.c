
#include <time.h>
#include <stdint.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/timerfd.h>
#include <capability.h>

typedef struct timer_session
{
    int tfd;
    void (*event)(void);
    capability_t *cap;
} timer_session_t;

uint64_t timer_client_clock()
{
    struct timespec t;
    clock_gettime(CLOCK_MONOTONIC_RAW, &t);
    return (t.tv_sec * 1000000000) + (t.tv_nsec);
}

void timer_client_finalize(timer_session_t **session);
void handle_timeout(int fd, void *session);

void timer_client_initialize(timer_session_t **session, capability_t *capability, void (*event)(void))
{
    *session = malloc(sizeof(timer_session_t));
    if(*session){
        (*session)->tfd = timerfd_create(CLOCK_MONOTONIC, 0);
        if((*session)->tfd >= 0){
            (*session)->event = event;
            (*session)->cap = capability;
            capability->enlist((*session)->tfd, &handle_timeout, *session);
        }else{
            perror("timerfd_create failed");
            timer_client_finalize(session);
        }
    }else{
        perror("malloc failed");
    }
}

void handle_timeout(int fd, void *session)
{
    uint64_t mods;
    read(fd, &mods, 8);
    ((timer_session_t *)session)->event();
}

void timer_client_set_timeout(timer_session_t *session, uint64_t duration)
{
    struct timespec const null_time = {0, 0};
    struct timespec const ev_time = {duration / 1000000000, duration % 1000000000};
    struct itimerspec newtime = {null_time, null_time};
    struct itimerspec oldtime = {null_time, null_time};
    timerfd_settime(session->tfd, 0, &newtime, &oldtime);
    newtime.it_value = ev_time;
    timerfd_settime(session->tfd, 0, &newtime, &oldtime);
}

void timer_client_finalize(timer_session_t **session)
{
    if((*session)->cap && (*session)->tfd >= 0){
        (*session)->cap->withdraw((*session)->tfd);
        close((*session)->tfd);
    }
    free(*session);
    *session = 0;
}
