
#ifndef _GNEISS_MESSAGE_CLIENT_H_
#define _GNEISS_MESSAGE_CLIENT_H_

#include <base/connection.h>
#include <base/session_label.h>
#include <base/rpc_client.h>
#include <base/signal.h>

#include <gneiss.h>
#include <gneiss_message_session.h>

namespace Gneiss
{
    class Message_Client;
    struct Message_Session_Client;
    struct Message_Connection;
}

class Gneiss::Message_Client
{
    friend class Gneiss::Message_Connection;
    private:
        Gneiss::Message_Connection *_connection;
        Genode::uint32_t _index;
        void (*_event)();
        void (*_init)(Gneiss::Message_Client *);

    public:
        Message_Client();
        void initialize(Gneiss::Capability *, const char *);
        void finalize();
        void write(Gneiss::Message_Session::Message_Buffer const *);
        void read(Gneiss::Message_Session::Message_Buffer *);
        int avail();
};

struct Gneiss::Message_Session_Client : Genode::Rpc_client<Gneiss::Message_Session>
{
    explicit Message_Session_Client(Genode::Capability<Gneiss::Message_Session> session) :
        Rpc_client<Gneiss::Message_Session>(session)
    { }

    void sigh(Genode::Signal_context_capability cap) override
    {
        call<Rpc_sigh>(cap);
    }

    void write(Gneiss::Message_Session::Message_Buffer const &buf) override
    {
        call<Rpc_write>(buf);
    }

    Gneiss::Message_Session::Message_Buffer read() override
    {
        return call<Rpc_read>();
    }

    bool avail() override
    {
        return call<Rpc_avail>();
    }
};

struct Gneiss::Message_Connection : Genode::Connection<Gneiss::Message_Session>, Gneiss::Message_Session_Client
{
    enum { RAM_QUOTA = 8192 };

    Genode::Signal_handler<Gneiss::Message_Connection> _init_sigh;
    Genode::Signal_handler<Gneiss::Message_Connection> _event_sigh;
    Gneiss::Message_Client *_client;

    Message_Connection(Genode::Env &, Genode::Session_label, Gneiss::Message_Client *);
    void init();
    void event();

    private:
        Message_Connection(const Message_Connection &);
        Message_Connection &operator = (Message_Connection &);
};

#endif /* ifndef _GNEISS_MESSAGE_CLIENT_H_ */
