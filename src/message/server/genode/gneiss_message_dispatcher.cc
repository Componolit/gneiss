
#include <gneiss_message_dispatcher.h>
#include <factory.h>

//#define ENABLE_TRACE
#include <trace.h>

Gneiss::Message_Dispatcher::Message_Dispatcher() :
    _root(nullptr),
    _dispatch(nullptr),
    _env(nullptr),
    _index(0)
{ }

void Gneiss::Message_Dispatcher::initialize(Gneiss::Capability *capability)
{
    TLOG("capability=", capability);
    check_factory(_factory, *(capability->env));
    _env = capability->env;
    _root = _factory->create2<Gneiss::Message_Root>(this);
    if(!_root){
        _env = nullptr;
    }
}

void Gneiss::Message_Dispatcher::session_initialize(Gneiss::Message_Server *server,
                        int (*avail)(Gneiss::Message_Server *),
                        void (*recv)(Gneiss::Message_Server *, const Gneiss::Message_Session::Message_Buffer *),
                        void (*get)(Gneiss::Message_Server *, Gneiss::Message_Session::Message_Buffer *))
{
    TLOG("server=", server, " avail=", avail, " recv=", recv, " get=", get);
    server->initialize(*_env, avail, recv, get);
}

void Gneiss::Message_Dispatcher::register_service()
{
    TLOG("");
    _env->parent().announce(_env->ep().manage(*_root));
}

void Gneiss::Message_Dispatcher::accept(Gneiss::Message_Server *server)
{
    TLOG("server=", server);
    _root->_accepted = server->component();
}

Gneiss::Message_Root::Message_Root(Gneiss::Message_Dispatcher *dispatcher) :
    Genode::Root_component<Gneiss::Message_Component>(dispatcher->_env->ep(), _factory->alloc()),
    _dispatcher(dispatcher),
    _accepted(nullptr)
{
    TLOG("dispatcher=", dispatcher);
}

Gneiss::Message_Component *Gneiss::Message_Root::_create_session(const char *args)
{
    TLOG("label=", Genode::Cstring(args));
    Genode::Session_label name;
    Genode::Session_label label;
    Gneiss::Message_Dispatcher_Capability cap = {nullptr};
    Genode::size_t ram_quota = Genode::Arg_string::find_arg(args, "ram_quota").ulong_value(0);

    if(ram_quota < Genode::max((Genode::size_t)4096, sizeof(Gneiss::Message_Component))){
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

void Gneiss::Message_Root::_destroy_session(Gneiss::Message_Component *component)
{
    TLOG("component=", component);
    Genode::Session_label dummy;
    Gneiss::Message_Dispatcher_Capability cap = {component};
    _dispatcher->_dispatch(_dispatcher, &cap, dummy.string(), dummy.string());
}
