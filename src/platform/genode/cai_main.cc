
#include <base/component.h>
#include <base/signal.h>
#include <cai_capability.h>

//#define ENABLE_TRACE
#include <trace.h>

Genode::Env *__genode_env; // only required for ada-runtime

extern "C" void adainit();
extern "C" void componolit_interfaces_component_construct(Cai::Env *);
extern "C" void componolit_interfaces_component_destruct();

struct Main
{
    Genode::Env &_env;
    Genode::Signal_handler<Main> _exit;
    Cai::Env _cai_env {Cai::Env::Status::RUNNING, &_env, &componolit_interfaces_component_destruct, _exit};

    void exit_handler()
    {
        TLOG();
        _cai_env.destruct();
        adafinal();
        _cai_env.env->parent().exit(_cai_env.status);
    }

    Main(Genode::Env &env) :
        _env(env),
        _exit(env.ep(), *this, &Main::exit_handler)
    {
        TLOG();
        adainit();
        componolit_interfaces_component_construct(&_cai_env);
    }
};

void Component::construct(Genode::Env &env)
{
    __genode_env = &env;
    env.exec_static_constructors();
    static Main inst(env);
}

extern "C" {
    void componolit_interfaces_component_vacate(Cai::Env *env, int status)
    {
        env->status = status;
        Genode::Signal_transmitter(env->exit_signal).submit();
    }
}
