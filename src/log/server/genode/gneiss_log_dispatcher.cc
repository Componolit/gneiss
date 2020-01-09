
#include <factory.h>
#include <gneiss_log_dispatcher.h>

#define ENABLE_TRACE
#include <trace.h>

Gneiss::Log_Dispatcher::Log_Dispatcher():
    _root(nullptr),
    _env(nullptr),
    _index(0),
    _dispatch(nullptr)
{ }

void Gneiss::Log_Dispatcher::initialize(Gneiss::Capability *capability, int index,
                                        void (Gneiss::Log_Dispatcher::*dispatch)
                                                (Gneiss::Log_Dispatcher_Capability *, const char *, const char*))
{
    TLOG("capability=", capability, " index=", index);
    _env = capability->env;
    _index = index;
    _dispatch = dispatch;
    check_factory(_factory, *(capability->env));
    _root = _factory->create2<Gneiss::Log_Root>(this);
    if(!_root){
        _env = nullptr;
        _index = 0;
        _dispatch = nullptr;
    }
}

void Gneiss::Log_Dispatcher::register_service()
{
    TLOG("");
    _env->parent().announce(_env->ep().manage(*_root));
}

Gneiss::Log_Component *Gneiss::Log_Root::_create_session(const char *args)
{
    TLOG("args=", args);
    Genode::log(args);
    throw Genode::Service_denied();
}

Gneiss::Log_Root::Log_Root(Gneiss::Log_Dispatcher *dispatcher):
    Root_component<Gneiss::Log_Component>(dispatcher->_env->ep(), _factory->alloc()),
    _dispatcher(dispatcher)
{ }
