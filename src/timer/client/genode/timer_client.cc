
#include <util/reconstructible.h>
#include <timer_session/connection.h>
#include <base/duration.h>
#include <base/signal.h>
#include <timer_client.h>
#include <factory.h>
#include <cai_capability.h>

//#define ENABLE_TRACE
#include <trace.h>

class Timer_Session
{
    private:
        Timer::Connection _timer;
        Timer::One_shot_timeout<Timer_Session> _timeout;
        Genode::Signal_handler<Timer_Session> _init_sigh;
        Cai::Timer::Client *_client;

        void (*_callback)();
        void (*_init)(Cai::Timer::Client *);

        void handle_event(Genode::Duration);
        void handle_init();

        Timer_Session(const Timer_Session &);
        Timer_Session &operator = (Timer_Session &);

    public:
        Timer_Session(Genode::Env &, void (*)(), void (*)(Cai::Timer::Client *), Cai::Timer::Client *);
        Timer::Connection &timer();
        void update_timeout(Genode::Microseconds);
};

Timer_Session::Timer_Session(Genode::Env &env, void (*callback)(),
                             void (*init)(Cai::Timer::Client *), Cai::Timer::Client *client) :
    _timer(env),
    _timeout(_timer, *this, &Timer_Session::handle_event),
    _init_sigh(env.ep(), *this, &Timer_Session::handle_init),
    _client(client),
    _callback(callback),
    _init(init)
{
    TLOG("callback=", callback);
    Genode::Signal_transmitter(_init_sigh).submit();
}

Timer::Connection &Timer_Session::timer()
{
    return _timer;
}

void Timer_Session::handle_event(Genode::Duration)
{
    TLOG();
    _callback();
}

void Timer_Session::handle_init()
{
    _init(_client);
}

void Timer_Session::update_timeout(Genode::Microseconds d)
{
    TLOG("d=", d);
    if(_timeout.scheduled()){
        _timeout.discard();
    }
    _timeout.schedule(d);
}

Cai::Timer::Client::Client() :
    _session(nullptr),
    _index(0)
{
    TLOG();
}

bool Cai::Timer::Client::initialized()
{
    TLOG();
    return (bool)_session;
}

void Cai::Timer::Client::initialize(void *capability, void *callback, void *init)
{
    TLOG("capability=", capability, "callback=", callback);
    check_factory(_factory, *reinterpret_cast<Cai::Env *>(capability)->env);
    _session = _factory->create<Timer_Session>(*reinterpret_cast<Cai::Env *>(capability)->env,
                                               reinterpret_cast<void (*)()>(callback),
                                               reinterpret_cast<void (*)(Cai::Timer::Client *)>(init),
                                               this);
}

Genode::uint64_t Cai::Timer::Client::clock()
{
    TLOG();
    return reinterpret_cast<Timer_Session *>(_session)->timer().elapsed_us() * 1000;
}

void Cai::Timer::Client::set_timeout(Genode::uint64_t duration)
{
    TLOG("duration=", duration);
    reinterpret_cast<Timer_Session *>(_session)->update_timeout(Genode::Microseconds(duration / 1000));
}

void Cai::Timer::Client::finalize()
{
    TLOG();
    _factory->destroy<Timer_Session>(_session);
    _session = nullptr;
}
