
#ifndef _CAI_LOG_H_
#define _CAI_LOG_H_

#include <base/log.h>
#include <util/string.h>

namespace Cai
{
    void log(const char *msg)
    {
        Genode::log(Genode::Cstring(msg));
    }

    void err(const char *msg)
    {
        Genode::error(Genode::Cstring(msg));
    }
}

#endif /* ifndef _CAI_LOG_H_ */
