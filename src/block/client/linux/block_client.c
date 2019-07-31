
#include <stdio.h>
#include <stdlib.h>
#include <block_client.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <string.h>
#include <errno.h>
#include <signal.h>

/*
 * Request memory lifetime:
 *
 * Requests need allocations at three different points:
 *  - aio control block
 *  - request data buffer
 *  - lio request list
 *
 *  The first two are simple memory allocations, if either of them failes all previous allocations are freed.
 *  The last one is a bit more complicated. We use an enqueue->submit scheme here and call lio_listio
 *  with a list of aio control blocks. Since submit cannot fail we need to ensure that the list provided
 *  is constrained in length (not longer than _SC_AIO_LISTIO_MAX. This is a constraint for a single call,
 *  we can call it multiple times in a row with different lists. To prevent use after free errors each list
 *  must exist until all requests are finished (and therefor not used by aio anymore). Also to have an arbitrary
 *  number of lists they live freely in the heap without any statically known reference.
 *
 *  The usage scheme is usually as follows:
 *   - allocate request
 *   - enqueue request into list
 *   - submit list
 *   - update requests to check their state
 *   - free requests
 *
 *   To ensure the constraint of the list length in submit there is a current_queue in the client
 *   that is used for the next submit. If it is null, it will be allocated with the request. The next
 *   request will be accounted on the already allocated queue. When enqueue is called the requests
 *   can be enqueued in any order. Since enqueue also cannot fail there can only be as many allocated requests
 *   as there are slots in a single queue. When submit is called the current_queue is set to null (but not freed!)
 *   so a new queue can be allocated.
 *
 *   Now theres a memory leak with floating pending queues. To prevent this each request knows the queue is has
 *   been assigned onto allocation. Also each queue has a reference counter how many requests are referencing it
 *   which is increased on each allocation.
 *   When a pending request is finished and gets released, it will, aside from freeing its data buffer and
 *   aio control block, remove itself from the queue and decrease the reference counter. If the counter drops to
 *   zero it will also free the queue.
 */

void block_client_allocate_request(block_client_t *client, request_t *request)
{
    int aio_opcode;
    struct aiocb *aiocb;
    void *buffer;
    int queue_slot = -1;
    request->status = CAI_BLOCK_RAW;
    if(client->current_queue){
        if(client->current_queue->refcount >= _SC_AIO_LISTIO_MAX){
            return;
        }
    }else{
        client->current_queue = (queue_t *)malloc(sizeof(queue_t));
        if(client->current_queue){
            memset(client->current_queue, 0, sizeof(queue_t));
        }else{
            return;
        }
    }
    switch(request->kind){
        case 1:
            aio_opcode = LIO_READ;
            break;
        case 2:
            aio_opcode = LIO_WRITE;
            break;
        default:
            return;
    }
    aiocb = (struct aiocb *)malloc(sizeof(struct aiocb));
    buffer = malloc(request->length * client->block_size);
    if(aiocb == 0 || buffer == 0){
        free(aiocb);
        free(buffer);
        return;
    }
    memset(aiocb, 0, sizeof(struct aiocb));
    memset(buffer, 0, request->length * client->block_size);
    aiocb->aio_fildes = client->fd;
    aiocb->aio_offset = request->start * client->block_size;
    aiocb->aio_nbytes = request->length * client->block_size;
    aiocb->aio_lio_opcode = aio_opcode;
    aiocb->aio_buf = buffer;
    request->aio_cb = aiocb;
    request->status = CAI_BLOCK_ALLOCATED;
    request->queue = client->current_queue;
    request->queue->refcount += 1;
}

void block_client_update_request(block_client_t *client, request_t *request)
{
    if(aio_error(request->aio_cb) != EINPROGRESS){
        if(aio_return(request->aio_cb) == request->aio_cb->aio_nbytes){
            request->status = CAI_BLOCK_OK;
        }else{
            request->status = CAI_BLOCK_ERROR;
        }
    }
}

const block_client_t *block_client_get_instance(const block_client_t *client)
{
    return client;
}

