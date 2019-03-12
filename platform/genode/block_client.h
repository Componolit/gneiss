
#ifndef _BLOCK_CLIENT_H_
#define _BLOCK_CLIENT_H_

#include <base/fixed_stdint.h>

#include <block.h>

namespace Block
{
    struct Request;

    class Client
    {
        private:
            Genode::uint64_t _block_count;
            Genode::uint64_t _block_size;
            void *_device; //Block_session in block_client.cc
            void *_callback; //procedure Event (S : in out State);
            void *_callback_state; //State

        protected:
            void callback();

        public:

            Client();
            void initialize(
                    const char *device = nullptr,
                    void *callback = nullptr,
                    void *callback_state = nullptr);
            void finalize();
            void submit_read(Request req);
            void submit_write(
                    Request req,
                    Genode::uint8_t *data,
                    Genode::uint64_t length);
            void read(
                    Request &req,
                    Genode::uint8_t *data,
                    Genode::uint64_t length);
            void sync();
            Request next();
            void acknowledge(Request req);
            bool writable();
            Genode::uint64_t block_count();
            Genode::uint64_t block_size();
    };
}

#endif
