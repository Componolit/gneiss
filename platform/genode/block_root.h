
#ifndef _BLOCK_ROOT_H_
#define _BLOCK_ROOT_H_

#include <block_session/block_session.h>
#include <block/request_stream.h>
#include <base/attached_ram_dataspace.h>

namespace Cai
{
    namespace Block
    {
        struct Block_session_component;
        struct Block_root;
    }
}

struct Cai::Block::Block_session_component : Genode::Rpc_object<::Block::Session>,
                                             ::Block::Request_stream
{
    Genode::Entrypoint &_ep;
    Cai::Block::Block_root *_server;

    Block_session_component(
            Genode::Region_map &rm,
            Genode::Dataspace_capability ds,
            Genode::Entrypoint &ep,
            Genode::Signal_context_capability sigh,
            Cai::Block::Block_root *server);

    ~Block_session_component();

    void info(::Block::sector_t *count, Genode::size_t *size, ::Block::Session::Operations *ops) override;

    void sync() override;

    Genode::Capability<::Block::Session::Tx> tx_cap() override;

    private:

    Block_session_component(const Block_session_component &);
    const Block_session_component &operator=(const Block_session_component &);

};

struct Cai::Block::Block_root
{
    Genode::Env &_env;
    Genode::Signal_handler<Cai::Block::Block_root> _sigh;
    Genode::Attached_ram_dataspace _ds;
    void (*_callback)(); //procedure Event;
    Genode::uint64_t (*_block_count)(void *); //function Block_Count (S : Instance) return Cai.Block.Count;
    Genode::uint64_t (*_block_size)(void *); //function Block_Size (S : Instance) return Cai.Block.Size;
    Genode::uint64_t (*_maximal_transfer_size)(void *); //function Maximal_Transfer_Size (S : Instance) return Cai.Block.Unsigned_long;
    void *_writable; //function Writable (S : Instance) return Boolean
    Cai::Block::Block_session_component _session;

    Block_root(Genode::Env &env,
               Genode::size_t ds_size,
               void (*callback)(),
               Genode::uint64_t (*block_count)(void *),
               Genode::uint64_t (*block_size)(void *),
               Genode::uint64_t (*maximal_transfer_size)(void *),
               void *writable);
    void handler();
    Genode::Capability<Genode::Session> cap();

    private:

    Block_root(const Block_root &);
    const Block_root &operator=(const Block_root &);
};

#endif /* ifndef _BLOCK_ROOT_H_ */
