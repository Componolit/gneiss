
#include <gneiss_memory_server.h>
#include <factory.h>

//#define ENABLE_TRACE
#include <trace.h>

Gneiss::Memory_Server::Memory_Server() :
    _component(nullptr),
    _addr(nullptr),
    _size(0),
    _index(0)
{ }

void Gneiss::Memory_Server::initialize(Genode::Env &env, long long size)
{
    TLOG("size=", size);
    check_factory(_factory, env);
    _component = _factory->create2<Gneiss::Memory_Component>(this, env.ram(), env.rm(), size);
}

Gneiss::Memory_Component *Gneiss::Memory_Server::component()
{
    TLOG("");
    return _component;
}

void Gneiss::Memory_Server::finalize()
{
    TLOG("");
    _factory->destroy<Gneiss::Memory_Component>(_component);
    _component = nullptr;
    _addr = nullptr;
}

Gneiss::Memory_Component::Memory_Component(Gneiss::Memory_Server *server,
                                           Genode::Ram_allocator &ram,
                                           Genode::Region_map &rm, long long size) :
    _server(server),
    _ds(ram, rm, size)
{
    TLOG("server=", server, " size=", size);
    _server->_addr = _ds.local_addr<void>();
    _server->_size = _ds.size();
}

Genode::Dataspace_capability Gneiss::Memory_Component::dataspace()
{
    TLOG("");
    return _ds.cap();
}
