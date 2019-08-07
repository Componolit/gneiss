
#ifndef _BLOCK_SERVER_H_
#define _BLOCK_SERVER_H_

#include <base/fixed_stdint.h>

#define Ada __attribute__((annotate("ada")))

namespace Block
{
    struct Request;

    class Server
    {
        friend class Root;
        friend class Block_session_component;
        friend class Block_root;
        friend class Dispatcher;
        private:
             void *_session; //Cai::Block::Block_root in block_root.h
             void *_callback; //procedure Event (S : Instance);
             void *_block_count; //function Block_Count (S : Instance) return Cai.Block.Count;
             void *_block_size; //function Block_Size (S : Instance) return Cai.Block.Size;
             void *_writable; //function Writable (S : Instance) return Boolean

        public:
            Server();
            void *get_instance();
            void initialize(
                    void *env,
                    Genode::uint64_t size,
                    void *callback,
                    void *block_count,
                    void *block_size,
                    void *writable);
            void finalize();
            Ada bool writable();
            void process_request(void *request, int *success);
            void read(void *request, void *buffer);
            void write(void *request, void *buffer);
            void acknowledge(void *request, int *success);
            bool initialized();
            void unblock_client();
    };
}

#endif
