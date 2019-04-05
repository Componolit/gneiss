
#include <util/string.h>
#include <log_session/connection.h>

#include <factory.h>

extern Genode::Env *__genode_env;
static Factory _factory {*__genode_env};


struct Log_session
{
    enum {WRITE_BUFFER = Genode::Log_session::MAX_STRING_LEN - 1};
    Genode::Log_connection _log;
    char _buffer[WRITE_BUFFER + 1];

    Log_session(Genode::Env &env, const char *label) :
        _log(env, label)
    {
        Genode::memset(_buffer, 0, sizeof(_buffer));
    }
};

extern "C" {

    void cai_log_client_initialize(void **session, const char *label, Genode::uint64_t)
    {
        *session = _factory.create<Log_session>(
                *__genode_env,
                label);
    }

    void cai_log_client_finalize(void **session)
    {
        _factory.destroy<Log_session>(*session);
        *session = nullptr;
    }

    static Log_session *log(void *session)
    {
        return static_cast<Log_session *>(session);
    }

    void cai_log_client_flush(void *session)
    {
        log(session)->_log.write(log(session)->_buffer);
        Genode::memset(log(session)->_buffer, 0, sizeof(Log_session::_buffer));
    }

    void cai_log_client_write(void *session, const char *message)
    {
        if(Genode::strlen(log(session)->_buffer) < Log_session::WRITE_BUFFER){
            Genode::memcpy(&(log(session)->_buffer[Genode::strlen(log(session)->_buffer)]),
                    message,
                    Genode::min(Genode::strlen(message),
                        Log_session::WRITE_BUFFER - Genode::strlen(log(session)->_buffer)));
        }else{
            cai_log_client_flush(session);
            if(Genode::strlen(message) < Log_session::WRITE_BUFFER){
                cai_log_client_write(session, message);
            }
        }
    }

    Genode::uint64_t cai_log_client_maximal_message_length(void *)
    {
        static_assert(Genode::Log_session::MAX_STRING_LEN - 16 > 79);
        return Genode::Log_session::MAX_STRING_LEN - 16;
    }

}
