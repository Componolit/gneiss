
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

        public:
            Dispatcher();
            void *get_instance();
            void initialize(
                    void *callback = nullptr);
            void finalize();
            void announce();
            __attribute__((annotate("ada"))) void dispatch();
            char *label_content();
            Genode::uint64_t label_length();
            Genode::uint64_t session_size();
            void session_accept(void *session);
            bool session_cleanup(void *session);
    };
}

#endif /* ifndef _BLOCK_DISPATCHER_H_ */
