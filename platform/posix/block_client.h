
#ifndef _BLOCK_CLIENT_H_
#define _BLOCK_CLIENT_H_

#include <stdint.h>
#include <block.h>

typedef struct block_client block_client_t;

struct block_client
{
    void (*event)(void);
    void (*rw)(block_client_t *client,
               uint32_t kind,
               uint64_t block_size,
               uint64_t start,
               uint64_t length,
               void *data);
};

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

uint64_t block_client_maximal_transfer_size(const block_client_t *client);

#endif /* ifndef _BLOCK_CLIENT_H_ */
