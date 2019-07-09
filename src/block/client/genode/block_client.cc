

#include <base/heap.h>
#include <block_session/connection.h>
#include <util/string.h>
#include <util/reconstructible.h>
#include <ada/exception.h>
#include <cai_capability.h>

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

class Block_session
{
    private:
        Genode::Heap _heap;
        Genode::Allocator_avl _alloc;
        Block::Connection<> _block;
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

        ::Block::Connection<> *block()
        {
            return &_block;
        }
};

inline ::Block::Connection<> *blk(void *device)
{
    return reinterpret_cast<Block_session *>(device)->block();
}

Cai::Block::Client::Client() :
    _block_count(0),
    _block_size(0),
    _buffer_size(0),
    _device(nullptr),
    _callback(nullptr),
    _rw(nullptr),
    _env(nullptr)
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
    Genode::uint64_t alloc_size;
    Genode::size_t const buf_size = buffer_size ? buffer_size : 128 * 1024;
    _callback = callback;
    _rw = rw;
    _env = env;
    check_factory(_factory, *reinterpret_cast<Cai::Env *>(env)->env);
    _device = _factory->create<Block_session>(
            *reinterpret_cast<Cai::Env *>(env)->env,
            buf_size,
            device ? device : default_device,
            this,
            &Client::callback);
    _block_size = blk(_device)->info().block_size;
    _block_count = blk(_device)->info().block_count;
    alloc_size = reinterpret_cast<Block_session *>(_device)->available();
    _buffer_size = alloc_size - (alloc_size % _block_size);
}

void Cai::Block::Client::finalize()
{
    _factory->destroy<Block_session>(_device);
    _block_count = 0;
    _block_size = 0;
    _buffer_size = 0;
    _device = nullptr;
    _callback = nullptr;
    _rw = nullptr;
    _env = nullptr;
}

void Cai::Block::Client::allocate_request (void *request,
                                           int opcode,
                                           Genode::uint64_t start,
                                           unsigned long length,
                                           unsigned long tag)
{
    ::Block::Packet_descriptor *packet = reinterpret_cast<::Block::Packet_descriptor *>(request);
    if(opcode == ::Block::Packet_descriptor::Opcode::READ
            || opcode == ::Block::Packet_descriptor::Opcode::WRITE){
        try{
            *packet = ::Block::Packet_descriptor(blk(_device)->alloc_packet (block_size() * length),
                    static_cast<::Block::Packet_descriptor::Opcode>(opcode),
                    start,
                    length,
                    {tag});
        }catch(...){}
    }
}

void Cai::Block::Client::update_response_queue(int *status,
                                               unsigned long *tag,
                                               int *success)
{
    if(blk(_device)->tx()->ack_avail()){
        ::Block::Packet_descriptor packet = blk(_device)->tx()->get_acked_packet();
        *success = static_cast<int>(packet.succeeded());
        *status = 1;
        *tag = packet.tag().value;
    }else{
        *status = 0;
    }
}

void Cai::Block::Client::enqueue(void *request)
{
    ::Block::Packet_descriptor *packet = reinterpret_cast<::Block::Packet_descriptor *>(request);
    if(packet->operation() == ::Block::Packet_descriptor::Opcode::WRITE){
        ((void (*)(void *, int, Genode::uint64_t, unsigned long, Genode::uint64_t, void *))(_rw))(
                get_instance(),
                static_cast<int>(packet->operation()),
                block_size(),
                packet->tag().value,
                packet->block_count(),
                blk(_device)->tx()->packet_content(*packet));
    }
    blk(_device)->tx()->submit_packet(*packet);
}

void Cai::Block::Client::submit()
{ }

void Cai::Block::Client::read(void *request)
{
    ::Block::Packet_descriptor *packet = reinterpret_cast<::Block::Packet_descriptor *>(request);
    ((void (*)(void *, int, Genode::uint64_t, unsigned long, Genode::uint64_t, void *))(_rw))(
            get_instance(),
            static_cast<int>(packet->operation()),
            block_size(),
            packet->tag().value,
            packet->block_count(),
            blk(_device)->tx()->packet_content(*packet));
}


void Cai::Block::Client::release(void *request)
{
    ::Block::Packet_descriptor *packet = reinterpret_cast<::Block::Packet_descriptor *>(request);
    if(packet->operation() == ::Block::Packet_descriptor::READ
            || packet->operation() == ::Block::Packet_descriptor::WRITE){
        blk(_device)->tx()->release_packet(*packet);
    }
}

bool Cai::Block::Client::writable()
{
    return blk(_device)->info().writeable;
}

Genode::uint64_t Cai::Block::Client::block_count()
{
    return _block_count;
}

Genode::uint64_t Cai::Block::Client::block_size()
{
    return _block_size;
}

Genode::uint64_t Cai::Block::Client::maximum_transfer_size()
{
    return _buffer_size;
}

void Cai::Block::Client::callback()
{
    Call(_callback);
}
