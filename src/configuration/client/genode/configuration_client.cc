
#include <base/attached_rom_dataspace.h>
#include <util/reconstructible.h>
#include <util/xml_node.h>
#include <configuration_client.h>
#include <factory.h>

static Genode::Constructible<Factory> _factory;

Cai::Configuration::Client::Client() :
    _config(nullptr),
    _parse(nullptr)
{ }

void Cai::Configuration::Client::initialize(void *env, void *parse)
{
    check_factory(_factory, *reinterpret_cast<Genode::Env *>(env));
    _config = _factory->create<Genode::Attached_rom_dataspace>(*reinterpret_cast<Genode::Env *>(env), "config");
    _parse = parse;
}

bool Cai::Configuration::Client::initialized()
{
    return _config && _parse;
}

void Cai::Configuration::Client::load()
{
    Genode::Attached_rom_dataspace *ds = reinterpret_cast<Genode::Attached_rom_dataspace *>(_config);
    ds->update();
    Genode::Xml_node raw = ds->xml().sub_node();
    ((void (*)(void const *, Genode::uint64_t))_parse)(static_cast<void const *>(raw.content_base()), raw.content_size());
}

void Cai::Configuration::Client::finalize()
{
    _factory->destroy<Genode::Attached_rom_dataspace>(_config);
    _config = nullptr;
    _parse = nullptr;
}
