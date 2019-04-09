
#ifndef _BLOCK_CLIENT_H_
#define _BLOCK_CLIENT_H_

#include <stdint.h>
#include <block.h>

/*
 * state struct, passed to each function
 */
typedef struct block_client
{
    /*
     * application event function
     */
    void (*event)(void);
} block_client_t;

/*
 * return instance id
 */
const block_client_t *block_client_get_instance(const block_client_t *client);

/*
 * initialize block_client_t
 * path is a null terminated string, needs to be copied
 * event is the application handler function
 * buffer size can be anything and is not required to be handled by the platform
 */
void block_client_initialize(block_client_t **client, const char *path, uint64_t buffer_size, void (*event)(void));

/*
 * finalize block_client_t
 */
void block_client_finalize(block_client_t **client);

/*
 * for all following functions block_client_t * is always valid
 */

/*
 * checks if a request can be queued by the platform (temporary property)
 * returns 1 if true else 0
 */
int block_client_ready(const block_client_t *client, const request_t *request);

/*
 * checks if a request is supported by the platform (persistent property)
 * returns 1 if true else 0
 */
int block_client_supported(const block_client_t *client, const request_t *request);

/*
 * enqueues a read request
 * request.type is always READ
 * request.status is always RAW
 */
void block_client_enqueue_read(block_client_t *client, const request_t *request);

/*
 * enqueues a write request
 * request.type is always WRITE
 * request.status is always RAW
 * buffer must be copied
 */
void block_client_enqueue_write(block_client_t *client, const request_t *request, const void *buffer);

/*
 * enqueues a sync request
 * request.type is always SYNC
 * request.status is always RAW
 */
void block_client_enqueue_sync(block_client_t *client, const request_t *request);

/*
 * enqueues a trim request
 * request.type is always TRIM
 * request.status is always RAW
 */
void block_client_enqueue_trim(block_client_t *client, const request_t *request);

/*
 * submits all currently enqueued requests
 */
void block_client_submit(block_client_t *client);

/*
 * sets request to the currently next request that has been acknowledged
 * does not take this request from the queue
 * request.status needs to be set either OK or ERROR
 * if no request is available all fields of request need to be initialized to zero
 */
void block_client_next(const block_client_t *client, request_t *request);

/*
 * reads the data associated with a successfully acknowledged request
 * request.type is always READ
 * request.status is always OK
 * data has the size of request.length * block_size
 */
void block_client_read(block_client_t *client, const request_t *request, void *data);

/*
 * releases this request
 * the request is taken from the queue in next and all memory that has been allocated
 * for this request needs to be freed here
 */
void block_client_release(block_client_t *client, const request_t *request);

/*
 * returns 1 if the block device is writable else 0
 */
int block_client_writable(const block_client_t *client);

/*
 * returns the block devices block count
 */
uint64_t block_client_block_count(const block_client_t *client);

/*
 * returns the block devices block size in bytes
 */
uint64_t block_client_block_size(const block_client_t *client);

/*
 * returns the number of bytes a single request can have at maximum
 */
uint64_t block_client_maximal_transfer_size(const block_client_t *client);

#endif /* ifndef _BLOCK_CLIENT_H_ */
