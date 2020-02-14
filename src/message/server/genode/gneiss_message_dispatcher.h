
#ifndef _GNEISS_MESSAGE_DISPATCHER_H_
#define _GNEISS_MESSAGE_DISPATCHER_H_

#include <root/component.h>

#include <gneiss.h>
#include <gneiss_message_session.h>
#include <gneiss_message_server.h>

namespace Gneiss
{
    class Message_Dispatcher;
    class Message_Root;
    struct Message_Dispatcher_Capability;
}

class Gneiss::Message_Dispatcher
{
    friend class Gneiss::Message_Root;
    private:
        Gneiss::Message_Root *_root;
        void (*_dispatch)(Gneiss::Message_Dispatcher *, Gneiss::Message_Dispatcher_Capability *,
                          const char *, const char *);
        Genode::Env *_env;
        Genode::uint32_t _index;

        Message_Dispatcher(const Message_Dispatcher &);
        Message_Dispatcher &operator = (Message_Dispatcher const &);
    public:
        Message_Dispatcher();
        void initialize(Gneiss::Capability *);
        void session_initialize(Gneiss::Message_Server *,
                                int (*)(Gneiss::Message_Server *),
                                void (*)(Gneiss::Message_Server *, const Gneiss::Message_Session::Message_Buffer *),
                                void (*)(Gneiss::Message_Server *, Gneiss::Message_Session::Message_Buffer *));
        void register_service();
        void accept(Gneiss::Message_Server *);
};

class Gneiss::Message_Root : public Genode::Root_component<Gneiss::Message_Component>
{
    friend class Gneiss::Message_Dispatcher;
    private:
        Gneiss::Message_Dispatcher *_dispatcher;
        Gneiss::Message_Component *_accepted;

        Message_Root(const Message_Root &);
        Message_Root &operator = (Message_Root const &);

    protected:
        Gneiss::Message_Component *_create_session(const char *) override;
        void _destroy_session(Gneiss::Message_Component *) override;

    public:
        Message_Root(Gneiss::Message_Dispatcher *);
};

struct Gneiss::Message_Dispatcher_Capability
{
    Gneiss::Message_Component *session;
};

#endif /* ifndef _GNEISS_MESSAGE_DISPATCHER_H_ */
