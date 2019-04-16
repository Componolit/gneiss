

#include <base/heap.h>
#include <block_session/connection.h>
#include <util/string.h>
#include <util/reconstructible.h>
#include <ada/exception.h>

#include <genode_packet.h>
namespace Cai {
#include <block_client.h>
}

#include <factory.h>

extern "C"
{
    void __gnat_rcheck_CE_Access_Check()
    {
        throw Ada::Exception::Access_Check();
    }
}

static Genode::Constructible<Factory> _factory {};

class Block_session
{
    private:
        Genode::Heap _heap;
        Genode::Allocator_avl _alloc;
        Block::Connection _block;
        Genode::Io_signal_handler<Cai::Block::Client> _event;
    public:
        Block_session(
                Genode::Env &env,
                Genode::size_t size,
                const char *device,
                Cai::Block::Client *client,
                void (Cai::Block::Client::*callback) ()) :
            _heap(env.ram(), env.rm()),
            _alloc(&_heap),
            _block(env, &_alloc, size, device),
            _event(env.ep(), *client, callback)
        {
            _block.tx_channel()->sigh_ack_avail(_event);
            _block.tx_channel()->sigh_ready_to_submit(_event);
        }

        Genode::uint64_t available()
        {
            return _alloc.avail();
        }

        ::Block::Connection *block()
        {
            return &_block;
        }
};

inline ::Block::Connection *blk(void *device)
{
    return reinterpret_cast<Block_session *>(device)->block();
}

Cai::Block::Client::Client() :
    _block_count(0),
    _block_size(0),
    _buffer_size(0),
    _device(nullptr),
    _callback(nullptr),
    _rw(nullptr)
{ }

void *Cai::Block::Client::get_instance()
{
    return reinterpret_cast<void *>(this);
}

bool Cai::Block::Client::initialized()
{
    return _device && _callback;
}

void Cai::Block::Client::initialize(
        void *env,
        const char *device,
        void *callback,
        void *rw,
        Genode::uint64_t buffer_size)
{
    const char default_device[] = "";
    Genode::size_t blk_size;
    Genode::uint64_t alloc_size;
    Genode::size_t const buf_size = buffer_size ? buffer_size : 128 * 1024;
    _callback = callback;
    _rw = rw;
    check_factory(_factory, *reinterpret_cast<Genode::Env *>(env));
    _device = _factory->create<Block_session>(
            *reinterpret_cast<Genode::Env *>(env),
            buf_size,
            device ? device : default_device,
            this,
            &Client::callback);
    ::Block::Session::Operations ops;
    blk(_device)->info(&_block_count, &blk_size, &ops);
    _block_size = blk_size;
    alloc_size = reinterpret_cast<Block_session *>(_device)->available();
    _buffer_size = alloc_size - (alloc_size % _block_size);
}

void Cai::Block::Client::finalize()
{
    _factory->destroy<Block_session>(_device);
    _device = nullptr;
    _callback = nullptr;
}

class Packet_allocator
{
    private:
        ::Block::Packet_descriptor _alloc_packet;

    public:
        Packet_allocator() :
            _alloc_packet()
        { }

        void free(void *device)
        {
            if(_alloc_packet.size()){
                blk(device)->tx()->release_packet(_alloc_packet);
            }
        }

        void reallocate(void *device, Genode::uint64_t size)
        {
            if(size != _alloc_packet.size()){
                free(device);
                _alloc_packet = blk(device)->tx()->alloc_packet(size, 0);
            }
        }

        ::Block::Packet_descriptor take()
        {
            ::Block::Packet_descriptor packet = ::Block::Packet_descriptor(
                    _alloc_packet.offset(),
                    _alloc_packet.size());
            _alloc_packet = ::Block::Packet_descriptor();
            return packet;
        }
};

static Packet_allocator _packet_allocator {};

bool Cai::Block::Client::ready(Cai::Block::Request req)
{
    if(_device && (req.kind == Cai::Block::READ || req.kind == Cai::Block::WRITE)){
        try {
            _packet_allocator.reallocate(_device, block_size() * req.length);
        } catch (...) {
            return false;
        }
    }
    return _device && (blk(_device)->tx()->ready_to_submit()
                       || req.kind == Cai::Block::SYNC
                       || req.kind == Cai::Block::TRIM);
}

bool Cai::Block::Client::supported(Cai::Block::Kind kind)
{
    return kind == Cai::Block::READ || kind == Cai::Block::WRITE;
}

void Cai::Block::Client::enqueue(Cai::Block::Request req)
{
    _packet_allocator.reallocate(_device, block_size() * req.length);
    ::Block::Packet_descriptor packet(
            _packet_allocator.take(),
            req.kind == Cai::Block::READ ? ::Block::Packet_descriptor::READ : ::Block::Packet_descriptor::WRITE,
            req.start, req.length);
    if(req.kind == Cai::Block::WRITE){
        ((void (*)(void *, Cai::Block::Kind, Genode::uint64_t, Genode::uint64_t, Genode::uint64_t, void *))(_rw))(
                get_instance(), req.kind, block_size(), req.start, req.length,
                blk(_device)->tx()->packet_content(packet));
    }
    blk(_device)->tx()->submit_packet(packet);
}

void Cai::Block::Client::submit()
{ }

static const ::Block::Packet_descriptor empty_packet = ::Block::Packet_descriptor();

static bool packet_empty(::Block::Packet_descriptor const &packet)
{
    return packet.operation() == empty_packet.operation()
        && packet.block_number() == empty_packet.block_number()
        && packet.block_count() == empty_packet.block_count()
        && packet.succeeded() == empty_packet.succeeded();
}

static ::Block::Packet_descriptor last_ack = empty_packet;

Cai::Block::Request Cai::Block::Client::next()
{
    Cai::Block::Request req = {Cai::Block::NONE, {}, 0, 0, Cai::Block::RAW};
    if(packet_empty(last_ack)){
        if(blk(_device)->tx()->ack_avail()){
            last_ack = blk(_device)->tx()->get_acked_packet();
            req = create_cai_block_request (last_ack);
        }
    }else{
        req = create_cai_block_request (last_ack);
    }
    return req;
}

void Cai::Block::Client::read(Cai::Block::Request req)
{
    ::Block::Packet_descriptor packet = create_packet_descriptor(req);
    ((void (*)(void *, Cai::Block::Kind, Genode::uint64_t, Genode::uint64_t, Genode::uint64_t, void *))(_rw))(
            get_instance(), req.kind, block_size(), req.start, req.length,
            blk(_device)->tx()->packet_content(packet));
}


void Cai::Block::Client::release(Cai::Block::Request)
{
    if(last_ack.operation() == ::Block::Packet_descriptor::READ
            || last_ack.operation() == ::Block::Packet_descriptor::WRITE){
        blk(_device)->tx()->release_packet(last_ack);
    }
    last_ack = empty_packet;
}

bool Cai::Block::Client::writable()
{
    ::Block::sector_t sector;
    Genode::size_t size;
    ::Block::Session::Operations ops;
    blk(_device)->info(&sector, &size, &ops);
    return ops.supported(::Block::Packet_descriptor::WRITE);
}

Genode::uint64_t Cai::Block::Client::block_count()
{
    return _block_count;
}

Genode::uint64_t Cai::Block::Client::block_size()
{
    return _block_size;
}

Genode::uint64_t Cai::Block::Client::maximal_transfer_size()
{
    return _buffer_size;
}

void Cai::Block::Client::callback()
{
    Call(_callback);
}
