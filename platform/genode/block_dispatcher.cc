

#include <session/session.h>
#include <block_session/block_session.h>
#include <base/attached_ram_dataspace.h>
#include <util/string.h>
#include <util/reconstructible.h>

#include <factory.h>
#include <block_root.h>
namespace Cai{
    namespace Block{
        struct Root;
    }
}

static Genode::Constructible<Factory> _factory {};

struct Cai::Block::Root : Genode::Rpc_object<Genode::Typed_root<::Block::Session>>
{
    Genode::Env &_env;
    void (*_dispatch)();

    char *_label;
    Genode::Capability<Genode::Session> *_close_cap;
    Genode::size_t _ds_size;
    Cai::Block::Block_root *_block_root;

    Root(Genode::Env &, void (*dispatch)());
    Genode::Capability<Genode::Session> session(Cai::Block::Root::Session_args const &args, Genode::Affinity const &) override;
    void upgrade(Genode::Capability<Genode::Session>, Cai::Block::Root::Upgrade_args const &) override;
    void close(Genode::Capability<Genode::Session>) override;

    private:
        Root(const Root&);
        Root &operator = (Root const &);
};

Cai::Block::Root::Root(Genode::Env &env, void (*dispatch)()) :
    _env(env),
    _dispatch(dispatch),
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
    _dispatch();
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
    _dispatch();
    _close_cap = nullptr;
}

extern "C" {

    void cai_block_dispatcher_initialize(Cai::Block::Root **session, Genode::Env *env, void (*callback)())
    {
        check_factory(_factory, *env);
        *session = _factory->create<Cai::Block::Root>(*env, callback);
    }

    void cai_block_dispatcher_finalize(Cai::Block::Root **session)
    {
        _factory->destroy<Cai::Block::Root>(*session);
        *session = nullptr;
    }

    void cai_block_dispatcher_announce(Cai::Block::Root *session)
    {
        session->_env.parent().announce(session->_env.ep().manage(*session));
    }

    char *cai_block_dispatcher_label_content(Cai::Block::Root *session)
    {
        return session->_label;
    }

    Genode::uint64_t cai_block_dispatcher_label_length(Cai::Block::Root *session)
    {
        return static_cast<Genode::uint64_t>(Genode::strlen(session->_label));
    }

    Genode::uint64_t cai_block_dispatcher_session_size(Cai::Block::Root *session)
    {
        return static_cast<Genode::uint64_t>(session->_ds_size);
    }

    void cai_block_dispatcher_session_accept(Cai::Block::Root *session, Cai::Block::Block_root *server)
    {
        session->_block_root = server;
    }

    bool cai_block_dispatcher_session_cleanup(Cai::Block::Root *session, Cai::Block::Block_root *server)
    {
        Genode::Capability<Genode::Session> *close_cap = session->_close_cap;
        Genode::Capability<Genode::Session> cap = server->cap();
        if(close_cap){
            return cap == *close_cap;
        }else{
            return false;
        }
    }

    Genode::Env *cai_block_dispatcher_get_capability(Cai::Block::Root *session)
    {
        return &(session->_env);
    }

}
