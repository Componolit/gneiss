
#ifndef _BLOCK_H_
#define _BLOCK_H_

#include <stdint.h>

/* request type */

#define NONE 0
#define READ 1
#define WRITE 2
#define SYNC 3
#define TRIM 4

/* request status */

#define RAW 0
#define ALLOCATED 1
#define PENDING 2
#define OK 3
#define ERROR 4

typedef struct request
{
    uint32_t type;
    uint32_t tag;
    uint64_t start;
    uint64_t length;
    uint32_t status;
} request_t;

typedef struct request_handle
{
    uint32_t tag;
    uint32_t valid;
} request_handle_t;

#endif /* ifndef _BLOCK_H_ */
