
#ifndef _GNEISS_MEMORY_SESSION_H_
#define _GNEISS_MEMORY_SESSION_H_

#include <session/session.h>
#include <base/rpc.h>
#include <dataspace/capability.h>

namespace Gneiss
{
    struct Memory_Session;
};

struct Gneiss::Memory_Session : Genode::Session
{

    static const char *service_name() { return "Gneiss_Memory"; }

    enum { CAP_QUOTA = 3 };

    virtual Genode::Dataspace_capability dataspace() = 0;

    GENODE_RPC(Rpc_dataspace, Genode::Dataspace_capability, dataspace);
    GENODE_RPC_INTERFACE(Rpc_dataspace);
};

#endif /* ifndef _GNEISS_MEMORY_SESSION_H_ */
