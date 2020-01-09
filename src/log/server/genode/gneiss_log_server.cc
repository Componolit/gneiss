
#include <factory.h>
#include <gneiss_log_server.h>

//#define ENABLE_TRACE
#include <trace.h>

Gneiss::Log_Server::Log_Server() :
    _component(nullptr),
    _event(nullptr),
    _write(nullptr)
{ }

void Gneiss::Log_Server::initialize(Gneiss::Capability *cap, void (*event)(), void(Gneiss::Log_Server::*write)(const char *, int, int *))
{
    TLOG("event=", (void *)event, "write=", (void *)callback);
    if(!event || !write){
        return;
    }
    check_factory(_factory, *(cap->env));
    _component = _factory->create2<Gneiss::Log_Component>(this);
    if(_component){
        _event = event;
        _write = write;
    }
}

Gneiss::Log_Component *Gneiss::Log_Server::component()
{
    return _component;
}

Gneiss::Log_Component::Log_Component(Gneiss::Log_Server *server):
    _server(server)
{ }

Genode::size_t Gneiss::Log_Component::write(Genode::Log_session::String const &data)
{
    Genode::size_t size;
    (_server->*(_server->_write))(data.string(), Genode::strlen(data.string()), (int *)&size);
    return size;
}
