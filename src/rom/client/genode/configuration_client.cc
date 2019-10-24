
#include <base/attached_rom_dataspace.h>
#include <util/reconstructible.h>
#include <util/xml_node.h>
#include <configuration_client.h>
#include <factory.h>
#include <cai_capability.h>

//#define ENABLE_TRACE
#include <trace.h>

class Config
{
    private:
        Cai::Env *_env;
        Genode::Attached_rom_dataspace _ds;
        Genode::Signal_handler<Config> _sigh;

        void (*_parse)(void const *, Genode::uint64_t);
        static char const _empty;

        Config(Config const &);
        Config & operator = (Config const &);

    public:
        Config(Cai::Env *, void (*)(void const *, Genode::uint64_t), const char *);
        void update();
};

char const Config::_empty = '\0';

Config::Config(Cai::Env *env, void (*parse)(void const *, Genode::uint64_t), const char *label) :
    _env(env),
    _ds(*env->env, label),
    _sigh(env->env->ep(), *this, &Config::update),
    _parse(parse)
{
    TLOG("env=", env, " parse=", parse, " label=", label);
    _ds.sigh(_sigh);
    _ds.update();
}

void Config::update()
{
    TLOG();
    _ds.update();
    try{
        Genode::Xml_node raw = _ds.xml().sub_node();
        _parse(static_cast<void const *>(raw.content_base()), raw.content_size());
    }catch(...){
        _parse(static_cast<void const *>(&_empty), 0);
    }
}

Cai::Configuration::Client::Client() :
    _config(nullptr)
{
    TLOG();
}

void Cai::Configuration::Client::initialize(void *env, void *parse, const char *label)
{
    TLOG("env=", env, " parse=", parse, " label=", label);
    check_factory(_factory, *reinterpret_cast<Cai::Env *>(env)->env);
    _config = _factory->create<Config>(reinterpret_cast<Cai::Env *>(env),
                                       reinterpret_cast<void (*)(void const *, Genode::uint64_t)>(parse),
                                       label);
}

bool Cai::Configuration::Client::initialized()
{
    TLOG();
    return _config;
}

void Cai::Configuration::Client::load()
{
    TLOG();
    reinterpret_cast<Config *>(_config)->update();
}

void Cai::Configuration::Client::finalize()
{
    TLOG();
    _factory->destroy<Config>(_config);
    _config = nullptr;
}
