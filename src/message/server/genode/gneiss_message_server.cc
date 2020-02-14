
#include <gneiss_message_server.h>
#include <factory.h>

//#define ENABLE_TRACE
#include <trace.h>

Gneiss::Message_Server::Message_Server() :
    _component(nullptr),
    _index(0),
    _cache()
{ }

void Gneiss::Message_Server::initialize(Genode::Env &env,
                                        int (*avail)(Gneiss::Message_Server *),
                                        void (*recv)(Gneiss::Message_Server *, const Gneiss::Message_Session::Message_Buffer *),
                                        void (*get)(Gneiss::Message_Server *, Gneiss::Message_Session::Message_Buffer *))
{
    TLOG("avail=", avail, " recv=", recv, " get=", get);
    check_factory(_factory, env);
    _component = _factory->create2<Gneiss::Message_Component>(this, avail, recv, get);
}

void Gneiss::Message_Server::send_signal()
{
    TLOG("");
    _component->signal();
}

Gneiss::Message_Component *Gneiss::Message_Server::component()
{
    TLOG("");
    return _component;
}

void Gneiss::Message_Server::finalize()
{
    TLOG("");
    _factory->destroy<Gneiss::Message_Component>(_component);
}

Gneiss::Message_Component::Message_Component (Gneiss::Message_Server *server,
                                              int (*avail)(Gneiss::Message_Server *),
                                              void (*recv)(Gneiss::Message_Server *, const Gneiss::Message_Session::Message_Buffer *),
                                              void (*get)(Gneiss::Message_Server *, Gneiss::Message_Session::Message_Buffer *)) :
    _server(server),
    _signal(),
    _buffer(),
    _avail(avail),
    _receive(recv),
    _get(get)
{
    TLOG("server=", server, " avail=", avail, " recv=", recv, " get=", get);
}

void Gneiss::Message_Component::sigh(Genode::Signal_context_capability sig)
{
    TLOG("sig=", sig);
    _signal = sig;
}

void Gneiss::Message_Component::write(Gneiss::Message_Session::Message_Buffer const &buf)
{
    TLOG("");
    _receive(_server, &buf);
}

Gneiss::Message_Session::Message_Buffer Gneiss::Message_Component::read()
{
    TLOG("");
    _get(_server, &_buffer);
    return _buffer;
}

bool Gneiss::Message_Component::avail()
{
    TLOG("");
    return !!_avail(_server);
}

void Gneiss::Message_Component::signal()
{
    TLOG("");
    if(_signal.valid()){
        Genode::Signal_transmitter(_signal).submit();
    }
}
