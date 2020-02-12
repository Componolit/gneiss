
#ifndef _GNEISS_MESSAGE_SESSION_H_
#define _GNEISS_MESSAGE_SESSION_H_

#include <session/session.h>
#include <base/signal.h>
#include <base/rpc.h>

namespace Gneiss
{
    struct Message_Session;
}

struct Gneiss::Message_Session : Genode::Session
{
    static const char *service_name() { return "Gneiss_Message"; }

    enum { CAP_QUOTA = 3 };

    typedef struct Message_Buffer { unsigned char buf [128]; } Message_Buffer;

    virtual void sigh(Genode::Signal_context_capability) = 0;

    virtual void write(Message_Buffer const &) = 0;

    virtual Message_Buffer read() = 0;

    virtual bool avail() = 0;

    GENODE_RPC(Rpc_sigh, void, sigh, Genode::Signal_context_capability);
    GENODE_RPC(Rpc_write, void, write, Message_Buffer const &);
    GENODE_RPC(Rpc_read, Message_Buffer, read);
    GENODE_RPC(Rpc_avail, bool, avail);
    GENODE_RPC_INTERFACE(Rpc_sigh, Rpc_write, Rpc_read, Rpc_avail);
};

#endif /* ifndef _GNEISS_MESSAGE_SESSION_H_ */
