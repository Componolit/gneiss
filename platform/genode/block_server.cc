
#include <block/driver.h>

#include <cai_block_server.h>
#include <genode_packet.h>
namespace Cai {
#include <block_server.h>
}

Cai::Block::Server::Server(void *session, void *state) :
    _session(session),
    _state(state)
{ }

static Genode::Constructible<Block_session_component> *blk(void *session)
{
    return static_cast<Genode::Constructible<Block_session_component> *>(session);
}

void Cai::Block::Server::acknowledge(Cai::Block::Request &req)
{
    if(_session && (*blk(_session)).constructed()){
        (*blk(_session))->try_acknowledge([&] (Block_session_component::Ack &ack){
                if(req.status != Cai::Block::ACK){
                    ack.submit(create_genode_block_request(req));
                    req.status = Cai::Block::ACK;
                }
        });
    }else{
        Genode::error("Failed to acknowledge, session not initialized");
    }
}
