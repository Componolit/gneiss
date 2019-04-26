
#ifndef _CONFIGURATION_CLIENT_H_
#define _CONFIGURATION_CLIENT_H_

namespace Cai
{
    namespace Configuration
    {
        class Client
        {
            private:
                void *_config;
            public:
                Client();
                void initialize(void *env, void *parse);
                bool initialized();
                void load();
                void finalize();
        };
    }
}

#endif /* ifndef _CONFIGURATION_CLIENT_H_ */
