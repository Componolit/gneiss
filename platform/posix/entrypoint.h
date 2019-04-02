
#ifndef _ENTRYPOINT_H_
#define _ENTRYPOINT_H_

#include <signal.h>

void entry_sigusr1(siginfo_t *info);

void entry_sigio(siginfo_t *info);

#endif /* ifndef _ENTRYPOINT_H_ */
