
#ifndef _TIMER_CLIENT_H_
#define _TIMER_CLIENT_H_

#include <base/fixed_stdint.h>

namespace Cai
{
    namespace Timer
    {
        class Client
        {
            private:
                void *_session;
                Genode::uint32_t _index;

            public:
                Client();
                bool initialized();
                void initialize(void *capability, void *callback, const char *label);
                Genode::uint64_t clock();
                void set_timeout(Genode::uint64_t);
                void finalize();
        };
    }
}

#endif /* ifndef _TIMER_CLIENT_H_ */
