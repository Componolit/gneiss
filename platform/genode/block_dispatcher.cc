

#include <session/session.h>
#include <block_session/block_session.h>
#include <base/attached_ram_dataspace.h>
#include <util/reconstructible.h>
#include <util/string.h>

#include <factory.h>
#include <block_root.h>
namespace Cai{
#include <block_dispatcher.h>
#include <block_server.h>
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

    char *_label;
    Genode::Capability<Genode::Session> *_close_cap;
    Genode::size_t _ds_size;
    Cai::Block::Block_root *_block_root;

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
    _dispatcher(dispatcher),
    _label(nullptr),
    _close_cap(nullptr),
    _ds_size(0),
    _block_root(nullptr)
{ }

Genode::Capability<Genode::Session> Cai::Block::Root::session(Cai::Block::Root::Session_args const &args, Genode::Affinity const &)
{
    Genode::size_t const ds_size = Genode::Arg_string::find_arg(args.string(), "tx_buf_size").ulong_value(0);
    Genode::Ram_quota const ram_quota = Genode::ram_quota_from_args(args.string());
    const Genode::Session::Label label = Genode::session_label_from_args(args.string()).last_element();

    if(ds_size >= ram_quota.value){
        Genode::warning("communication buffer size exceeds session quota");
        throw Genode::Insufficient_ram_quota();
    }

    _ds_size = ds_size;
    _label = const_cast<char *>(label.string());
    _block_root = nullptr;
    _dispatcher->dispatch();
    _label = nullptr;
    _ds_size = 0;

    if(_block_root){
        return _block_root->cap();
    }else{
        Genode::warning("Failed to create block session");
        throw Genode::Service_denied();
    }
}

void Cai::Block::Root::upgrade(Genode::Capability<Genode::Session>, Cai::Block::Root::Upgrade_args const &)
{ }

void Cai::Block::Root::close(Genode::Capability<Genode::Session> close_cap)
{
    _close_cap = &close_cap;
    _dispatcher->dispatch();
    _close_cap = nullptr;
}

Cai::Block::Dispatcher::Dispatcher() :
    _root(nullptr),
    _handler(nullptr)
{ }

void *Cai::Block::Dispatcher::get_instance()
{
    return reinterpret_cast<void *>(this);
}

void Cai::Block::Dispatcher::initialize(
        void *callback)
{
    if(component_env){
        _handler = callback;
        if(!_factory.constructed()){
            _factory.construct(*component_env);
        }
        _root = _factory->create<Cai::Block::Root>(*component_env, this);
    }else{
        Genode::error("Failed to construct block root");
    }
}

void Cai::Block::Dispatcher::finalize()
{
    if(_factory.constructed()){
        _factory->destroy<Cai::Block::Root>(_root);
    }
    _root = nullptr;
    _handler = nullptr;
}

void Cai::Block::Dispatcher::announce()
{
    if(component_env){
        component_env->parent().announce(component_env->ep().manage(*reinterpret_cast<Cai::Block::Root *>(_root)));
    }
}

char *Cai::Block::Dispatcher::label_content()
{
    return reinterpret_cast<Cai::Block::Root *>(_root)->_label;
}

Genode::uint64_t Cai::Block::Dispatcher::label_length()
{
    return static_cast<Genode::uint64_t>(Genode::strlen(reinterpret_cast<Cai::Block::Root *>(_root)->_label));
}

Genode::uint64_t Cai::Block::Dispatcher::session_size()
{
    return static_cast<Genode::uint64_t>(reinterpret_cast<Cai::Block::Root *>(_root)->_ds_size);
}

void Cai::Block::Dispatcher::session_accept(void *session)
{
    reinterpret_cast<Cai::Block::Root *>(_root)->_block_root =
        reinterpret_cast<Cai::Block::Block_root *>(reinterpret_cast<Cai::Block::Server *>(session)->_session);
}

bool Cai::Block::Dispatcher::session_cleanup(void *session)
{
    Genode::Capability<Genode::Session> *close_cap = reinterpret_cast<Cai::Block::Root *>(_root)->_close_cap;
    Genode::Capability<Genode::Session> cap =
        reinterpret_cast<Cai::Block::Block_root *>(reinterpret_cast<Cai::Block::Server *>(session)->_session)->cap();
    if(close_cap){
        return cap == *close_cap;
    }else{
        return false;
    }
}
