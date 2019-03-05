
#ifndef _GENODE_PACKET_H_
#define _GENODE_PACKET_H_

#include <block_session/block_session.h>
#include <block/request_stream.h>
namespace Cai {
#include <block.h>
}

struct Genode_Packet
{
    Genode::uint64_t offset;
    Genode::uint64_t size;

    Genode_Packet(Genode::uint64_t o, Genode::uint64_t s) :
        offset(o),
        size(s)
    { }
};

inline Block::Packet_descriptor create_packet_descriptor(const Cai::Block::Request &r)
{
    Block::Packet_descriptor::Opcode opcode[4] = {
        Block::Packet_descriptor::END,
        Block::Packet_descriptor::READ,
        Block::Packet_descriptor::WRITE,
        Block::Packet_descriptor::END
    };
    return Block::Packet_descriptor(
            Block::Packet_descriptor(
                ((Genode_Packet*)&r.uid)->offset,
                ((Genode_Packet*)&r.uid)->size),
            opcode[r.kind],
            r.start,
            r.length);
}

inline Cai::Block::Request create_cai_block_request(const Block::Packet_descriptor &p)
{
    Cai::Block::Kind request_kind[3] = {
        Cai::Block::READ,
        Cai::Block::WRITE,
        Cai::Block::NONE
    };
    Cai::Block::Request req = {
        request_kind[p.operation()],
        {},
        p.block_number(),
        p.block_count(),
        p.succeeded() ? Cai::Block::OK : Cai::Block::ERROR
    };
    ((Genode_Packet*)&req.uid)->offset = p.offset();
    ((Genode_Packet*)&req.uid)->size = p.size();
    return req;
}

inline Cai::Block::Request create_cai_block_request(const Block::Request &r)
{
    Cai::Block::Status request_status[2] = {
        Cai::Block::Status::ERROR,
        Cai::Block::Status::OK
    };
    Cai::Block::Request req = {
        static_cast<Cai::Block::Kind>(r.operation),
        {},
        r.block_number,
        0,
        request_status[static_cast<Genode::uint32_t>(r.success)]
    };
    *reinterpret_cast<Genode::uint64_t*>(&req.uid) = r.offset;
    reinterpret_cast<Genode::uint32_t*>(&req.length)[0] = r.count;
    return req;
}

inline Block::Request create_genode_block_request(const Cai::Block::Request &req)
{
    Block::Request r = {
        static_cast<Block::Request::Operation>(req.kind),
        req.status == Cai::Block::Status::ERROR ?
            Block::Request::Success::FALSE : Block::Request::Success::TRUE,
        req.start,
        *(reinterpret_cast<const Genode::uint64_t *>(&req.uid)),
        reinterpret_cast<const Genode::uint32_t*>(&req.length)[0]
    };
    return r;
}

#endif
