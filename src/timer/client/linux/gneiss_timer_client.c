
#include <time.h>
#include <sys/timerfd.h>
#include <err.h>

//#define ENABLE_TRACE
#include <trace.h>

#define NANO 1000000000

void gneiss_timer_set(int fd, unsigned long long duration)
{
    TRACE("fd=%d duration=%llu\n", fd, duration);
    struct itimerspec its = {{0, 0}, {0, 0}};
    if(timerfd_settime(fd, 0, &its, 0) < 0){
        warn("fd=%d duration=%llu", fd, duration);
    }
    its.it_value.tv_sec = duration / NANO;
    its.it_value.tv_nsec = duration - (its.it_value.tv_sec * NANO);
    if(timerfd_settime(fd, 0, &its, 0) < 0){
        warn("fd=%d duration=%llu", fd, duration);
    }
}

unsigned long long gneiss_timer_get(int fd)
{
    TRACE("fd=%d\n");
    struct timespec ts = {0, 0};
    if(clock_gettime(CLOCK_MONOTONIC, &ts) < 0){
        warn("fd=%d", fd);
    }
    return ts.tv_sec * NANO + ts.tv_nsec;
}

void gneiss_timer_read(int fd)
{
    TRACE("fd=%d\n", fd);
    unsigned long long u;
    if(read(fd, &u, 8) < 0){
        warn("fd=%d", fd);
    }
}
