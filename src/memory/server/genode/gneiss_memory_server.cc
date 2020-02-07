
#include <gneiss_memory_server.h>
#include <factory.h>

#define ENABLE_TRACE
#include <trace.h>

Gneiss::Memory_Server::Memory_Server() :
    _component(nullptr),
    _modify(nullptr),
    _index(0)
{ }

void Gneiss::Memory_Server::initialize(Genode::Env &env, void(*modify)(Gneiss::Memory_Server *, void *, int), int size)
{
    TLOG("");
    check_factory(_factory, env);
    _component = _factory->create2<Gneiss::Memory_Component>(this, env.ram(), env.rm(), size);
    if(_component){
        _modify = modify;
    }
}

void Gneiss::Memory_Server::modify()
{
    TLOG("");
    //FIXME: how to attach dataspace
    //Genode::Attached_ram_dataspace ds(_component->dataspace());
    //_modify(this, ds.local_addr<void>(), ds.size());
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
    _modify = nullptr;
}

Gneiss::Memory_Component::Memory_Component(Gneiss::Memory_Server *server,
                                           Genode::Ram_allocator &ram,
                                           Genode::Region_map &rm, int size) :
    _server(server),
    _ds(ram, rm, size)
{ }

Genode::Dataspace_capability Gneiss::Memory_Component::dataspace()
{
    TLOG("");
    return _ds.cap();
}
