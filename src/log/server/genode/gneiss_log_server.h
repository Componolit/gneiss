
#ifndef _GNEISS_LOG_SERVER_H_
#define _GNEISS_LOG_SERVER_H_

#include <base/component.h>
#include <log_session/log_session.h>
#include <util/noncopyable.h>
#include <util/string.h>
#include <gneiss.h>

namespace Gneiss
{
    class Log_Server;
    class Log_Component;
}

class Gneiss::Log_Server
{
    friend class Log_Component;
    private:
        Gneiss::Log_Component *_component;
        void (*_event)();
        void (Gneiss::Log_Server::*_write)(const char *, int, int *);
        Log_Server(const Log_Server &);
        Log_Server &operator = (Log_Server const &);

    public:
        Log_Server();
        void initialize(Gneiss::Capability *, void (*)(), void(Gneiss::Log_Server::*)(const char *, int, int *));
        Gneiss::Log_Component *component();
};

class Gneiss::Log_Component : public Genode::Rpc_object<Genode::Log_session>
{
    private:
        Gneiss::Log_Server *_server;
        Log_Component(const Log_Component &);
        Log_Component &operator = (Log_Component const &);

    public:
        Log_Component(Gneiss::Log_Server *);
        Genode::size_t write(Genode::Log_session::String const &) override;
};

#endif /* ifndef _GNEISS_LOG_SERVER_H_ */
