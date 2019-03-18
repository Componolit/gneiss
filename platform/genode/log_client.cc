
#include <util/string.h>
#include <log_session/connection.h>

namespace Cai
{
#include <log_client.h>
}
#include <factory.h>

extern Genode::Env *__genode_env;
static Factory _factory {*__genode_env};

Cai::Log::Client::Client() :
    _session(nullptr)
{ }

bool Cai::Log::Client::initialized()
{
    return (bool)_session;
}

void Cai::Log::Client::initialize(const char *label, Genode::uint64_t)
{
    _session = _factory.create<Genode::Log_connection>(
            *__genode_env,
            label);
}

void Cai::Log::Client::finalize()
{
    _factory.destroy<Genode::Log_connection>(_session);
    _session = nullptr;
}

static Genode::Log_connection *log(void *session)
{
    return static_cast<Genode::Log_connection *>(session);
}

void Cai::Log::Client::write(const char *message)
{
    log(_session)->write(message);
}

Genode::uint64_t Cai::Log::Client::maximal_message_length()
{
    static_assert(Genode::Log_session::MAX_STRING_LEN - 16 > 79);
    return Genode::Log_session::MAX_STRING_LEN - 16;
}
