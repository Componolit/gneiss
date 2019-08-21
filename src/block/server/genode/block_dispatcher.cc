

#include <session/session.h>
#include <block_session/block_session.h>
#include <base/attached_ram_dataspace.h>
#include <util/string.h>
#include <util/reconstructible.h>

#include <factory.h>
#include <block_root.h>
#include <cai_capability.h>
namespace Cai{
#include <block_dispatcher.h>
#include <block_server.h>
    namespace Block{
        struct Root;
    }
}

struct Dcap
{
    Genode::size_t size;
    char *label;
    Cai::Block::Block_root *root;
    Genode::Capability<Genode::Session> *cap;
};

struct Cai::Block::Root : Genode::Rpc_object<Genode::Typed_root<::Block::Session>>
{
    Cai::Env *_env;
    Cai::Block::Dispatcher *_dispatcher;

    Root(Cai::Env *, Cai::Block::Dispatcher *);
    Genode::Capability<Genode::Session> session(Cai::Block::Root::Session_args const &args, Genode::Affinity const &) override;
    void upgrade(Genode::Capability<Genode::Session>, Cai::Block::Root::Upgrade_args const &) override;
    void close(Genode::Capability<Genode::Session>) override;
    void dispatch(Dcap *);

    private:
        Root(const Root&);
        Root &operator = (Root const &);
};

Cai::Block::Root::Root(Cai::Env *env, Cai::Block::Dispatcher *dispatcher) :
    _env(env),
    _dispatcher(dispatcher)
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

    Dcap dispatch_cap {
        ds_size,
        const_cast<char *>(label.string()),
        nullptr,
        nullptr
    };

    dispatch(&dispatch_cap);

    if(dispatch_cap.root){
        return dispatch_cap.root->cap();
    }else{
        Genode::warning("Failed to create block session");
        throw Genode::Service_denied();
    }
}

void Cai::Block::Root::upgrade(Genode::Capability<Genode::Session>, Cai::Block::Root::Upgrade_args const &)
{ }

void Cai::Block::Root::close(Genode::Capability<Genode::Session> close_cap)
{
    Dcap dispatch_cap {
        0,
        nullptr,
        nullptr,
        &close_cap
    };
    dispatch(&dispatch_cap);
}

void Cai::Block::Root::dispatch(Dcap *cap)
{
    _dispatcher->dispatch(static_cast<void *>(cap));
}

Cai::Block::Dispatcher::Dispatcher() :
    _root(nullptr),
    _handler(nullptr),
    _tag(0)
{ }

void Cai::Block::Dispatcher::initialize(
        void *env,
        void *callback)
{
    _handler = callback;
    check_factory(_factory, *reinterpret_cast<Cai::Env *>(env)->env);
    _root = _factory->create<Cai::Block::Root>(reinterpret_cast<Cai::Env *>(env), this);
}

void Cai::Block::Dispatcher::finalize()
{
    _factory->destroy<Cai::Block::Root>(_root);
    _root = nullptr;
    _handler = nullptr;
}

void Cai::Block::Dispatcher::announce()
{
    Cai::Block::Root *root = reinterpret_cast<Cai::Block::Root *>(_root);
    root->_env->env->parent().announce(root->_env->env->ep().manage(*root));
}

char *Cai::Block::Dispatcher::label_content(void *dcap)
{
    return reinterpret_cast<Dcap *>(dcap)->label;
}

Genode::uint64_t Cai::Block::Dispatcher::label_length(void *dcap)
{
    return static_cast<Genode::uint64_t>(Genode::strlen(reinterpret_cast<Dcap *>(dcap)->label));
}

Genode::uint64_t Cai::Block::Dispatcher::session_size(void *dcap)
{
    return static_cast<Genode::uint64_t>(reinterpret_cast<Dcap *>(dcap)->size);
}

void Cai::Block::Dispatcher::session_accept(void *dcap, void *session)
{
    reinterpret_cast<Dcap *>(dcap)->root =
        reinterpret_cast<Cai::Block::Block_root *>(reinterpret_cast<Cai::Block::Server *>(session)->_session);
}

bool Cai::Block::Dispatcher::session_cleanup(void *dcap, void *session)
{
    Genode::Capability<Genode::Session> *close_cap = reinterpret_cast<Dcap *>(dcap)->cap;
    Genode::Capability<Genode::Session> cap =
        reinterpret_cast<Cai::Block::Block_root *>(reinterpret_cast<Cai::Block::Server *>(session)->_session)->cap();
    if(close_cap){
        return cap == *close_cap;
    }else{
        return false;
    }
}

void *Cai::Block::Dispatcher::get_capability()
{
    return reinterpret_cast<Cai::Block::Root *>(_root)->_env;
}
