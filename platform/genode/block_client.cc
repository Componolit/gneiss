

#include <base/heap.h>
#include <block_session/connection.h>
#include <util/string.h>
#include <ada/exception.h>

#include <genode_packet.h>
namespace Cai {
#include <block.h>
}

#include <factory.h>

extern "C"
{
    void __gnat_rcheck_CE_Access_Check()
    {
        throw Ada::Exception::Access_Check();
    }
}

extern Genode::Env *__genode_env;
static Factory _factory {*__genode_env};

struct Block_session
{
        Genode::Heap _heap;
        Genode::Allocator_avl _alloc;
        Block::Connection _block;
        Genode::Io_signal_handler<Block_session> _event_handler;
        Genode::uint64_t _block_count;
        Genode::uint64_t _block_size;
        Genode::uint64_t _buffer_size;
        void (*_event)();

        void callback()
        {
            _event();
        }

        Block_session(
                Genode::Env &env,
                Genode::size_t size,
                const char *device,
                void (*event)()) :
            _heap(env.ram(), env.rm()),
            _alloc(&_heap),
            _block(env, &_alloc, size, device),
            _event_handler(env.ep(), *this, &Block_session::callback),
            _block_count(0),
            _block_size(0),
            _buffer_size(0),
            _event(event)
        {
            Genode::size_t blk_size;
            Genode::uint64_t alloc_size;
            ::Block::Session::Operations ops;
            _block.info(&_block_count, &blk_size, &ops);
            _block_size = blk_size;
            alloc_size = _alloc.avail();
            _buffer_size = alloc_size - (alloc_size % _block_size);
            _block.tx_channel()->sigh_ack_avail(_event_handler);
            _block.tx_channel()->sigh_ready_to_submit(_event_handler);
        }

};

inline ::Block::Connection *blk(void *device)
{
    return &(reinterpret_cast<Block_session *>(device)->_block);
}

class Packet_allocator
{
    private:
        ::Block::Packet_descriptor _alloc_packet;

    public:
        Packet_allocator() :
            _alloc_packet()
    { }

        void free(Block_session *device)
        {
            if(_alloc_packet.size()){
                device->_block.tx()->release_packet(_alloc_packet);
            }
        }

        void reallocate(Block_session *device, Genode::uint64_t size)
        {
            if(size != _alloc_packet.size()){
                free(device);
                _alloc_packet = device->_block.tx()->alloc_packet(size, 0);
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

static const ::Block::Packet_descriptor empty_packet = ::Block::Packet_descriptor();

static bool packet_empty(::Block::Packet_descriptor const &packet)
{
    return packet.operation() == empty_packet.operation()
        && packet.block_number() == empty_packet.block_number()
        && packet.block_count() == empty_packet.block_count()
        && packet.succeeded() == empty_packet.succeeded();
}

static ::Block::Packet_descriptor last_ack = empty_packet;

extern "C" {

    Genode::uint64_t cai_block_client_block_count(Block_session *session)
    {
        return session->_block_count;
    }

    Genode::uint64_t cai_block_client_block_size(Block_session *session)
    {
        return session->_block_size;
    }

    Genode::uint64_t cai_block_client_maximal_transfer_size(Block_session *session)
    {
        return session->_buffer_size;
    }

    void cai_block_client_initialize(
            Block_session **session,
            const char *device,
            void (*callback)(),
            Genode::uint64_t buffer_size)
    {
        const char default_device[] = "";
        Genode::size_t const buf_size = buffer_size ? buffer_size : 128 * 1024;
        *session = _factory.create<Block_session>(
                *__genode_env,
                buf_size,
                device ? device : default_device,
                callback);
    }

    void cai_block_client_finalize(Block_session **session)
    {
        _factory.destroy<Block_session>(*session);
        *session = nullptr;
    }

    bool cai_block_client_ready(Block_session *session, Cai::Block::Request req)
    {
        if(req.kind == Cai::Block::READ || req.kind == Cai::Block::WRITE){
            try {
                _packet_allocator.reallocate(session, cai_block_client_block_size(session) * req.length);
            } catch (...) {
                return false;
            }
        }
        return session->_block.tx()->ready_to_submit()
                || req.kind == Cai::Block::SYNC
                || req.kind == Cai::Block::TRIM;
    }

    bool cai_block_client_supported(Block_session *, Cai::Block::Request req)
    {
        return req.kind == Cai::Block::READ || req.kind == Cai::Block::WRITE;
    }

    void cai_block_client_enqueue_read(Block_session *session, Cai::Block::Request req)
    {
        _packet_allocator.reallocate(session, cai_block_client_block_size(session) * req.length);
        ::Block::Packet_descriptor packet(
                _packet_allocator.take(),
                ::Block::Packet_descriptor::READ,
                req.start, req.length);
        session->_block.tx()->submit_packet(packet);
    }

    void cai_block_client_enqueue_write(
            Block_session *session,
            Cai::Block::Request req,
            Genode::uint8_t *data)
    {
        _packet_allocator.reallocate(session, cai_block_client_block_size(session) * req.length);
        ::Block::Packet_descriptor packet(
                _packet_allocator.take(),
                ::Block::Packet_descriptor::WRITE,
                req.start, req.length);
        Genode::memcpy(session->_block.tx()->packet_content(packet), data, req.length * cai_block_client_block_size(session));
        session->_block.tx()->submit_packet(packet);
    }

    void cai_block_client_enqueue_sync(Block_session *, Cai::Block::Request)
    { }

    void cai_block_client_enqueue_trim(Block_session *, Cai::Block::Request)
    { }

    void cai_block_client_submit(Block_session *)
    { }

    Cai::Block::Request cai_block_client_next(Block_session *session)
    {
        Cai::Block::Request req = {Cai::Block::NONE, {}, 0, 0, Cai::Block::RAW};
        if(packet_empty(last_ack)){
            if(session->_block.tx()->ack_avail()){
                last_ack = session->_block.tx()->get_acked_packet();
                req = create_cai_block_request (last_ack);
            }
        }else{
            req = create_cai_block_request (last_ack);
        }
        return req;
    }

    void cai_block_client_read(
            Block_session *session,
            Cai::Block::Request req,
            Genode::uint8_t *data)
    {
        ::Block::Packet_descriptor packet = create_packet_descriptor(req);
        Genode::memcpy(data, session->_block.tx()->packet_content(packet), packet.size());
    }


    void cai_block_client_release(Block_session *session, Cai::Block::Request)
    {
        if(last_ack.operation() == ::Block::Packet_descriptor::READ
                || last_ack.operation() == ::Block::Packet_descriptor::WRITE){
            session->_block.tx()->release_packet(last_ack);
        }
        last_ack = empty_packet;
    }

    bool cai_block_client_writable(Block_session *session)
    {
        ::Block::sector_t sector;
        Genode::size_t size;
        ::Block::Session::Operations ops;
        session->_block.info(&sector, &size, &ops);
        return ops.supported(::Block::Packet_descriptor::WRITE);
    }

}
