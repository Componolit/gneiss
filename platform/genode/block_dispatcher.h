
#ifndef _BLOCK_DISPATCHER_H_
#define _BLOCK_DISPATCHER_H_

#include <base/fixed_stdint.h>

namespace Block
{
    class Dispatcher
    {
        friend class Root;
        private:
            void *_root;
            void *_handler;
            void *_state;

        public:
            Dispatcher();
            void initialize(
                    void *callback = nullptr,
                    void *state = nullptr);
            void finalize();
            void announce();
            __attribute__((annotate("ada"))) void dispatch(
                    const char *label,
                    Genode::uint64_t length,
                    void **session);
    };
}

#endif /* ifndef _BLOCK_DISPATCHER_H_ */
