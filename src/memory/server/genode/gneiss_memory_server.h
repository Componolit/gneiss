
#ifndef _GNEISS_MEMORY_SERVER_H_
#define _GNEISS_MEMORY_SERVER_H_

#include <base/component.h>
#include <base/attached_ram_dataspace.h>

#include <gneiss.h>
#include <gneiss_memory_session.h>

namespace Gneiss
{
    class Memory_Server;
    class Memory_Component;
};

class Gneiss::Memory_Server
{
    friend class Memory_Component;
    private:
        Gneiss::Memory_Component *_component;
        void *_addr;
        long long _size;
        int _index;
        Memory_Server(const Memory_Server &);
        Memory_Server &operator = (Memory_Server const &);
    public:
        Memory_Server();
        void initialize(Genode::Env &, long long);
        Gneiss::Memory_Component *component();
        void finalize();
};

class Gneiss::Memory_Component : public Genode::Rpc_object<Gneiss::Memory_Session>
{
    friend class Memory_Server;
    private:
        Gneiss::Memory_Server *_server;
        Genode::Attached_ram_dataspace _ds;
        Memory_Component(const Memory_Component &);
        Memory_Server &operator = (Memory_Component const &);
    public:
        Memory_Component(Gneiss::Memory_Server *, Genode::Ram_allocator &, Genode::Region_map &, long long);
        Genode::Dataspace_capability dataspace() override;
};

#endif /* ifndef _GNEISS_MEMORY_SERVER_H_ */
