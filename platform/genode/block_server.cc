
#include <session/session.h>
#include <block/request_stream.h>
#include <block_session/block_session.h>
#include <util/reconstructible.h>

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

Genode::Env *component_env __attribute__((weak)) = nullptr;
static Genode::Constructible<Factory> _factory;

Cai::Block::Block_session_component::Block_session_component(
        Genode::Region_map &rm,
        Genode::Dataspace_capability ds,
        Genode::Entrypoint &ep,
        Genode::Signal_context_capability sigh,
        Cai::Block::Server &server) :
    Request_stream(rm, ds, ep, sigh, Get_attr_64(server._block_size, server.get_instance())),
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
    *count = Get_attr_64(_server._block_count, _server.get_instance());
    *size = Get_attr_64(_server._block_size, _server.get_instance());
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
    if(_server._callback){
        Call(_server._callback);
    }
    _session.wakeup_client();
}

Genode::Capability<Genode::Session> Cai::Block::Block_root::cap()
{
    return _session.cap();
}

Cai::Block::Server::Server() :
    _session(nullptr),
    _callback(nullptr),
    _block_count(nullptr),
    _block_size(nullptr),
    _maximal_transfer_size(nullptr),
    _writable(nullptr)
{ }

void *Cai::Block::Server::get_instance()
{
    return reinterpret_cast<void *>(this);
}

void Cai::Block::Server::initialize(
        Genode::uint64_t size,
        void *callback,
        void *block_count,
        void *block_size,
        void *maximal_transfer_size,
        void *writable)
{
    if(component_env){
        _callback = callback;
        _block_count = block_count;
        _block_size = block_size;
        _maximal_transfer_size = maximal_transfer_size;
        _writable = writable;
        if(!_factory.constructed()){
            _factory.construct(*component_env);
        }
        _session = _factory->create<Cai::Block::Block_root>(
                *component_env,
                *this,
                static_cast<Genode::size_t>(size));
    }
}

void Cai::Block::Server::finalize()
{
    if(_factory.constructed()){
        _factory->destroy<Cai::Block::Block_root>(_session);
    }
    _session = nullptr;
    _callback = nullptr;
    _block_count = nullptr;
    _block_size = nullptr;
    _maximal_transfer_size = nullptr;
    _writable = nullptr;
}

bool Cai::Block::Server::initialized()
{
    return _session
        && _callback
        && _block_count
        && _block_size
        && _maximal_transfer_size
        && _writable;
}

static Cai::Block::Block_session_component &blk(void *session)
{
    return static_cast<Cai::Block::Block_root *>(session)->_session;
}

Cai::Block::Request Cai::Block::Server::head()
{
    Request request = Cai::Block::Request {Cai::Block::NONE, {}, 0, 0, Cai::Block::RAW};
    blk(_session).with_requests([&] (::Block::Request req) {
        request = create_cai_block_request (req);
        request.status = Cai::Block::RAW;
        return Cai::Block::Block_session_component::Response::RETRY;
    });
    return request;
}

void Cai::Block::Server::discard()
{
    bool accepted = false;
    blk(_session).with_requests([&] (::Block::Request) {
        if(accepted){
            return Cai::Block::Block_session_component::Response::RETRY;
        }else{
            accepted = true;
            return Cai::Block::Block_session_component::Response::ACCEPTED;
        }
    });
}

void Cai::Block::Server::read(Cai::Block::Request request, void *buffer)
{
    ::Block::Request req = create_genode_block_request(request);
    blk(_session).with_content(req, [&] (void *ptr, Genode::size_t size){
        Genode::memcpy(ptr, buffer, size);
    });
}

void Cai::Block::Server::write(Cai::Block::Request request, void *buffer)
{
    ::Block::Request req = create_genode_block_request(request);
    blk(_session).with_content(req, [&] (void *ptr, Genode::size_t size){
        Genode::memcpy(buffer, ptr, size);
    });
}

void Cai::Block::Server::acknowledge(Cai::Block::Request &req)
{
    bool acked = false;
    blk(_session).try_acknowledge([&] (Cai::Block::Block_session_component::Ack &ack){
        if (acked) {
            req.status = Cai::Block::ACK;
        } else {
            ack.submit(create_genode_block_request(req));
            acked = true;
        }
    });
}
