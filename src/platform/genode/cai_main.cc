
#include <base/component.h>

Genode::Env *__genode_env; // only required for ada-runtime

extern "C" void adainit();
extern "C" void cai_component_construct(Genode::Env *);

void Component::construct(Genode::Env &env)
{
    __genode_env = &env;
    env.exec_static_constructors();
    adainit();
    cai_component_construct(&env);
}
