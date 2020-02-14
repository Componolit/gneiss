
#ifndef _GNEISS_MESSAGE_SERVER_H_
#define _GNEISS_MESSAGE_SERVER_H_

#include <base/component.h>
#include <base/signal.h>

#include <gneiss.h>
#include <gneiss_message_session.h>

namespace Gneiss
{
    class Message_Server;
    class Message_Component;
    struct Basalt_Message_Queue;
}

struct Gneiss::Basalt_Message_Queue
{
    long long index;
    long long length;
    Gneiss::Message_Session::Message_Buffer list[10];
};

class Gneiss::Message_Server
{
    private:
        Gneiss::Message_Component *_component;
        Genode::uint32_t _index;
        Gneiss::Basalt_Message_Queue _cache;

        Message_Server(const Message_Server &);
        Message_Server &operator = (Message_Server const &);

    public:
        Message_Server();
        void initialize(Genode::Env &,
                        int (*)(Gneiss::Message_Server *),
                        void (*)(Gneiss::Message_Server *, const Gneiss::Message_Session::Message_Buffer *),
                        void (*)(Gneiss::Message_Server *, Gneiss::Message_Session::Message_Buffer *));
        void send_signal();
        void finalize();
        Gneiss::Message_Component *component();
};

class Gneiss::Message_Component : public Genode::Rpc_object<Gneiss::Message_Session>
{
    private:
        Gneiss::Message_Server *_server;
        Genode::Signal_context_capability _signal;
        Gneiss::Message_Session::Message_Buffer _buffer;
        int (*_avail)(Gneiss::Message_Server *);
        void (*_receive)(Gneiss::Message_Server *, const Gneiss::Message_Session::Message_Buffer *);
        void (*_get)(Gneiss::Message_Server *, Gneiss::Message_Session::Message_Buffer *);

        Message_Component(const Message_Component &);
        Message_Component &operator = (Message_Component const &);

    public:
        Message_Component(Gneiss::Message_Server *,
                          int (*)(Gneiss::Message_Server *),
                          void (*)(Gneiss::Message_Server *, const Gneiss::Message_Session::Message_Buffer *),
                          void (*)(Gneiss::Message_Server *, Gneiss::Message_Session::Message_Buffer *));
        void sigh(Genode::Signal_context_capability) override;
        void write(Gneiss::Message_Session::Message_Buffer const &) override;
        Gneiss::Message_Session::Message_Buffer read() override;
        bool avail() override;
        void signal();
};

#endif /* ifndef _GNEISS_MESSAGE_SERVER_H_ */
