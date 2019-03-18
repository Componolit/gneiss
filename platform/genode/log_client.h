
#ifndef _CAI_LOG_CLIENT_H_
#define _CAI_LOG_CLIENT_H_

#include <base/fixed_stdint.h>

namespace Log{
    class Client
    {
        private:
            void *_session;

        public:
            Client();
            bool initialized();
            void initialize(const char *label, Genode::uint64_t size);
            void finalize();
            void write(const char *message);
            Genode::uint64_t maximal_message_length();
    };
}

#endif
