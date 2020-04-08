
#ifndef _BLOCK_CLIENT_H_
#define _BLOCK_CLIENT_H_

#include <base/fixed_stdint.h>

namespace Block
{
    class Client
    {
        private:
            Genode::uint64_t _block_count;
            Genode::uint64_t _block_size;
            void *_device; //Block_session in block_client.cc
            void *_callback; //procedure Event;
            void *_rw; //procedure Crw (Session, Kind, Start, Length, Data, Ctx)
            void *_env; //Cai::Env
            Genode::uint32_t _tag;

        protected:
            void callback();
            void init();

        public:

            Client();
            void *get_instance();
            void initialize(
                    void *env,
                    const char *device = nullptr,
                    void *callback = nullptr,
                    void *rw = nullptr,
                    Genode::uint64_t buffer_size = 0);
            void finalize();
            void allocate_request (void *request,
                                   int opcode,
                                   Genode::uint64_t start,
                                   unsigned long length,
                                   unsigned long tag,
                                   int *result);
            void update_response_queue (int *status,
                                        unsigned long *tag,
                                        int *success);
            void enqueue(void *request);
            void submit();
            void read_write(void *request, void *context);
            void release(void *request);
            bool writable();
            Genode::uint64_t block_count();
            Genode::uint64_t block_size();
    };
}

#endif
