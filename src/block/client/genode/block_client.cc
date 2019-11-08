

#include <base/heap.h>
#include <block_session/connection.h>
#include <util/string.h>
#include <util/reconstructible.h>
#include <ada/exception.h>
#include <cai_capability.h>

//#define ENABLE_TRACE
#include <trace.h>

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
            TLOG("client=", client);
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
    _device(nullptr),
    _callback(nullptr),
    _rw(nullptr),
    _env(nullptr),
    _tag(0)
{
    TLOG();
}

void Cai::Block::Client::initialize(
        void *env,
        const char *device,
        void *callback,
        void *rw,
        Genode::uint64_t buffer_size)
{
    TLOG("env=", env, " device=", device, " callback=", callback, " rw=", rw, " buffer_size=", buffer_size);
    const char default_device[] = "";
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
    if(_device){
        _block_size = blk(_device)->info().block_size;
        _block_count = blk(_device)->info().block_count;
    }
}

void Cai::Block::Client::finalize()
{
    TLOG();
    _factory->destroy<Block_session>(_device);
    _block_count = 0;
    _block_size = 0;
    _device = nullptr;
    _callback = nullptr;
    _rw = nullptr;
    _env = nullptr;
}

void Cai::Block::Client::allocate_request (void *request,
                                           int opcode,
                                           Genode::uint64_t start,
                                           unsigned long length,
                                           unsigned long tag,
                                           int *result)
{
    TLOG("request=", request, " opcode=", opcode, " start=", start, " length=", length, " tag=", tag, " result=", result);
    ::Block::Packet_descriptor *packet = reinterpret_cast<::Block::Packet_descriptor *>(request);
    if(opcode == ::Block::Packet_descriptor::Opcode::READ
            || opcode == ::Block::Packet_descriptor::Opcode::WRITE){
        try{
            *packet = ::Block::Packet_descriptor(blk(_device)->alloc_packet (block_size() * length),
                    static_cast<::Block::Packet_descriptor::Opcode>(opcode),
                    start,
                    length,
                    {tag});
            *result = 0;
        }catch(...){
            *result = 1;
        }
    }else{
        *result = 0;
    }
}

void Cai::Block::Client::update_response_queue(int *status,
                                               unsigned long *tag,
                                               int *success)
{
    TLOG("status=", status, " tag=", tag, " success=", success);
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
    TLOG("request=", request);
    ::Block::Packet_descriptor *packet = reinterpret_cast<::Block::Packet_descriptor *>(request);
    blk(_device)->tx()->submit_packet(*packet);
}

void Cai::Block::Client::submit()
{
    TLOG();
}

void Cai::Block::Client::read_write(void *request)
{
    TLOG("request=", request);
    ::Block::Packet_descriptor *packet = reinterpret_cast<::Block::Packet_descriptor *>(request);
    ((void (*)(void *, int, unsigned long, Genode::uint64_t, void *))(_rw))(
            (void *)this,
            static_cast<int>(packet->operation()),
            packet->tag().value,
            packet->block_count(),
            blk(_device)->tx()->packet_content(*packet));
}

void Cai::Block::Client::release(void *request)
{
    TLOG("request=", request);
    ::Block::Packet_descriptor *packet = reinterpret_cast<::Block::Packet_descriptor *>(request);
    if(packet->operation() == ::Block::Packet_descriptor::READ
            || packet->operation() == ::Block::Packet_descriptor::WRITE){
        blk(_device)->tx()->release_packet(*packet);
    }
}

bool Cai::Block::Client::writable()
{
    TLOG();
    return blk(_device)->info().writeable;
}

Genode::uint64_t Cai::Block::Client::block_count()
{
    TLOG();
    return _block_count;
}

Genode::uint64_t Cai::Block::Client::block_size()
{
    TLOG();
    return _block_size;
}

void Cai::Block::Client::callback()
{
    TLOG();
    Call(_callback);
}
