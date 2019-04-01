
#include <spark/component.h>

extern "C" void cai_component_construct(void);

Spark::Component::Result Spark::Component::construct()
{
    cai_component_construct();
    return Spark::Component::Result::CONT;
}
