
#ifndef _GNEISS_TRACE_H_
#define _GNEISS_TRACE_H_

#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>

#ifdef ENABLE_TRACE

#define TRACE(...) fprintf(stderr, "[%d] %s:%d (%s): ", getpid(), __FILE__, __LINE__, __func__);\
                   fprintf(stderr, __VA_ARGS__)

#else

#define TRACE(...)

#endif

#endif /* ifndef _GNEISS_TRACE_H_ */
