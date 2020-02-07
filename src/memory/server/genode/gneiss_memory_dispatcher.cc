
#include <gneiss_memory_dispatcher.h>
#include <factory.h>

#define ENABLE_TRACE
#include <trace.h>

Gneiss::Memory_Dispatcher::Memory_Dispatcher() :
    _root(nullptr),
    _env(nullptr),
    _index(0),
    _dispatch(nullptr)
{ }

void Gneiss::Memory_Dispatcher::initialize(Gneiss::Capability *capability,
                                           void (*dispatch)(Gneiss::Memory_Dispatcher *,
                                                            Gneiss::Memory_Dispatcher_Capability *,
                                                            const char *, const char *))
{
    TLOG("capability=", capability);
    check_factory(_factory, *(capability->env));
    _root = _factory->create2<Gneiss::Memory_Root>(this);
    if(_root){
        _dispatch = dispatch;
        _env = capability->env;
    }
}

void Gneiss::Memory_Dispatcher::session_initialize(Gneiss::Memory_Dispatcher_Capability *capability,
                                                   Gneiss::Memory_Server *server,
                                                   void (*modify)(Gneiss::Memory_Server *, void *, int))
{
    TLOG("capability=", capability, " server=", server);
    server->initialize(*_env, modify, 0);
    //TODO: use capability to fill memory size (0)
}

void Gneiss::Memory_Dispatcher::register_service()
{
    TLOG("");
    _env->parent().announce(_env->ep().manage(*_root));
}

void Gneiss::Memory_Dispatcher::accept(Gneiss::Memory_Server *server)
{
    TLOG("server=", server);
    _root->_accepted = server->component();
}

void Gneiss::Memory_Dispatcher::cleanup(Gneiss::Memory_Dispatcher_Capability *capability, Gneiss::Memory_Server *server)
{
    TLOG("capability=", capability, " server=", server);
}

Gneiss::Memory_Component *Gneiss::Memory_Root::_create_session(const char *args)
{
    TLOG("args=", Genode::Cstring(args));
    return nullptr;
}

void Gneiss::Memory_Root::_destroy_session(Gneiss::Memory_Component *session)
{
    TLOG("session=", session);
}

Gneiss::Memory_Root::Memory_Root(Gneiss::Memory_Dispatcher *dispatcher) :
    Genode::Root_component<Gneiss::Memory_Component>(dispatcher->_env->ep(), _factory->alloc()),
    _dispatcher(dispatcher),
    _accepted(nullptr)
{
    TLOG("dispatcher=", dispatcher);
}
