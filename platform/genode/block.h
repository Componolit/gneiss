
#ifndef _BLOCK_H_
#define _BLOCK_H_

#include <base/fixed_stdint.h>

namespace Block
{
    enum Kind {NONE, READ, WRITE, SYNC};
    enum Status {RAW, OK, ERROR, ACK};
    struct Request
    {
        Kind kind;
        Genode::uint8_t uid[16];
        Genode::uint64_t start;
        Genode::uint64_t length;
        Status status;
    };
}

#endif
