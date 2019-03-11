
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
            friend class Block_session_component;
            friend class Block_root;

             void *_session;
             void *_state;
             void *_callback;
             void *_block_count;
             void *_block_size;
             void *_maximal_transfer_size;
             void *_writable;

        public:

            Server();
            void initialize(
                    const char *label,
                    Genode::uint64_t length,
                    void *callback,
                    void *block_count,
                    void *block_size,
                    void *maximal_transfer_size,
                    void *writable);
            void finalize();
            Ada bool writable();
            Ada bool ready();
            void next_request(Request *request);
            void read(Request request, void *buffer, Genode::uint64_t size, bool *success);
            void write(Request request, void *buffer, Genode::uint64_t size, bool *success);
            void acknowledge(Request &request);
    };
}

#endif
