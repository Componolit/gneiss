
#ifndef _CAI_CAPABILITY_H_
#define _CAI_CAPABILITY_H_

#include <base/env.h>
#include <base/signal.h>

extern "C" void adafinal();

namespace Cai
{
    struct Env
    {
        enum Status : int {RUNNING = -1, SUCCESS = 0, ERROR = 1};
        int status;
        Genode::Env *env;
        void (*destruct)();
        Genode::Signal_context_capability exit_signal;
    };
}

#endif /* ifndef _CAI_CAPABILITY_H_ */
