
#ifndef _BLOCK_CLIENT_H_
#define _BLOCK_CLIENT_H_

#include <stdint.h>
#include <aio.h>

#define QUEUE_SIZE 64

#define CAI_BLOCK_NONE 0
#define CAI_BLOCK_READ 1
#define CAI_BLOCK_WRITE 2
#define CAI_BLOCK_SYNC 3
#define CAI_BLOCK_TRIM 4

#define CAI_BLOCK_RAW 0
#define CAI_BLOCK_ALLOCATED 1
#define CAI_BLOCK_PENDING 2
#define CAI_BLOCK_SUBMITTED 3
#define CAI_BLOCK_FINISHED 4
#define CAI_BLOCK_OK 5
#define CAI_BLOCK_ERROR 6

typedef struct block_client block_client_t;
typedef struct request request_t;
typedef struct request_handle request_handle_t;

struct request
{
    uint32_t kind;
    uint32_t tag;
    uint64_t start;
    uint64_t length;
    uint32_t status;
    struct aiocb *aio_cb;
};

struct request_handle
{
    uint32_t tag;
    uint32_t valid;
};

struct block_client
{
    void (*event)(void);
    void (*rw)(block_client_t *client,
               request_t const *request,
               void *data);
    int fd;
    int writable;
    uint64_t block_size;
    uint64_t block_count;
    uint64_t maximum_transfer_size;
    request_t *queue[QUEUE_SIZE];
};

void block_client_allocate_request(block_client_t *client, request_t *request);

void block_client_update_response_queue(block_client_t *client, request_handle_t *handle);

void block_client_update_request(block_client_t *client, request_t *request, request_handle_t *handle);

const block_client_t *block_client_get_instance(const block_client_t *client);

void block_client_initialize(block_client_t **client,
                             const char *path,
                             uint64_t buffer_size,
                             void (*event)(void),
                             void (*rw)(block_client_t *, request_t const *, void*));

void block_client_finalize(block_client_t **client);

void block_client_enqueue(block_client_t *client, request_t *request);

void block_client_submit(block_client_t *client);

void block_client_read(block_client_t *client, const request_t *request);

void block_client_release(block_client_t *client, request_t *request);

int block_client_writable(const block_client_t *client);

uint64_t block_client_block_count(const block_client_t *client);

uint64_t block_client_block_size(const block_client_t *client);

uint64_t block_client_maximum_transfer_size(const block_client_t *client);

#endif /* ifndef _BLOCK_CLIENT_H_ */
