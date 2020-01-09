
#ifndef _GNEISS_LOG_DISPATCHER_H_
#define _GNEISS_LOG_DISPATCHER_H_

#include <root/component.h>
#include <gneiss.h>
#include <gneiss_log_server.h>

namespace Gneiss
{
    class Log_Dispatcher;
    class Log_Root;
    struct Log_Dispatcher_Capability;
}

class Gneiss::Log_Dispatcher
{
    friend class Gneiss::Log_Root;
    private:
        Gneiss::Log_Root *_root;
        Genode::Env *_env;
        int _index;
        void (Gneiss::Log_Dispatcher::*_dispatch)
                (Gneiss::Log_Dispatcher_Capability *, const char *, const char *);
        Log_Dispatcher(const Log_Dispatcher &);
        Log_Dispatcher &operator = (Log_Dispatcher const &);

    public:
        Log_Dispatcher();
        void initialize(Gneiss::Capability *, int,
                        void(Gneiss::Log_Dispatcher::*)
                                (Gneiss::Log_Dispatcher_Capability *, const char *, const char *));
        void register_service();
};

class Gneiss::Log_Root : public Genode::Root_component<Gneiss::Log_Component>
{
    private:
        Gneiss::Log_Dispatcher *_dispatcher;
        Log_Root(const Log_Root &);
        Log_Root &operator = (Log_Root const &);

    protected:
        Gneiss::Log_Component *_create_session(const char *args) override;

    public:
        Log_Root(Gneiss::Log_Dispatcher *);
};

struct Gneiss::Log_Dispatcher_Capability
{
};

#endif /* ifndef _GNEISS_LOG_DISPATCHER_H_ */
