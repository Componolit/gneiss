
#ifndef _GNEISS_MEMORY_DISPATCHER_H_
#define _GNEISS_MEMORY_DISPATCHER_H_

#include <root/component.h>

#include <gneiss.h>
#include <gneiss_memory_session.h>
#include <gneiss_memory_server.h>

namespace Gneiss
{
    class Memory_Dispatcher;
    class Memory_Root;
    struct Memory_Dispatcher_Capability;
}

class Gneiss::Memory_Dispatcher
{
    friend class Gneiss::Memory_Root;
    private:
        Gneiss::Memory_Root *_root;
        Genode::Env *_env;
        int _index;
        void (*_dispatch)(Gneiss::Memory_Dispatcher *,
                          Gneiss::Memory_Dispatcher_Capability *,
                          const char *, const char *);
        Memory_Dispatcher(const Memory_Dispatcher &);
        Memory_Dispatcher &operator = (Memory_Dispatcher const &);
    public:
        Memory_Dispatcher();
        void initialize(Gneiss::Capability *, void (*)(Gneiss::Memory_Dispatcher *,
                                                       Gneiss::Memory_Dispatcher_Capability *,
                                                       const char *, const char *));
        void session_initialize(Gneiss::Memory_Dispatcher_Capability *, Gneiss::Memory_Server *,
                                void(*)(Gneiss::Memory_Server *, void *, int));
        void register_service();
        void accept(Gneiss::Memory_Server *);
        void cleanup(Gneiss::Memory_Dispatcher_Capability *, Gneiss::Memory_Server *);
};

class Gneiss::Memory_Root : public Genode::Root_component<Gneiss::Memory_Component>
{
    friend class Gneiss::Memory_Dispatcher;
    private:
        Gneiss::Memory_Dispatcher *_dispatcher;
        Gneiss::Memory_Component *_accepted;

        Memory_Root(const Memory_Root &);
        Memory_Root &operator = (Memory_Root const &);

    protected:
        Gneiss::Memory_Component *_create_session(const char *) override;
        void _destroy_session(Gneiss::Memory_Component *) override;

    public:
        Memory_Root(Gneiss::Memory_Dispatcher *);
};

#endif /* ifndef _GNEISS_MEMORY_DISPATCHER_H_ */
