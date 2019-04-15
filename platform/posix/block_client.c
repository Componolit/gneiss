
#include <stdlib.h>
#include <block_client.h>

const block_client_t *block_client_get_instance(const block_client_t *client)
{
    return client;
}

void block_client_initialize(block_client_t **client,
                             const char *path,
                             uint64_t buffer_size,
                             void (*event)(void),
                             void (*write)(block_client_t *, uint64_t, uint64_t, uint64_t, void*))
{
    *client = malloc(sizeof(block_client_t));
    (*client)->event = event;
    (*client)->write = write;
}

void block_client_finalize(block_client_t **client)
{
    free(*client);
    *client = 0;
}

int block_client_ready(const block_client_t *client, const request_t *request)
{ }

int block_client_supported(const block_client_t *client, uint32_t kind)
{ }

void block_client_enqueue(block_client_t *client, const request_t *request)
{ }

void block_client_submit(block_client_t *client)
{ }

void block_client_next(const block_client_t *client, request_t *request)
{ }

void block_client_read(block_client_t *client, const request_t *request, void *data)
{ }

void block_client_release(block_client_t *client, const request_t *request)
{ }

int block_client_writable(const block_client_t *client)
{ }

uint64_t block_client_block_count(const block_client_t *client)
{ }

uint64_t block_client_block_size(const block_client_t *client)
{ }

uint64_t block_client_maximal_transfer_size(const block_client_t *client)
{ }
