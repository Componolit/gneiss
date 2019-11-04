
#include <component.h>

#define ENABLE_TRACE
#include <trace.h>

static void set_status(capability_t *capability, int status)
{
    TRACE("%d\n", status);
    capability->component->status = status;
}

int component_main(component_t *component)
{
    component->capability.component = component;
    component->capability.set_status = &set_status;

    TRACE("%d %p %p %p\n", component->status, component->construct, component->destruct, component->capability.set_status);
    component->construct(&(component->capability));
    TRACE("%d\n", component->status);
    while(component->status == COMPONENT_RUNNING){
        TRACE("%d\n", component->status);
    }
    TRACE("%d\n", component->status);
    component->destruct();
    return component->status;
}
