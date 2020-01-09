
#ifndef _GNEISS_H_
#define _GNEISS_H_

#include <base/env.h>
#include <base/signal.h>

namespace Gneiss
{
    struct Capability;
    class Limited;
}

struct Gneiss::Capability
{
    enum Status : int {RUNNING = -1, SUCCESS = 0, ERROR = 1};
    int status;
    Genode::Env *env;
    void (*destruct)();
    Genode::Signal_context_capability exit_signal;
};

class Gneiss::Limited
{
    private:
        Limited(const Limited&);
        Limited &operator = (Limited const &);
};

#endif /* ifndef _GNEISS_H_ */
