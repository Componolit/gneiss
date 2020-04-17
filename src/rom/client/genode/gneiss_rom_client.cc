
#include <base/attached_rom_dataspace.h>
#include <factory.h>
#include <gneiss.h>

//#define ENABLE_TRACE
#include <trace.h>

namespace Gneiss
{
    class Rom_Client;
}

class Gneiss::Rom_Client
{
    private:
        Genode::uint32_t _index;
        Genode::Attached_rom_dataspace *_rom;
        void (*_read)(Rom_Client *, void *, int, void *);

        Rom_Client(Rom_Client const &);
        Rom_Client & operator = (Rom_Client const &);

    public:
        Rom_Client();
        void initialize(Gneiss::Capability *, const char *);
        void update(void *);
        void finalize();
};

Gneiss::Rom_Client::Rom_Client() :
    _index(0),
    _rom(nullptr),
    _read(nullptr)
{ }

void Gneiss::Rom_Client::initialize(Gneiss::Capability *cap, const char *label)
{
    TLOG("cap=", cap, " label=", label);
    TLOG("label: ", Genode::Cstring(label));
    check_factory(_factory, *(cap->env));
    if(label[0] == '\0'){
        _rom = _factory->create2<Genode::Attached_rom_dataspace>(*(cap->env), "config");
    }else{
        _rom = _factory->create2<Genode::Attached_rom_dataspace>(*(cap->env), label);
    }
}

void Gneiss::Rom_Client::update(void *ctx)
{
    TLOG("");
    _rom->update();
    _read(this, _rom->local_addr<void>(), _rom->size(), ctx);
}

void Gneiss::Rom_Client::finalize()
{
    TLOG("");
    _factory->destroy<Genode::Attached_rom_dataspace>(_rom);
}
