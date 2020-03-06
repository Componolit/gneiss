
#ifndef _GNEISS_MEMORY_CLIENT_H_
#define _GNEISS_MEMORY_CLIENT_H_

#include <base/connection.h>
#include <base/session_label.h>
#include <base/rpc_client.h>
#include <base/capability.h>
#include <base/signal.h>
#include <gneiss.h>
#include <gneiss_memory_session.h>

namespace Gneiss
{
    class Memory_Client;
    struct Memory_Session_Client;
    struct Memory_Connection;
}

class Gneiss::Memory_Client
{
    private:
        Gneiss::Memory_Connection *_session;
        Genode::uint32_t _index;

    public:
        Memory_Client();
        void initialize(Gneiss::Capability *, const char *, long long, void (*)(Gneiss::Memory_Client *));
        void *address();
        long long size();
        void finalize();
};

struct Gneiss::Memory_Session_Client : Genode::Rpc_client<Gneiss::Memory_Session>
{
    explicit Memory_Session_Client(Genode::Capability<Gneiss::Memory_Session> session) :
        Rpc_client<Gneiss::Memory_Session>(session)
    { }

    Genode::Dataspace_capability dataspace() override {
        return call<Rpc_dataspace>();
    }
};

struct Gneiss::Memory_Connection : Genode::Connection<Gneiss::Memory_Session>, Gneiss::Memory_Session_Client
{
    enum { RAM_QUOTA = 8 * 1024UL };

    Genode::Signal_handler<Gneiss::Memory_Connection> _init;
    Gneiss::Memory_Client *_client;
    void (*_event)(Gneiss::Memory_Client *);
    void *_addr;
    Genode::size_t _size;

    Memory_Connection(Genode::Env &, Genode::Session_label,
                      long long, void (*)(Gneiss::Memory_Client *),
                      Gneiss::Memory_Client &);
    Memory_Connection(Genode::Env &, Genode::size_t, Genode::Session_label = "");
    template <typename T>
    T *local_addr(){
        return reinterpret_cast<T *>(_addr);
    }
    Genode::size_t size();

    protected:
        void init();

    private:
        void dummy_init();
        Memory_Connection(const Memory_Connection &);
        Memory_Connection &operator = (Memory_Connection &);
};

#endif /* ifndef _GNEISS_MEMORY_CLIENT_H_ */
