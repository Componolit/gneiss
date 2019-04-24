
#ifndef _BLOCK_CLIENT_H_
#define _BLOCK_CLIENT_H_

#include <stdint.h>
#include <block.h>
#include <aio.h>

typedef struct block_client block_client_t;

#define EMPTY 0
#define RW 1
#define FSYNC 2
#define FAILED 3

struct ctrl
{
    //the first member MUST ALWAYS be struct aiocb
    struct aiocb aio_cb;
    uint8_t status;
};

typedef struct ring
{
    struct ctrl **buffer;
    size_t size;
    unsigned enqueue;
    unsigned dequeue;
    unsigned submit;
} ring_t;

struct block_client
{
    void (*event)(void);
    void (*rw)(block_client_t *client,
               uint32_t kind,
               uint64_t block_size,
               uint64_t start,
               uint64_t length,
               void *data);
    int fd;
    int writable;
    uint64_t block_size;
    uint64_t block_count;
    uint64_t maximum_transfer_size;
    ring_t queue;
};

size_t ring_alloc(ring_t *, uint64_t buffer_size);
int ring_avail(ring_t const *);
void ring_enqueue(ring_t *, block_client_t *, request_t const *);
void ring_peek(ring_t const *, block_client_t const *, request_t *);
void ring_dequeue(ring_t *);
unsigned ring_submit_offset(ring_t const *);
unsigned ring_submit_length(ring_t const *);
void ring_submitted(ring_t *, unsigned);

const block_client_t *block_client_get_instance(const block_client_t *client);

void block_client_initialize(block_client_t **client,
                             const char *path,
                             uint64_t buffer_size,
                             void (*event)(void),
                             void (*rw)(block_client_t *, uint32_t, uint64_t, uint64_t, uint64_t, void*));

void block_client_finalize(block_client_t **client);

int block_client_ready(const block_client_t *client, const request_t *request);

int block_client_supported(const block_client_t *client, uint32_t kind);

void block_client_enqueue(block_client_t *client, const request_t *request);

void block_client_submit(block_client_t *client);

void block_client_next(const block_client_t *client, request_t *request);

void block_client_read(block_client_t *client, const request_t *request);

void block_client_release(block_client_t *client, const request_t *request);

int block_client_writable(const block_client_t *client);

uint64_t block_client_block_count(const block_client_t *client);

uint64_t block_client_block_size(const block_client_t *client);

uint64_t block_client_maximum_transfer_size(const block_client_t *client);

#endif /* ifndef _BLOCK_CLIENT_H_ */
