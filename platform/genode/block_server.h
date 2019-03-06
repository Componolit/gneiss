
#ifndef _BLOCK_SERVER_H_
#define _BLOCK_SERVER_H_

#include <base/fixed_stdint.h>

#define Ada __attribute__((annotate("ada")))

namespace Block
{
    struct Request;

    class Server
    {
        private:

             void *_session;
             void *_state;

        public:

            Server(void *session, void *state);
            Ada void initialize(const char *label, Genode::uint64_t length);
            Ada void finalize();
            Ada Genode::uint64_t block_count();
            Ada Genode::uint64_t block_size();
            Ada bool writable();
            Ada Genode::uint64_t maximal_transfer_size();
            Ada void read(
                    Genode::uint8_t buffer[],
                    Genode::uint64_t size,
                    Request &req);
            Ada void write(
                    Genode::uint8_t buffer[],
                    Genode::uint64_t size,
                    Request &req);
            Ada void sync();
            void acknowledge(Request &req);
            static Ada Genode::uint64_t state_size();
    };
}

#endif
