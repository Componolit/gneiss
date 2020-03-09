
#include <gneiss_message_client.h>
#include <factory.h>

//#define ENABLE_TRACE
#include <trace.h>

Gneiss::Message_Client::Message_Client() :
    _connection(nullptr),
    _index(0),
    _event(nullptr)
{ }

void Gneiss::Message_Client::initialize(Gneiss::Capability *capability, const char *label)
{
    TLOG("capability=", capability, " label=", Genode::Cstring(label));
    check_factory(_factory, *(capability->env));
    _connection = _factory->create2<Gneiss::Message_Connection>(*(capability->env), label, *this);
}

void Gneiss::Message_Client::finalize()
{
    TLOG("");
    _factory->destroy<Gneiss::Message_Connection>(_connection);
}

void Gneiss::Message_Client::write(Gneiss::Message_Session::Message_Buffer const *buf)
{
    TLOG("buf=", buf);
    _connection->write(*buf);
}

void Gneiss::Message_Client::read(Gneiss::Message_Session::Message_Buffer *buf)
{
    TLOG("buf=", buf);
    *buf = _connection->read();
}

int Gneiss::Message_Client::avail()
{
    TLOG("");
    return (int)(_connection->avail());
}

Gneiss::Message_Connection::Message_Connection(Genode::Env &env, Genode::Session_label label, Gneiss::Message_Client &client) :
    Genode::Connection<Gneiss::Message_Session>(env, session(env.parent(),
                                                     "ram_quota=%ld, cap_quota=%ld, label=\"%s\"",
                                                     RAM_QUOTA, CAP_QUOTA, label.string())),
    Gneiss::Message_Session_Client(cap()),
    _event_sigh(env.ep(), *this, &Gneiss::Message_Connection::event),
    _client(&client)
{
    TLOG("label=", label, " client=", client);
    sigh(_event_sigh);
}

Gneiss::Message_Connection::Message_Connection(Genode::Env &env, Genode::Session_label label) :
    Genode::Connection<Gneiss::Message_Session>(env, session(env.parent(),
                                                     "ram_quota=%ld, cap_quota=%ld, label=\"%s\"",
                                                     RAM_QUOTA, CAP_QUOTA, label.string())),
    Gneiss::Message_Session_Client(cap()),
    _event_sigh(env.ep(), *this, &Gneiss::Message_Connection::dummy_event),
    _client(nullptr)
{ }

void Gneiss::Message_Connection::event()
{
    TLOG("");
    _client->_event();
}

void Gneiss::Message_Connection::dummy_event()
{ }
