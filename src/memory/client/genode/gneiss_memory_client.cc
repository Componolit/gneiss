
#include <base/attached_rom_dataspace.h>
#include <factory.h>
#include <gneiss.h>

//#define ENABLE_TRACE
#include <trace.h>

namespace Gneiss
{
    class Memory_Client;
    class Rom_Session;
}

class Gneiss::Memory_Client
{
    private:
        Genode::uint32_t _index;
        Genode::uint8_t _writable;
        Gneiss::Rom_Session *_rom;
        void (*_event)(void);
        void (*_modify)(Memory_Client *, void *, int);

        Memory_Client(Memory_Client const &);
        Memory_Client & operator = (Memory_Client const &);

    public:
        Memory_Client();
        void initialize(Gneiss::Capability *, const char *);
        void event();
        void update();
        void finalize();
};

class Gneiss::Rom_Session
{
    friend class Gneiss::Memory_Client;
    private:
        Genode::Attached_rom_dataspace _ds;
        Genode::Signal_handler<Gneiss::Memory_Client> _sigh;
        Gneiss::Memory_Client *_mc;

        Rom_Session(Rom_Session const &);
        Rom_Session & operator = (Rom_Session const &);

    public:
        Rom_Session(Genode::Env &, Gneiss::Memory_Client *, const char *);
};

Gneiss::Memory_Client::Memory_Client() :
    _index(0),
    _writable(0),
    _rom(nullptr),
    _event(nullptr),
    _modify(nullptr)
{ }

void Gneiss::Memory_Client::initialize(Gneiss::Capability *cap, const char *label)
{
    TLOG("cap=", cap, " label=", label);
    TLOG("label: ", Genode::Cstring(label));
    check_factory(_factory, *(cap->env));
    if(label[0] == '\0'){
        _rom = _factory->create2<Gneiss::Rom_Session>(*(cap->env), this, "config");
    }else{
        _rom = _factory->create2<Gneiss::Rom_Session>(*(cap->env), this, label);
    }
    if(_rom){
        Genode::Signal_transmitter(_rom->_sigh).submit();
    }
}

void Gneiss::Memory_Client::event()
{
    TLOG("");
    _event();
}

void Gneiss::Memory_Client::update()
{
    TLOG("");
    _rom->_ds.update();
    _modify(this, _rom->_ds.local_addr<void>(), _rom->_ds.size());
}

void Gneiss::Memory_Client::finalize()
{
    TLOG("");
    if(_rom){
        _factory->destroy<Gneiss::Rom_Session>(_rom);
    }
}

Gneiss::Rom_Session::Rom_Session(Genode::Env &env, Gneiss::Memory_Client *mc, const char *label) :
    _ds(env, label),
    _sigh(env.ep(), *mc, &Gneiss::Memory_Client::event),
    _mc(mc)
{ }
