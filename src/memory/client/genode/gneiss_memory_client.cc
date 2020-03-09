
#include <gneiss_memory_client.h>

#include <factory.h>

//#define ENABLE_TRACE
#include <trace.h>

Gneiss::Memory_Client::Memory_Client() :
    _session(nullptr),
    _index(0)
{ }

void Gneiss::Memory_Client::initialize(Gneiss::Capability *capability, const char *label, long long size)
{
    TLOG("capability=", capability, " label=", Genode::Cstring(label), " size=", size, " event=", event);
    check_factory(_factory, *(capability->env));
    _session = _factory->create2<Gneiss::Memory_Connection>(*(capability->env), size, label);
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

Gneiss::Memory_Connection::Memory_Connection(Genode::Env &env, Genode::size_t size, Genode::Session_label label) :
    Genode::Connection<Gneiss::Memory_Session>(env, session(env.parent(),
            "ram_quota=%ld, cap_quota=%ld, label=\"%s\", memory_size=%lld",
            RAM_QUOTA + size, CAP_QUOTA, label.string(), size)),
    Gneiss::Memory_Session_Client(cap()),
    _addr(env.rm().attach(dataspace())),
    _size(size)
{
    TLOG("size=", size, " label=", label);
}

Genode::size_t Gneiss::Memory_Connection::size()
{
    TLOG("");
    return _size;
}
