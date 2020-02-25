
#include <factory.h>
#include <gneiss_log_dispatcher.h>

//#define ENABLE_TRACE
#include <trace.h>

Gneiss::Log_Dispatcher::Log_Dispatcher():
    _root(nullptr),
    _env(nullptr),
    _index(0),
    _dispatch(nullptr)
{ }

void Gneiss::Log_Dispatcher::initialize(Gneiss::Capability *capability,
                                        void (*dispatch)(Gneiss::Log_Dispatcher *,
                                                         Gneiss::Log_Dispatcher_Capability *,
                                                         const char *, const char*))
{
    TLOG("capability=", capability, " index=", index);
    _env = capability->env;
    _dispatch = dispatch;
    check_factory(_factory, *(capability->env));
    _root = _factory->create2<Gneiss::Log_Root>(this);
    if(!_root){
        _env = nullptr;
        _dispatch = nullptr;
    }
}

void Gneiss::Log_Dispatcher::register_service()
{
    TLOG("");
    _env->parent().announce(_env->ep().manage(*_root));
}

void Gneiss::Log_Dispatcher::accept(Gneiss::Log_Server *server)
{
    TLOG("server=", server);
    _root->accept(server->component());
}

void Gneiss::Log_Dispatcher::session_initialize(Gneiss::Log_Dispatcher_Capability *, Gneiss::Log_Server *server,
                                                void (*write)(Gneiss::Log_Server *, const char *, int, int*))
{
    TLOG("server=", server, " write=", (void *)write);
    server->initialize(_env, write);
}

void Gneiss::Log_Dispatcher::cleanup(Gneiss::Log_Dispatcher_Capability *cap, Gneiss::Log_Server *server)
{
    TLOG("cap=", cap, " server=", server);
    if(cap->session == server->component()){
        server->finalize();
    }
}

Gneiss::Log_Component *Gneiss::Log_Root::_create_session(const char *args)
{
    TLOG("args=", args);
    Genode::Session_label label;
    Genode::Session_label component;
    Gneiss::Log_Dispatcher_Capability cap = {nullptr};
    Genode::size_t ram_quota = Genode::Arg_string::find_arg(args, "ram_quota").ulong_value(0);

    if(ram_quota < Genode::max((Genode::size_t)4096, sizeof(Gneiss::Log_Component))){
        Genode::warning("Insufficient_ram_quota (", args, ")");
        throw Genode::Insufficient_ram_quota();
    }

    _accepted = nullptr;
    label = Genode::label_from_args(args);
    component = label.prefix();
    label = label.last_element();
    if(component.length() > 1){
        _dispatcher->_dispatch(_dispatcher, &cap, component.string(), label.string());
    }else{
        _dispatcher->_dispatch(_dispatcher, &cap, label.string(), component.string());
    }

    if(!_accepted){
        Genode::warning("Service_denied (", args, ")");
        throw Genode::Service_denied();
    }
    return _accepted;
}

Gneiss::Log_Root::Log_Root(Gneiss::Log_Dispatcher *dispatcher):
    Root_component<Gneiss::Log_Component>(dispatcher->_env->ep(), _factory->alloc()),
    _dispatcher(dispatcher),
    _accepted(nullptr)
{ }

void Gneiss::Log_Root::accept(Gneiss::Log_Component *component)
{
    TLOG("component=", component);
    _accepted = component;
}

void Gneiss::Log_Root::_destroy_session(Gneiss::Log_Component *session)
{
    TLOG("session=", session);
    Gneiss::Log_Dispatcher_Capability cap = {session};
    Genode::Session_label dummy;
    _dispatcher->_dispatch(_dispatcher, &cap, dummy.string(), dummy.string());
}
