
#include <base/component.h>

Genode::Env *__genode_env; // only required for ada-runtime

extern "C" void adainit();
extern "C" void cai_component_construct(Genode::Env *);
extern "C" void adafinal();

void Component::construct(Genode::Env &env)
{
    __genode_env = &env;
    env.exec_static_constructors();
    adainit();
    cai_component_construct(&env);
}

extern "C" {
    void cai_component_exit(Genode::Env *env, int status)
    {
        adafinal();
        env->parent().exit(status);
    }
}
