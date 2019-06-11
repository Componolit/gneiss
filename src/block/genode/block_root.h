
#ifndef _BLOCK_ROOT_H_
#define _BLOCK_ROOT_H_

#include <block_session/block_session.h>
#include <block/request_stream.h>
#include <base/attached_ram_dataspace.h>
#include <cai_capability.h>

namespace Cai
{
#include <block_server.h>
    namespace Block
    {
        struct Block_session_component;
        struct Block_root;
    }
}

struct Cai::Block::Block_session_component : Genode::Rpc_object<::Block::Session>, ::Block::Request_stream
{
    Genode::Entrypoint &_ep;
    Cai::Block::Server &_server;

    Block_session_component(
            Genode::Region_map &rm,
            Genode::Dataspace_capability ds,
            Genode::Entrypoint &ep,
            Genode::Signal_context_capability sigh,
            Cai::Block::Server &server);

    ~Block_session_component();

    ::Block::Session::Info info() const override;

    Genode::Capability<::Block::Session::Tx> tx_cap() override;
};

struct Cai::Block::Block_root
{
    Cai::Env *_env;
    Genode::Signal_handler<Cai::Block::Block_root> _sigh;
    Cai::Block::Server &_server;
    Genode::Attached_ram_dataspace _ds;
    Cai::Block::Block_session_component _session;

    Block_root(Cai::Env *env, Cai::Block::Server &server, Genode::size_t ds_size);
    void handler();
    Genode::Capability<Genode::Session> cap();

    private:
        Block_root(const Block_root&);
        Block_root &operator = (Block_root const &);
};

#endif /* ifndef _BLOCK_ROOT_H_ */
