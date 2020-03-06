
#include <gneiss_memory_client.h>

#include <factory.h>

//#define ENABLE_TRACE
#include <trace.h>

Gneiss::Memory_Client::Memory_Client() :
    _session(nullptr),
    _index(0)
{ }

void Gneiss::Memory_Client::initialize(Gneiss::Capability *capability, const char *label, long long size, void(*event)(Gneiss::Memory_Client *))
{
    TLOG("capability=", capability, " label=", Genode::Cstring(label), " size=", size, " event=", event);
    check_factory(_factory, *(capability->env));
    _session = _factory->create2<Gneiss::Memory_Connection>(*(capability->env), label, size, event, *this);
    if(_session){
        Genode::Signal_transmitter(_session->_init).submit();
    }
}

void *Gneiss::Memory_Client::address()
{
    return _session->local_addr<void>();
}

long long Gneiss::Memory_Client::size()
{
    return _session->size();
}

void Gneiss::Memory_Client::finalize()
{
    TLOG("");
    _factory->destroy<Gneiss::Memory_Connection>(_session);
    _session = nullptr;
}

Gneiss::Memory_Connection::Memory_Connection(Genode::Env &env, Genode::Session_label label, long long size,
                                             void (*event)(Gneiss::Memory_Client *),
                                             Gneiss::Memory_Client &client) :
    Genode::Connection<Gneiss::Memory_Session>(env, session(env.parent(),
            "ram_quota=%ld, cap_quota=%ld, label=\"%s\", memory_size=%lld",
            RAM_QUOTA + size, CAP_QUOTA, label.string(), size)),
    Gneiss::Memory_Session_Client(cap()),
    _init(env.ep(), *this, &Gneiss::Memory_Connection::init),
    _client(&client),
    _event(event),
    _addr(env.rm().attach(dataspace())),
    _size(size)
{
    TLOG("label=", label, " size=", size, " event=", event);
    if(!_event){
        throw 1;
    }
}

Gneiss::Memory_Connection::Memory_Connection(Genode::Env &env, Genode::size_t size, Genode::Session_label label) :
    Genode::Connection<Gneiss::Memory_Session>(env, session(env.parent(),
            "ram_quota=%ld, cap_quota=%ld, label=\"%s\", memory_size=%lld",
            RAM_QUOTA + size, CAP_QUOTA, label.string(), size)),
    Gneiss::Memory_Session_Client(cap()),
    _init(env.ep(), *this, &Gneiss::Memory_Connection::dummy_init),
    _client(nullptr),
    _event(nullptr),
    _addr(env.rm().attach(dataspace())),
    _size(size)
{ }

Genode::size_t Gneiss::Memory_Connection::size()
{
    return _size;
}

void Gneiss::Memory_Connection::init()
{
    TLOG("");
    _event(_client);
}

void Gneiss::Memory_Connection::dummy_init()
{ }
