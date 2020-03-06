
#include <gneiss_log_client.h>

#include <factory.h>

//#define ENABLE_TRACE
#include <trace.h>

Gneiss::Log_Client::Log_Client() :
    _session(nullptr),
    _buffer(),
    _cursor(0)
{ }

void Gneiss::Log_Client::initialize(Gneiss::Capability *cap, const char *label)
{
    TLOG("cap=", cap, " label=", label);
    check_factory(_factory, *(cap->env));
    _session = _factory->create2<Genode::Log_connection>(*(cap->env), label);
}

void Gneiss::Log_Client::write(const char *msg)
{
    _session->write(msg);
}

void Gneiss::Log_Client::finalize()
{
    _factory->destroy<Genode::Log_connection>(_session);
    _session = nullptr;
}
