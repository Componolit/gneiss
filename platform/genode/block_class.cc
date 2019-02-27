
#include <block.h>

#include <base/heap.h>
#include <block_session/connection.h>
#include <util/string.h>
#include <util/reconstructible.h>
#include <ada/exception.h>

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

inline Block::Connection *blk(Genode::uint64_t device)
{
    if (device){
        return reinterpret_cast<Block::Connection *>(device);
    }else{
        throw Ada::Exception::Access_Check();
    }
}

struct Genode_Packet
{
    Genode::uint64_t offset;
    Genode::uint64_t size;

    Genode_Packet(Genode::off_t o, Genode::size_t s) :
        offset(o), size(s) { }

    void uid(Genode::uint8_t *u)
    {
        Genode::memcpy(u, this, 16);
    }
};

Block::Client::Client() :
    _device(0),
    _block_count(0),
    _block_size(0)
{ }

void Block::Client::initialize(const char *device)
{
    const char default_device[] = "";
    Genode::size_t blk_size;
    if(component_env){
        _heap.construct(component_env->ram(), component_env->rm());
        _alloc.construct(&*_heap);
        _device = reinterpret_cast<Genode::uint64_t>(new (*_heap) Block::Connection(
                *component_env,
                &*_alloc,
                128 * 1024,
                device ? device : default_device));
        Block::Session::Operations ops;
        blk(_device)->info(&_block_count, &blk_size, &ops);
        _block_size = blk_size;
    }else{
        Genode::error("Failed to construct block session");
    }
}

void Block::Client::finalize()
{
    Genode::destroy (*_heap, reinterpret_cast<Block::Connection *>(_device));
}

void Block::Client::submit_read(Block::Client::Request req)
{
    Block::Packet_descriptor packet(
            blk(_device)->dma_alloc_packet(block_size() * req.length),
            Block::Packet_descriptor::READ,
            req.start, req.length);
    blk(_device)->tx()->submit_packet(packet);
}

void Block::Client::submit_sync(Block::Client::Request req)
{
    Block::Packet_descriptor packet(
            blk(_device)->dma_alloc_packet(block_size() * req.length),
            Block::Packet_descriptor::END,
            req.start, req.length);
    blk(_device)->tx()->submit_packet(packet);
}

void Block::Client::submit_write(
        Block::Client::Request req,
        Genode::uint8_t *data,
        Genode::uint64_t length)
{
    if(length > req.length * block_size()){
        throw Ada::Exception::Length_Check();
    }

    Block::Packet_descriptor packet(
            blk(_device)->dma_alloc_packet(length),
            Block::Packet_descriptor::WRITE,
            req.start, req.length);
    Genode::memcpy(blk(_device)->tx()->packet_content(packet), data, length);
    blk(_device)->tx()->submit_packet(packet);
}

Block::Client::Request Block::Client::next()
{
    Block::Client::Request req = {NONE, {}, 0, 0, RAW};
    Block::Client::Kind genode_request_id[3] = {READ, WRITE, SYNC};
    if(blk(_device)->tx()->ack_avail()){
        Block::Packet_descriptor packet = blk(_device)->tx()->get_acked_packet();
        req.kind = genode_request_id[packet.operation()];
        req.start = packet.block_number();
        req.length = packet.block_count();
        req.status = packet.succeeded() ? OK : ERROR;
        Genode_Packet(packet.offset(), packet.size()).uid(req.uid);
    }
    return req;
}

void Block::Client::read(
        Block::Client::Request &req,
        Genode::uint8_t *data,
        Genode::uint64_t length)
{
    Block::Packet_descriptor::Opcode opcode[4] = {
        Block::Packet_descriptor::READ,
        Block::Packet_descriptor::READ,
        Block::Packet_descriptor::WRITE,
        Block::Packet_descriptor::END,
    };
    Block::Packet_descriptor packet(
            Block::Packet_descriptor(
                ((Genode_Packet*)&req.uid)->offset,
                ((Genode_Packet*)&req.uid)->size),
            opcode[req.kind],
            req.start,
            req.length);
    if(length < packet.size()){
        Genode::error (length, " < ", packet.size());
        req.status = ERROR;
    }else{
        Genode::memcpy(data, blk(_device)->tx()->packet_content(packet), packet.size());
        req.status = OK;
    }
}

void Block::Client::acknowledge(Block::Client::Request req)
{
    Block::Packet_descriptor::Opcode opcode[4] = {
        Block::Packet_descriptor::READ,
        Block::Packet_descriptor::READ,
        Block::Packet_descriptor::WRITE,
        Block::Packet_descriptor::END,
    };
    Block::Packet_descriptor packet(
            Block::Packet_descriptor(
                ((Genode_Packet*)&req.uid)->offset,
                ((Genode_Packet*)&req.uid)->size),
            opcode[req.kind],
            req.start,
            req.length);
    if(packet.operation() == Block::Packet_descriptor::READ
            || packet.operation() == Block::Packet_descriptor::WRITE){
        blk(_device)->tx()->release_packet(packet);
    }
}

bool Block::Client::writable()
{
    Block::sector_t sector;
    Genode::size_t size;
    Block::Session::Operations ops;
    blk(_device)->info(&sector, &size, &ops);
    return ops.supported(Block::Packet_descriptor::WRITE);
}

Genode::uint64_t Block::Client::block_count()
{
    return _block_count;
}

Genode::uint64_t Block::Client::block_size()
{
    return _block_size;
}