void block_client_initialize(block_client_t **client,
                             const char *path,
                             uint64_t buffer_size,
                             void (*event)(void),
                             void (*rw)(block_client_t *, uint64_t, request_t const *, void*))
{
    struct stat st;
    *client = malloc(sizeof(block_client_t));
    if(*client){
        // try to open the file read-write
        // also no support for symlinks to prevent handling special cases
        (*client)->fd = open(path, O_RDWR | O_NOFOLLOW);
        (*client)->writable = 1;
        if((*client)->fd < 0){
            // if read-write fails try to open it read only
            (*client)->fd = open(path, O_RDONLY | O_NOFOLLOW);
            (*client)->writable = 0;
        }
        if((*client)->fd >= 0){
            if(!fstat((*client)->fd, &st)){
                if(S_ISREG(st.st_mode)){
                    (*client)->block_size = st.st_blksize;
                    (*client)->block_count = st.st_size / st.st_blksize;
                    (*client)->maximum_transfer_size = -1;
                }else if(S_ISBLK(st.st_mode)){
                    size_t bytes;
                    size_t max_blocks;
                    int ro;
                    // these are some ioctls from /usr/include/linux/fs.h
                    // this code most probably only works on linux
                    ioctl((*client)->fd, _IO(0x12,104), &((*client)->block_size)); // block device sector size
                    ioctl((*client)->fd, _IOR(0x12,114,size_t), &bytes); // number of bytes
                    ioctl((*client)->fd, _IO(0x12,103), &max_blocks); // max sectors per request
                    // writability needs to be checked on the block device itself as device files are always rw
                    ioctl((*client)->fd, _IO(0x12,94), &ro); // read only
                    (*client)->block_count = bytes / (*client)->block_size;
                    (*client)->maximum_transfer_size = max_blocks * (*client)->block_size;
                    (*client)->writable = !ro;
                }else{
                    fprintf(stderr, "Unsupported file type: 0%o\n", st.st_mode >> 12);
                    block_client_finalize(client);
                }
            }else{
                perror("failed to get device meta data");
                block_client_finalize(client);
            }
            (*client)->event = event;
            (*client)->rw = rw;
            (*client)->current_queue = 0;
        }else{
            perror(path);
            block_client_finalize(client);
        }
    }else{
        perror("failed to initialize block client");
        if(*client){
            block_client_finalize(client);
        }
    }
}

void block_client_finalize(block_client_t **client)
{
    aio_cancel((*client)->fd, 0);
    // we do not free the queues as they should be freed before finalizing
    close((*client)->fd);
    free(*client);
    *client = 0;
}

void block_client_enqueue(block_client_t *client, request_t *request)
{
    request->status = CAI_BLOCK_PENDING;
    for(unsigned i = 0; i < _SC_AIO_LISTIO_MAX; i++){
        if(request->queue->lio_queue[i] == 0){
            request->queue->lio_queue[i] = request->aio_cb;
            if(request->kind == CAI_BLOCK_WRITE){
                client->rw(client, block_client_block_size (client), request, (void *)(request->aio_cb->aio_buf));
            }
            return;
        }
    }
}

void block_client_submit(block_client_t *client)
{
    unsigned length;
    struct sigevent sige;
    if(client->current_queue){
        memset(&sige, 0, sizeof(struct sigevent));
        for(length = 0; length < _SC_AIO_LISTIO_MAX - 1 && client->current_queue->lio_queue[length] != 0; length++);
        if(!length){
            return;
        }
        // since length counts the index of the queue we need to increase it to get the actual length
        length++;
        sige.sigev_notify = SIGEV_SIGNAL;
        sige.sigev_signo = SIGIO;
        sige.sigev_value.sival_ptr = (void *)client;
retry:
        if(lio_listio(LIO_NOWAIT, client->current_queue->lio_queue, length, &sige) == -1){
            switch(errno){
                case EAGAIN:
                    // there is no error handling for submit so we retry until it works
                    goto retry;
                    break;
                case EIO:
                    // EIO means that a request failed so we can handle it as a successful submit
                    client->current_queue = 0;
                    break;
                default:
                    // lio_listio was called wrongly, this should never happen
                    // (and even if it does we can't handle it)
                    perror("lio_listio failed");
                    break;
            }
        }else{
            client->current_queue = 0;
        }
    }
}

void block_client_read(block_client_t *client, const request_t *request)
{
    client->rw(client, block_client_block_size (client), request, (void *)(request->aio_cb->aio_buf));
}

void block_client_release(block_client_t *client, request_t *request)
{
    if(request->aio_cb){
        aio_cancel(client->fd, request->aio_cb);
        free((void *)(request->aio_cb->aio_buf));
        for(long i = 0; i < _SC_AIO_LISTIO_MAX; i++){
            if(request->queue->lio_queue[i] = request->aio_cb){
                request->queue->lio_queue[i] = 0;
                request->queue->refcount -= 1;
                break;
            }
        }
    }
    free(request->aio_cb);
    if(request->queue && request->queue->refcount <= 0){
        // free the queue if we are the last one referencing it
        free(request->queue);
    }
    memset(request, 0, sizeof(request_t));
}

int block_client_writable(const block_client_t *client)
{
    return client->writable;
}

uint64_t block_client_block_count(const block_client_t *client)
{
    return client->block_count;
}

uint64_t block_client_block_size(const block_client_t *client)
{
    return client->block_size;
}

uint64_t block_client_maximum_transfer_size(const block_client_t *client)
{
    if(client->maximum_transfer_size < client->block_size * client->block_count){
        return client->maximum_transfer_size;
    }else{
        return client->block_size * client->block_count;
    }
}
