
#include <util/reconstructible.h>
#include <timer_session/connection.h>
#include <timer_client.h>
#include <factory.h>

static Genode::Constructible<Factory> _factory;

Cai::Timer::Client::Client() :
    _session(nullptr)
{ }

bool Cai::Timer::Client::initialized()
{
    return (bool)_session;
}

void Cai::Timer::Client::initialize(void *capability)
{
    check_factory(_factory, *reinterpret_cast<Genode::Env *>(capability));
    _session = _factory->create<::Timer::Connection>(*reinterpret_cast<Genode::Env *>(capability));
}

Genode::uint64_t Cai::Timer::Client::clock()
{
    return reinterpret_cast<::Timer::Connection *>(_session)->elapsed_us();
}

void Cai::Timer::Client::finalize()
{
    _factory->destroy<::Timer::Connection>(_session);
    _session = nullptr;
}
