
#ifndef _BLOCK_H_
#define _BLOCK_H_

#include <base/fixed_stdint.h>

namespace Block
{
    class Client
    {
        private:
            Genode::uint64_t _device;

        public:

            enum {BLOCK_SIZE = 512};
            enum Kind {NONE, READ, WRITE, SYNC};

            struct Request
            {
                Kind kind;
                Genode::uint8_t uid[16];
                Genode::uint64_t start;
                Genode::uint64_t length;
                bool success;
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
            void acknowledge_read(
                    Request req,
                    Genode::uint8_t *data,
                    Genode::uint64_t length);
            void acknowledge_sync(Request req);
            void acknowledge_write(Request req);
    };
}

#endif
