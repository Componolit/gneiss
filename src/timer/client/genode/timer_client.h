
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

            public:
                Client();
                bool initialized();
                void initialize(void *capability);
                Genode::uint64_t clock();
                void finalize();
        };
    }
}

#endif /* ifndef _TIMER_CLIENT_H_ */
