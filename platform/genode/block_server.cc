
#include <session/session.h>
#include <block/request_stream.h>
#include <block_session/block_session.h>

#include <genode_packet.h>
#include <block_root.h>
namespace Cai {
#include <block_server.h>
    namespace Block {
        struct Block_session_component;
        struct Block_root;
    }
}

#include <factory.h>

Cai::Block::Block_session_component::Block_session_component(
        Genode::Region_map &rm,
        Genode::Dataspace_capability ds,
        Genode::Entrypoint &ep,
        Genode::Signal_context_capability sigh,
        Cai::Block::Server &server) :
    Request_stream(rm, ds, ep, sigh, Get_attr_64(server._block_size, server._state)),
    _ep(ep),
    _server(server)
{
    _ep.manage(*this);
}

Cai::Block::Block_session_component::~Block_session_component()
{
    _ep.dissolve(*this);
}

void Cai::Block::Block_session_component::info(::Block::sector_t *count, Genode::size_t *size, ::Block::Session::Operations *ops)
{
    *count = Get_attr_64(_server._block_count, _server._state);
    *size = Get_attr_64(_server._block_size, _server._state);
    *ops = ::Block::Session::Operations();
    ops->set_operation(::Block::Packet_descriptor::Opcode::READ);
    if(_server.writable()){
        ops->set_operation(::Block::Packet_descriptor::Opcode::WRITE);
    }
}

void Cai::Block::Block_session_component::sync()
{ }

Genode::Capability<::Block::Session::Tx> Cai::Block::Block_session_component::tx_cap()
{
    return Request_stream::tx_cap();
}

Cai::Block::Block_root::Block_root(Genode::Env &env, Cai::Block::Server &server, Genode::size_t ds_size) :
    _env(env),
    _sigh(env.ep(), *this, &Cai::Block::Block_root::handler),
    _server(server),
    _ds(env.ram(), env.rm(), ds_size),
    _session(env.rm(), _ds.cap(), env.ep(), _sigh, server)
{ }

void Cai::Block::Block_root::handler()
{
    if(_server._callback && _server._state){
        Call(_server._callback, _server._state);
    }
    _session.wakeup_client();
}

Genode::Capability<Genode::Session> Cai::Block::Block_root::cap()
{
    return _session.cap();
}

Cai::Block::Server::Server() :
    _session(nullptr),
    _state(nullptr),
    _callback(nullptr),
    _block_count(nullptr),
    _block_size(nullptr),
    _maximal_transfer_size(nullptr),
    _writable(nullptr)
{ }

static Cai::Block::Block_session_component &blk(void *session)
{
    return static_cast<Cai::Block::Block_root *>(session)->_session;
}

typedef Genode::Packet_stream_sink<Block::Session::Tx_policy> Tx_sink;

/*
 * http://www.gotw.ca/gotw/076.htm
 * #4
 */

namespace Block {

    template <>
        void Request_stream::try_acknowledge(Cai::Block::Request const &req)
        {
            Cai::Block::Request &request = const_cast<Cai::Block::Request &>(req);
            Tx_sink &tx_sink = *_tx.sink();
            if(tx_sink.ack_slots_free()){
                ::Block::Request_stream::Ack ack(tx_sink, _payload._block_size);
                if(request.status != Cai::Block::ACK){
                    ack.submit(create_genode_block_request(req));
                    if(ack._submitted){
                        request.status = Cai::Block::ACK;
                    }
                }
            }
        }

    template <>
        void Request_stream::with_requests(Cai::Block::Request const &req)
        {
            Cai::Block::Request &request = const_cast<Cai::Block::Request &>(req);
            Tx_sink &tx_sink = *_tx.sink();
            if(tx_sink.packet_avail()){
                request = create_cai_block_request(tx_sink.try_get_packet());
            }
        }

}

/*
 */

void Cai::Block::Server::next_request(Cai::Block::Request *request)
{
    *request = Cai::Block::Request {Cai::Block::NONE, {}, 0, 0, Cai::Block::RAW};
    if(_session){
        blk(_session).with_requests(*request);
    }
}

void Cai::Block::Server::read(Cai::Block::Request request, void *buffer, Genode::uint64_t size, bool *success)
{
    ::Block::Request req = create_genode_block_request(request);
    if(_session){
        blk(_session).with_content(req, [&] (void *ptr, Genode::size_t sz){
                if(size < sz){
                    *success = false;
                }else{
                    Genode::memcpy(buffer, ptr, sz);
                    *success = true;
                }
        });
    }
}

void Cai::Block::Server::write(Cai::Block::Request request, void *buffer, Genode::uint64_t size, bool *success)
{
    ::Block::Request req = create_genode_block_request(request);
    if(_session){
        blk(_session).with_content(req, [&] (void *ptr, Genode::size_t sz){
                if(sz < size){
                    *success = false;
                }else{
                    Genode::memcpy(ptr, buffer, size);
                    *success = true;
                }
        });
    }
}

void Cai::Block::Server::acknowledge(Cai::Block::Request &req)
{
    if(_session){
        blk(_session).try_acknowledge(req);
    }else{
        Genode::error("Failed to acknowledge, session not initialized");
    }
}
