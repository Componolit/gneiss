
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
        void (*_dispatch)(Gneiss::Log_Dispatcher *,
                          Gneiss::Log_Dispatcher_Capability *,
                          const char *, const char *);
        Log_Dispatcher(const Log_Dispatcher &);
        Log_Dispatcher &operator = (Log_Dispatcher const &);

    public:
        Log_Dispatcher();
        void initialize(Gneiss::Capability *, void(*)(Gneiss::Log_Dispatcher *,
                                                      Gneiss::Log_Dispatcher_Capability *,
                                                      const char *, const char *));
        void session_initialize(Gneiss::Log_Dispatcher_Capability *, Gneiss::Log_Server *,
                                void (*write)(Gneiss::Log_Server *, const char *, int, int *));
        void register_service();
        void accept(Gneiss::Log_Server *);
        void cleanup(Gneiss::Log_Server *);
};

class Gneiss::Log_Root : public Genode::Root_component<Gneiss::Log_Component>
{
    friend class Gneiss::Log_Dispatcher;
    private:
        Gneiss::Log_Dispatcher *_dispatcher;
        Gneiss::Log_Component *_accepted;

        void accept(Gneiss::Log_Component *);
        Log_Root(const Log_Root &);
        Log_Root &operator = (Log_Root const &);

    protected:
        Gneiss::Log_Component *_create_session(const char *args) override;
        void _destroy_session(Gneiss::Log_Component *session) override;

    public:
        Log_Root(Gneiss::Log_Dispatcher *);
};

struct Gneiss::Log_Dispatcher_Capability
{
    Gneiss::Log_Component *session;
};

#endif /* ifndef _GNEISS_LOG_DISPATCHER_H_ */
