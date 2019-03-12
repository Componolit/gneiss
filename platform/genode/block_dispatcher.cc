

#include <session/session.h>
#include <block_session/block_session.h>
#include <base/attached_ram_dataspace.h>
#include <util/reconstructible.h>
#include <util/string.h>

#include <factory.h>
namespace Cai{
#include <block_dispatcher.h>
    namespace Block{
        struct Root;
    }
}

Genode::Env *component_env __attribute__((weak)) = nullptr;
static Genode::Constructible<Factory> _factory;

struct Cai::Block::Root : Genode::Rpc_object<Genode::Typed_root<::Block::Session>>
{
    Genode::Env &_env;
    Cai::Block::Dispatcher *_dispatcher;
    Root(Genode::Env &, Cai::Block::Dispatcher *);
    Genode::Capability<Genode::Session> session(Cai::Block::Root::Session_args const &args, Genode::Affinity const &) override;
    void upgrade(Genode::Capability<Genode::Session>, Cai::Block::Root::Upgrade_args const &) override;
    void close(Genode::Capability<Genode::Session>) override;

    private:
        Root(const Root&);
        Root &operator = (Root const &);
};

Cai::Block::Root::Root(Genode::Env &env, Cai::Block::Dispatcher *dispatcher) :
    _env(env),
    _dispatcher(dispatcher)
{ }

Genode::Capability<Genode::Session> Cai::Block::Root::session(Cai::Block::Root::Session_args const &args, Genode::Affinity const &)
{
    Genode::size_t const ds_size = Genode::Arg_string::find_arg(args.string(), "tx_buf_size").ulong_value(0);
    Genode::Ram_quota const ram_quota = Genode::ram_quota_from_args(args.string());
    const Genode::Session::Label label = Genode::session_label_from_args(args.string()).last_element();
    void *session = nullptr;

    if(ds_size >= ram_quota.value){
        Genode::warning("communication buffer size exceeds session quota");
        throw Genode::Insufficient_ram_quota();
    }

    _dispatcher->dispatch(label.string(), Genode::strlen(label.string()), &session);

    if(session){
        throw Genode::Exception();
    }else{
        Genode::warning("Failed to create block session");
        return Genode::Capability<Genode::Session>();
    }
}

void Cai::Block::Root::upgrade(Genode::Capability<Genode::Session>, Cai::Block::Root::Upgrade_args const &)
{ }

void Cai::Block::Root::close(Genode::Capability<Genode::Session>)
{ }

Cai::Block::Dispatcher::Dispatcher() :
    _root(nullptr),
    _handler(nullptr),
    _state(nullptr)
{ }

void Cai::Block::Dispatcher::initialize(
        void *callback,
        void *state)
{
    if(component_env){
        if(!_factory.constructed()){
            _factory.construct(*component_env);
        }
        _root = _factory->create<Cai::Block::Root>(*component_env, this);
    }else{
        Genode::error("Failed to construct block root");
    }
    _handler = callback;
    _state = state;
    Genode::log("initialized ", _root, " ", _handler, " ", _state);
}

void Cai::Block::Dispatcher::finalize()
{
    if(_factory.constructed()){
        _factory->destroy<Cai::Block::Root>(_root);
    }
    _root = nullptr;
    _handler = nullptr;
    _state = nullptr;
}

void Cai::Block::Dispatcher::announce()
{
    if(component_env){
        component_env->parent().announce(component_env->ep().manage(*reinterpret_cast<Cai::Block::Root*>(_root)));
    }
}
