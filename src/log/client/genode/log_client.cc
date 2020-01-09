
#include <util/string.h>
#include <util/reconstructible.h>
#include <log_session/connection.h>
#include <base/signal.h>
#include <cai_capability.h>

//#define ENABLE_TRACE
#include <trace.h>

namespace Cai
{
#include <log_client.h>
}
#include <factory.h>

struct Log_session
{
    enum {WRITE_BUFFER = Genode::Log_session::MAX_STRING_LEN - 1};
    Genode::Log_connection _log;
    Genode::Signal_handler<Log_session> _init;
    void (*_init_event)();

    Log_session(Genode::Env &env, const char *label, void (*init_event)()) :
        _log(env, label),
        _init(env.ep(), *this, &Log_session::event_handler),
        _init_event(init_event)
    {
        TLOG("label=", label);
    }

    void event_handler()
    {
        _init_event();
    }
};

static Log_session *log(void *session)
{
    TLOG("session=", session);
    return static_cast<Log_session *>(session);
}

Cai::Log::Client::Client() :
    _session(nullptr)
{ }

bool Cai::Log::Client::initialized()
{
    TLOG();
    return (bool)_session;
}

void Cai::Log::Client::initialize(void *env, const char *label, void (*event)(void))
{
    TLOG("env=", env, " label=", label);
    check_factory(_factory, *reinterpret_cast<Cai::Env *>(env)->env);
    _session = _factory->create<Log_session>(
            *reinterpret_cast<Cai::Env *>(env)->env,
            label, event);
    Genode::Signal_transmitter(log(_session)->_init).submit();
}

void Cai::Log::Client::finalize()
{
    TLOG();
    _factory->destroy<Log_session>(_session);
    _session = nullptr;
}

void Cai::Log::Client::write(const char *message)
{
    TLOG("message=", message);
    log(_session)->_log.write(message);
}

Genode::uint64_t Cai::Log::Client::maximum_message_length()
{
    TLOG();
    static_assert(Genode::Log_session::MAX_STRING_LEN - 16 > 79);
    return Genode::Log_session::MAX_STRING_LEN - 16;
}
