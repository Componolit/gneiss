
#ifndef _GNEISS_LOG_CLIENT_H_
#define _GNEISS_LOG_CLIENT_H_

#include <log_session/connection.h>
#include <gneiss.h>

namespace Gneiss
{
    class Log_Client;
}

class Gneiss::Log_Client
{
    private:
        Genode::Log_connection *_session;
        char _buffer[4096];
        int _cursor;

        Log_Client(Log_Client const &);
        Log_Client & operator = (Log_Client const &);

    public:
        Log_Client();
        void initialize(Gneiss::Capability *, const char *);
        void write(const char *);
        void finalize();
};

#endif /* ifndef _GNEISS_LOG_CLIENT_H_ */
