
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
            Genode::uint64_t _buffer_size;
            void *_device; //Block_session in block_client.cc
            void *_callback; //procedure Event (S : Instance);

        protected:
            void callback();

        public:

            Client();
            void *get_instance();
            bool initialized();
            void initialize(
                    void *env,
                    const char *device = nullptr,
                    void *callback = nullptr,
                    Genode::uint64_t buffer_size = 0);
            void finalize();
            bool ready(Request req);
            bool supported(Request req);
            void enqueue_read(Request req);
            void enqueue_write(
                    Request req,
                    Genode::uint8_t *data);
            void enqueue_sync(Request req);
            void enqueue_trim(Request req);
            void submit();
            void read(
                    Request req,
                    Genode::uint8_t *data);
            Request next();
            void release(Request req);
            bool writable();
            Genode::uint64_t block_count();
            Genode::uint64_t block_size();
            Genode::uint64_t maximal_transfer_size();
    };
}

#endif
