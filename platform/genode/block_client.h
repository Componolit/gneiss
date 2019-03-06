
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
            Genode::uint64_t _device;
            Genode::uint64_t _block_count;
            Genode::uint64_t _block_size;

        public:

            Client();
            void initialize(const char *device = nullptr);
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
