
#include <time.h>
#include <stdint.h>

uint64_t timer_client_clock()
{
    struct timespec t;
    clock_gettime(CLOCK_MONOTONIC_RAW, &t);
    return (t.tv_sec * 1000000000) + (t.tv_nsec);
}
