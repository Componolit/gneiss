
#include <gneiss_memory_client.h>

#include <factory.h>

//#define ENABLE_TRACE
#include <trace.h>

Gneiss::Memory_Client::Memory_Client() :
    _session(nullptr),
    _index(0),
    _size(0),
    _addr(nullptr)
{ }

void Gneiss::Memory_Client::initialize(Gneiss::Capability *capability, const char *label, long long size, void(*event)(Gneiss::Memory_Client *))
{
    TLOG("capability=", capability, " label=", Genode::Cstring(label), " size=", size, " event=", event);
    check_factory(_factory, *(capability->env));
    _size = size;
    _session = _factory->create2<Gneiss::Memory_Connection>(*(capability->env), label, size, event, this);
    if(_session){
        _addr = capability->env->rm().attach(_session->dataspace());
        Genode::Signal_transmitter(_session->_init).submit();
    }
}

void Gneiss::Memory_Client::finalize()
{
    TLOG("");
    _factory->destroy<Gneiss::Memory_Connection>(_session);
    _session = nullptr;
    _addr = nullptr;
}

Gneiss::Memory_Connection::Memory_Connection (Genode::Env &env, Genode::Session_label label, long long size,
                                              void (*event)(Gneiss::Memory_Client *),
                                              Gneiss::Memory_Client *client) :
    Genode::Connection<Gneiss::Memory_Session>(env, session(env.parent(),
            "ram_quota=%ld, cap_quota=%ld, label=\"%s\", memory_size=%lld",
            RAM_QUOTA + size, CAP_QUOTA, label.string(), size)),
    Gneiss::Memory_Session_Client(cap()),
    _init(env.ep(), *this, &Gneiss::Memory_Connection::init),
    _client(client),
    _event(event)
{
    TLOG("label=", label, " size=", size, " event=", event);
    if(!_event){
        throw 1;
    }
}

void Gneiss::Memory_Connection::init()
{
    TLOG("");
    _event(_client);
}
