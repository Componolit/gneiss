
#include <base/env.h>
#include <factory.h>
#include <gneiss_log_server.h>

//#define ENABLE_TRACE
#include <trace.h>

Gneiss::Log_Server::Log_Server() :
    _component(nullptr),
    _write(nullptr),
    _index(0)
{
    TLOG("");
}

void Gneiss::Log_Server::initialize(Gneiss::Log_Component *component,
                                    void(*write)(Gneiss::Log_Server *, const char *, int, int *))
{
    TLOG("component=", component, " write=", write);
    if(!component || !write){
        return;
    }
    _component = component;
    _write = write;
}

Gneiss::Log_Component *Gneiss::Log_Server::component()
{
    TLOG("");
    return _component;
}

void Gneiss::Log_Server::finalize()
{
    TLOG("");
    _component = nullptr;
    _write = nullptr;
}

Gneiss::Log_Component::Log_Component(Gneiss::Log_Server *server):
    _server(server)
{ }

Genode::size_t Gneiss::Log_Component::write(Genode::Log_session::String const &data)
{
    TLOG("data=", data.string());
    Genode::size_t size;
    _server->_write(_server, data.string(), Genode::strlen(data.string()), (int *)&size);
    return size;
}
