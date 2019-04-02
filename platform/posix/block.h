
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
#define OK 1
#define ERROR 2
#define ACKNOWLEDGED 3

typedef struct request
{
    uint32_t type;
    uint8_t priv[16];
    uint64_t start;
    uint64_t length;
    uint32_t status;
} request_t;

#endif /* ifndef _BLOCK_H_ */
