
#ifndef _BLOCK_DISPATCHER_H_
#define _BLOCK_DISPATCHER_H_

#include <base/fixed_stdint.h>

namespace Block
{
    class Dispatcher
    {
        friend class Root;
        private:
            void *_root; //Cai::Block::Root in block_dispatcher.cc
            void *_handler; //procedure Event(S : Instance);
            Genode::uint32_t _tag;

        public:
            Dispatcher();
            void initialize(
                    void *env,
                    void *callback = nullptr);
            void finalize();
            void announce();
            void dispatch(void *dcap);
            char *label_content(void *dcap);
            Genode::uint64_t label_length(void *dcap);
            Genode::uint64_t session_size(void *dcap);
            void session_accept(void *dcap, void *session);
            bool session_cleanup(void *dcap, void *session);
            void *get_capability();
    };
}

#endif /* ifndef _BLOCK_DISPATCHER_H_ */
