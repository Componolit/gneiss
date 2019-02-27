
#ifndef _BLOCK_H_
#define _BLOCK_H_

#include <base/fixed_stdint.h>

namespace Block
{
    class Client
    {
        private:
            Genode::uint64_t _device;
            Genode::uint64_t _block_count;
            Genode::uint64_t _block_size;

        public:

            enum Kind {NONE, READ, WRITE, SYNC};
            enum Status {
                RAW,
                OK,
                ERROR,
                ACK
            };

            struct Request
            {
                Kind kind;
                Genode::uint8_t uid[16];
                Genode::uint64_t start;
                Genode::uint64_t length;
                Status status;
            };

            Client();
            void initialize(const char *device = nullptr);
            void finalize();
            void submit_read(Request req);
            void submit_sync(Request req);
            void submit_write(
                    Request req,
                    Genode::uint8_t *data,
                    Genode::uint64_t length);
            Request next();
            void read(
                    Request &req,
                    Genode::uint8_t *data,
                    Genode::uint64_t length);
            void acknowledge(Request req);
            bool writable();
            Genode::uint64_t block_count();
            Genode::uint64_t block_size();
    };
}

#endif
