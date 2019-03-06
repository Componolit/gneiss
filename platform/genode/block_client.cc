

#include <base/heap.h>
#include <block_session/connection.h>
#include <util/string.h>
#include <util/reconstructible.h>
#include <ada/exception.h>

#include <genode_packet.h>
namespace Cai {
#include <block_client.h>
}

extern "C"
{
    void __gnat_rcheck_CE_Access_Check()
    {
        throw Ada::Exception::Access_Check();
    }
}

Genode::Env *component_env __attribute__((weak)) = nullptr;
Genode::Constructible<Genode::Sliced_heap> _heap;
Genode::Constructible<Genode::Allocator_avl> _alloc;

inline ::Block::Connection *blk(Genode::uint64_t device)
{
    if (device){
        return reinterpret_cast<::Block::Connection *>(device);
    }else{
        Genode::error("Block connection device not initialized.");
        throw Ada::Exception::Access_Check();
    }
}

Cai::Block::Client::Client() :
    _device(0),
    _block_count(0),
    _block_size(0)
{ }

void Cai::Block::Client::initialize(const char *device)
{
    const char default_device[] = "";
    Genode::size_t blk_size;
    if(component_env){
        _heap.construct(component_env->ram(), component_env->rm());
        _alloc.construct(&*_heap);
        _device = reinterpret_cast<Genode::uint64_t>(new (*_heap) ::Block::Connection(
                *component_env,
                &*_alloc,
                128 * 1024,
                device ? device : default_device));
        ::Block::Session::Operations ops;
        blk(_device)->info(&_block_count, &blk_size, &ops);
        _block_size = blk_size;
    }else{
        Genode::error("Failed to construct block session");
    }
}

void Cai::Block::Client::finalize()
{
    Genode::destroy (*_heap, reinterpret_cast<::Block::Connection *>(_device));
    _device = 0;
}

void Cai::Block::Client::submit_read(Cai::Block::Request req)
{
    ::Block::Packet_descriptor packet(
            blk(_device)->dma_alloc_packet(block_size() * req.length),
            ::Block::Packet_descriptor::READ,
            req.start, req.length);
    blk(_device)->tx()->submit_packet(packet);
}

void Cai::Block::Client::submit_write(
        Cai::Block::Request req,
        Genode::uint8_t *data,
        Genode::uint64_t length)
{
    if(length > req.length * block_size()){
        throw Ada::Exception::Length_Check();
    }

    ::Block::Packet_descriptor packet(
            blk(_device)->dma_alloc_packet(length),
            ::Block::Packet_descriptor::WRITE,
            req.start, req.length);
    Genode::memcpy(blk(_device)->tx()->packet_content(packet), data, length);
    blk(_device)->tx()->submit_packet(packet);
}

void Cai::Block::Client::sync()
{ }

Cai::Block::Request Cai::Block::Client::next()
{
    Cai::Block::Request req = {Cai::Block::NONE, {}, 0, 0, Cai::Block::RAW};
    if(blk(_device)->tx()->ack_avail()){
        ::Block::Packet_descriptor packet = blk(_device)->tx()->get_acked_packet();
        req = create_cai_block_request(packet);
    }
    return req;
}

void Cai::Block::Client::read(
        Cai::Block::Request &req,
        Genode::uint8_t *data,
        Genode::uint64_t length)
{
    ::Block::Packet_descriptor packet = create_packet_descriptor(req);
    if(length < packet.size()){
        Genode::error (length, " < ", packet.size());
        req.status = ERROR;
    }else{
        Genode::memcpy(data, blk(_device)->tx()->packet_content(packet), packet.size());
        req.status = OK;
    }
}

void Cai::Block::Client::acknowledge(Cai::Block::Request req)
{
    ::Block::Packet_descriptor packet = create_packet_descriptor(req);
    if(packet.operation() == ::Block::Packet_descriptor::READ
            || packet.operation() == ::Block::Packet_descriptor::WRITE){
        blk(_device)->tx()->release_packet(packet);
    }
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

