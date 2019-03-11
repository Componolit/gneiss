
#include <session/session.h>
#include <block/request_stream.h>

#include <genode_packet.h>
namespace Cai {
#include <block_server.h>
    struct Block_session_component;
}
#include <block_root.h>

Cai::Block_session_component::Block_session_component(
        Genode::Region_map &rm,
        Genode::Dataspace_capability ds,
        Genode::Entrypoint &ep,
        Genode::Signal_context_capability sigh,
        Cai::Block::Server &server) :
    Request_stream(rm, ds, ep, sigh,
            ((Genode::uint64_t (*)(void *))server._block_size)(server._state)),
    _ep(ep),
    _server(server)
{
    _ep.manage(*this);
}

Cai::Block_session_component::~Block_session_component()
{
    _ep.dissolve(*this);
}

void Cai::Block_session_component::info(::Block::sector_t *count, Genode::size_t *size, Block::Session::Operations *ops)
{
    *count = ((Genode::uint64_t (*)(void *))_server._block_count)(_server._state);
    *size = ((Genode::uint64_t (*)(void *))_server._block_size)(_server._state);
    *ops = Block::Session::Operations();
    ops->set_operation(Block::Packet_descriptor::Opcode::READ);
    if(_server.writable()){
        ops->set_operation(Block::Packet_descriptor::Opcode::Write);
    }
}

void Cai::Block_session_component::sync()
{ }

Genode::Capability<Tx> Cai::Block_session_component::tx_cap()
{
    return Request_stream::tx_cap();
}

Cai::Block_root::Block_root(Genode::Env &env, Cai::Block::Server &server, Genode::size_t ds_size) :
    _env(env),
    _sigh(env.ep(), *this, &Cai::Block_root::handler),
    _server(server),
    _ds(env.ram(), env.rm(), ds_size),
    _session(env.rm(), _ds.cap(), env.ep(), _sigh, server)
{ }

void Cai::Block_root::handler()
{
    ((void (*)(void *))_server._callback)(_server._state);
    _session.wakeup_client();
}

Genode::Capability<Genode::Session> Cai::Block_root::cap()
{
    return _session->cap();
}

Cai::Block::Server::Server(void *session, void *state) :
    _session(session),
    _state(state)
{ }

static Block_session_component *blk(void *session)
{
    return static_cast<Block_root *>(session)->_session;
}

typedef Genode::Packet_stream_sink<Block::Session::Tx_policy> Tx_sink;

class Public_tx_wrapper
{
    public:
        Packet_stream_tx::Rpc_object<Block::Session::Tx> *tx;
};

/*
 * http://www.gotw.ca/gotw/076.htm#4
 * #4
 */

template <>
void ::Block::Request_stream::try_acknowledge(Cai::Block::Request const &req)
{
    Cai::Block::Request &request = const_cast<Cai::Block::Request &>(req);
    Tx_sink &tx_sink = *_tx.sink();
    if(tx_sink.ack_slots_free()){
        ::Block::Request_stream::Ack ack(tx_sink, _payload.block_size);
        if(request.status != Cai::Block::ACK){
            ack.submit(create_genode_block_request(req));
            if(ack.submitted){
                request.status = Cai::Block::ACK;
            }
        }
    }
}

template <>
void ::Block::Request_stream::with_requests(Cai::Block::Request const &)
{
}

/*
 */

void Cai::Block::Server::next_request(Cai::Block::Request *)
{
    Genode::warning(__func__);
}

void Cai::Block::Server::read(Cai::Block::Request, void *, Genode::uint64_t, bool *)
{
    Genode::warning(__func__);
}

void Cai::Block::Server::write(Cai::Block::Request, void *, Genode::uint64_t, bool *)
{
    Genode::warning(__func__);
}

void Cai::Block::Server::acknowledge(Cai::Block::Request &req)
{
    if(_session && (*blk(_session)).constructed()){
        (*blk(_session))->try_acknowledge(req);
    }else{
        Genode::error("Failed to acknowledge, session not initialized");
    }
}
