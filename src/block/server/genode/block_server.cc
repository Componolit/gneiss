
#include <session/session.h>
#include <block/request_stream.h>
#include <block_session/block_session.h>
#include <util/reconstructible.h>
#include <cai_capability.h>

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
    Request_stream(rm, ds, ep, sigh, ::Block::Session::Info{
                Get_attr_64(server._block_size, (void *)&server),
                Get_attr_64(server._block_size, (void *)&server),
                0,
                ((bool (*)(Cai::Block::Server *))server._writable)(&server)
            }),
    _ep(ep),
    _server(server)
{
    _ep.manage(*this);
}

Cai::Block::Block_session_component::~Block_session_component()
{
    _ep.dissolve(*this);
}

::Block::Session::Info Cai::Block::Block_session_component::info() const
{
    return ::Block::Session::Info {
        Get_attr_64(_server._block_size, &_server),
        Get_attr_64(_server._block_count, &_server),
        0,
        ((bool (*)(Cai::Block::Server *))_server._writable)(&_server)
    };
}

Genode::Capability<::Block::Session::Tx> Cai::Block::Block_session_component::tx_cap()
{
    return Request_stream::tx_cap();
}

Cai::Block::Block_root::Block_root(Cai::Env *env, Cai::Block::Server &server, Genode::size_t ds_size) :
    _env(env),
    _sigh(env->env->ep(), *this, &Cai::Block::Block_root::handler),
    _server(server),
    _ds(env->env->ram(), env->env->rm(), ds_size),
    _session(env->env->rm(), _ds.cap(), env->env->ep(), _sigh, server)
{ }

void Cai::Block::Block_root::handler()
{
    Call(_server._callback);
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
    _writable(nullptr)
{ }

void Cai::Block::Server::initialize(
        void *env,
        Genode::uint64_t size,
        void *callback,
        void *block_count,
        void *block_size,
        void *writable)
{
    _callback = callback;
    _block_count = block_count;
    _block_size = block_size;
    _writable = writable;
    check_factory(_factory, *reinterpret_cast<Cai::Env *>(env)->env);
    _session = _factory->create<Cai::Block::Block_root>(
            reinterpret_cast<Cai::Env *>(env),
            *this,
            static_cast<Genode::size_t>(size));
}

void Cai::Block::Server::finalize()
{
    _factory->destroy<Cai::Block::Block_root>(_session);
    _session = nullptr;
    _callback = nullptr;
    _block_count = nullptr;
    _block_size = nullptr;
    _writable = nullptr;
}

static Cai::Block::Block_session_component &blk(void *session)
{
    return static_cast<Cai::Block::Block_root *>(session)->_session;
}

void Cai::Block::Server::process_request(void *request, int *success)
{
    *success = 0;
    ::Block::Request *req = reinterpret_cast<::Block::Request *>(request);
    blk(_session).with_requests([&] (::Block::Request r) {
        if(*success){
            return Cai::Block::Block_session_component::Response::RETRY;
        }else{
            *req = r;
            *success = 1;
            return Cai::Block::Block_session_component::Response::ACCEPTED;
        }
    });
}

void Cai::Block::Server::read(void *request, void *buffer)
{
    ::Block::Request *req = reinterpret_cast<::Block::Request *>(request);
    blk(_session).with_content(*req, [&] (void *ptr, Genode::size_t size){
        Genode::memcpy(ptr, buffer, size);
    });
}

void Cai::Block::Server::write(void *request, void *buffer)
{
    ::Block::Request *req = reinterpret_cast<::Block::Request *>(request);
    blk(_session).with_content(*req, [&] (void *ptr, Genode::size_t size){
        Genode::memcpy(buffer, ptr, size);
    });
}

void Cai::Block::Server::acknowledge(void *request, int *success)
{
    ::Block::Request *req = reinterpret_cast<::Block::Request *>(request);
    req->success = static_cast<bool>(*success);
    *success = 0;
    blk(_session).try_acknowledge([&] (Cai::Block::Block_session_component::Ack &ack){
        if(!*success){
            ack.submit(*req);
            *success = 1;
        }
    });
}

void Cai::Block::Server::unblock_client()
{
    blk(_session).wakeup_client_if_needed();
}
