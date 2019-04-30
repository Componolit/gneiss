
#include <base/component.h>
#include <cai_capability.h>

Genode::Env *__genode_env; // only required for ada-runtime

extern "C" void adainit();
extern "C" void cai_component_construct(Cai::Env *);
extern "C" void cai_component_destruct();

static Cai::Env cai_env {Cai::Env::Status::RUNNING, 0, 0};

void Component::construct(Genode::Env &env)
{
    __genode_env = &env;
    cai_env.env = &env;
    cai_env.destruct = &cai_component_destruct;
    env.exec_static_constructors();
    adainit();
    cai_component_construct(&cai_env);
    cai_env.cgc();
}

extern "C" {
    void cai_component_vacate(Cai::Env *env, int status)
    {
        env->status = status;
    }
}
