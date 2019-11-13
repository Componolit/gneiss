
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
            void initialize(void *env, const char *label);
            void finalize();
            void write(const char *message);
            Genode::uint64_t maximum_message_length();
    };
}

#endif
