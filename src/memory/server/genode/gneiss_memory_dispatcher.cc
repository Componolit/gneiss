
#include <gneiss_memory_dispatcher.h>
#include <factory.h>

//#define ENABLE_TRACE
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
    TLOG("capability=", capability, " dispatch=", dispatch);
    check_factory(_factory, *(capability->env));
    _dispatch = dispatch;
    _env = capability->env;
    _root = _factory->create2<Gneiss::Memory_Root>(this);
    if(!_root){
        _dispatch = nullptr;
        _env = nullptr;
    }
}

void Gneiss::Memory_Dispatcher::session_initialize(Gneiss::Memory_Dispatcher_Capability *capability,
                                                   Gneiss::Memory_Server *server)
{
    TLOG("capability=", capability, " server=", server);
    server->initialize(*_env, capability->size);
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

Gneiss::Memory_Component *Gneiss::Memory_Root::_create_session(const char *args)
{
    TLOG("args=", Genode::Cstring(args));
    Genode::Session_label name;
    Genode::Session_label label;
    Gneiss::Memory_Dispatcher_Capability cap = {nullptr, Genode::Arg_string::find_arg(args, "memory_size").long_value(0)};
    Genode::size_t ram_quota = Genode::Arg_string::find_arg(args, "ram_quota").ulong_value(0);

    if(ram_quota < Genode::max((Genode::size_t)4096, sizeof(Gneiss::Memory_Component))){
        Genode::warning("Insufficient_ram_quota (", args, ")");
        throw Genode::Insufficient_ram_quota();
    }

    _accepted = nullptr;
    label = Genode::label_from_args(args);
    name = label.prefix();
    label = label.last_element();
    if(name.length() > 1){
        _dispatcher->_dispatch(_dispatcher, &cap, name.string(), label.string());
    }else{
        _dispatcher->_dispatch(_dispatcher, &cap, label.string(), name.string());
    }

    if(!_accepted){
        Genode::warning("Service_denied (", args, ")");
        throw Genode::Service_denied();
    }
    return _accepted;
}

void Gneiss::Memory_Root::_destroy_session(Gneiss::Memory_Component *session)
{
    TLOG("session=", session);
    Genode::Session_label dummy;
    Gneiss::Memory_Dispatcher_Capability cap = {session, 0};
    _dispatcher->_dispatch(_dispatcher, &cap, dummy.string(), dummy.string());
}

Gneiss::Memory_Root::Memory_Root(Gneiss::Memory_Dispatcher *dispatcher) :
    Genode::Root_component<Gneiss::Memory_Component>(dispatcher->_env->ep(), _factory->alloc()),
    _dispatcher(dispatcher),
    _accepted(nullptr)
{
    TLOG("dispatcher=", dispatcher);
}
