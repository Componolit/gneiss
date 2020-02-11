
#include <base/attached_rom_dataspace.h>
#include <factory.h>
#include <gneiss.h>

//#define ENABLE_TRACE
#include <trace.h>

namespace Gneiss
{
    class Rom_Client;
    class Rom_Session;
}

class Gneiss::Rom_Client
{
    private:
        Genode::uint32_t _index;
        Gneiss::Rom_Session *_rom;
        void (*_event)(Gneiss::Rom_Client *);
        void (*_read)(Rom_Client *, void *, int);

        Rom_Client(Rom_Client const &);
        Rom_Client & operator = (Rom_Client const &);

    public:
        Rom_Client();
        void initialize(Gneiss::Capability *, const char *);
        void event();
        void update();
        void finalize();
};

class Gneiss::Rom_Session
{
    friend class Gneiss::Rom_Client;
    private:
        Genode::Attached_rom_dataspace _ds;
        Genode::Signal_handler<Gneiss::Rom_Client> _sigh;
        Gneiss::Rom_Client *_mc;

        Rom_Session(Rom_Session const &);
        Rom_Session & operator = (Rom_Session const &);

    public:
        Rom_Session(Genode::Env &, Gneiss::Rom_Client *, const char *);
};

Gneiss::Rom_Client::Rom_Client() :
    _index(0),
    _rom(nullptr),
    _event(nullptr),
    _read(nullptr)
{ }

void Gneiss::Rom_Client::initialize(Gneiss::Capability *cap, const char *label)
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

void Gneiss::Rom_Client::event()
{
    TLOG("");
    _event(this);
}

void Gneiss::Rom_Client::update()
{
    TLOG("");
    _rom->_ds.update();
    _read(this, _rom->_ds.local_addr<void>(), _rom->_ds.size());
}

void Gneiss::Rom_Client::finalize()
{
    TLOG("");
    if(_rom){
        _factory->destroy<Gneiss::Rom_Session>(_rom);
    }
}

Gneiss::Rom_Session::Rom_Session(Genode::Env &env, Gneiss::Rom_Client *mc, const char *label) :
    _ds(env, label),
    _sigh(env.ep(), *mc, &Gneiss::Rom_Client::event),
    _mc(mc)
{ }
