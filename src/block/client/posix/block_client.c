
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

size_t ring_alloc(ring_t *r, uint64_t buffer_size)
{
    r->size = buffer_size ? buffer_size / (sizeof(struct aiocb) + sizeof(uint8_t)) : _SC_AIO_LISTIO_MAX - 1;
    r->status = malloc(r->size * sizeof(uint8_t));
    r->buffer = malloc(r->size * sizeof(struct aiocb));
    if(r->buffer && r->status){
        memset(r->status, 0, r->size * sizeof(uint8_t));
        memset(r->buffer, 0, r->size * sizeof(struct aiocb));
    }
    r->enqueue = 0;
    r->dequeue = 0;
    r->submit = 0;
    return r->buffer && r->status ? r->size : 0;
}

int ring_avail(ring_t const *r)
{
    return r->status[r->enqueue] == 0;
}

void ring_enqueue(ring_t *r, block_client_t *c, request_t const *req)
{
    memset(&(r->buffer[r->enqueue]), 0, sizeof(struct aiocb));
    r->buffer[r->enqueue].aio_fildes = c->fd;
    r->buffer[r->enqueue].aio_sigevent.sigev_notify = SIGEV_NONE; // TODO: proper signal creation for READ and WRITE
    switch(req->type){
        case READ:
            r->status[r->enqueue] = RW;
            r->buffer[r->enqueue].aio_lio_opcode = LIO_READ;
            r->buffer[r->enqueue].aio_offset = req->start * c->block_size;
            r->buffer[r->enqueue].aio_nbytes = req->length * c->block_size;
            r->buffer[r->enqueue].aio_buf = malloc(req->length * c->block_size);
            if(!(r->buffer[r->enqueue].aio_buf)){
                r->status[r->enqueue] = FAILED;
            }
            break;
        case WRITE:
            r->status[r->enqueue] = RW;
            r->buffer[r->enqueue].aio_lio_opcode = LIO_WRITE;
            r->buffer[r->enqueue].aio_offset = req->start * c->block_size;
            r->buffer[r->enqueue].aio_nbytes = req->length * c->block_size;
            r->buffer[r->enqueue].aio_buf = malloc(req->length * c->block_size);
            if((r->buffer[r->enqueue].aio_buf)){
                c->rw(c, req->type, c->block_size, req->start, req->length, (void *)(r->buffer[r->enqueue].aio_buf));
            }else{
                r->status[r->enqueue] = FAILED;
            }
            break;
        case SYNC:
            r->status[r->enqueue] = FSYNC;
            break;
        default:
            break;
    }
    r->enqueue = (r->enqueue + 1) % r->size;
}

void ring_peek(ring_t const *r, block_client_t const *c, request_t *req)
{
    int aio_status;
    memset(req, 0, sizeof(request_t));
    switch(r->status[r->dequeue]){
        case EMPTY:
            req->type = NONE;
            break;
        case RW:
            aio_status = aio_error(&r->buffer[r->dequeue]);
            req->type = r->buffer[r->dequeue].aio_lio_opcode == LIO_READ ? READ : WRITE;
            req->start = r->buffer[r->dequeue].aio_offset / c->block_size;
            req->length = r->buffer[r->dequeue].aio_nbytes / c->block_size;
            switch(aio_status){
                case 0:
                    req->status = OK;
                    break;
                case EINPROGRESS:
                    req->type = NONE;
                    break;
                case ECANCELED:
                    req->status = ERROR;
                default:
                    fprintf(stderr, "invalid request status: %d\n", aio_status);
            }
            break;
        case FSYNC:
            req->type = NONE;
            break;
        case FAILED:
            req->status = ERROR;
            req->type = r->buffer[r->dequeue].aio_lio_opcode == LIO_READ ? READ : WRITE;
            req->start = r->buffer[r->dequeue].aio_offset / c->block_size;
            req->length = r->buffer[r->dequeue].aio_nbytes / c->block_size;
            break;
    }
}

void ring_dequeue(ring_t *r)
{
    free((void *)(r->buffer[r->dequeue].aio_buf));
    r->buffer[r->dequeue].aio_buf = 0;
    r->status[r->dequeue] = EMPTY;
    r->dequeue = (r->dequeue + 1) % r->size;
}

unsigned ring_submit_length(ring_t const *r)
{
    unsigned avail = 0;
    for(avail; avail < _SC_AIO_LISTIO_MAX
               && r->submit + avail < r->size
               && r->status[r->submit + avail] == RW; avail++);
    return avail;
}
void ring_submitted(ring_t *r, unsigned s)
{
    r->submit = (r->submit + s) % r->size;
}

const block_client_t *block_client_get_instance(const block_client_t *client)
{
    return client;
}

void block_client_initialize(block_client_t **client,
                             const char *path,
                             uint64_t buffer_size,
                             void (*event)(void),
                             void (*rw)(block_client_t *, uint32_t, uint64_t, uint64_t, uint64_t, void*))
{
    struct stat st;
    *client = malloc(sizeof(block_client_t));
    if(*client && ring_alloc(&(*client)->queue, buffer_size)){
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
        }else{
            perror(path);
            block_client_finalize(client);
        }
    }else{
        perror("failed to initialize block client");
        block_client_finalize(client);
    }
}

void block_client_finalize(block_client_t **client)
{
    close((*client)->fd);
    free(*client);
    *client = 0;
}

int block_client_ready(const block_client_t *client, const request_t *request)
{
    return ring_avail(&client->queue);
}

int block_client_supported(const block_client_t *client, uint32_t kind)
{
    return kind == READ
           || kind == WRITE
           || kind == SYNC;
}

void block_client_enqueue(block_client_t *client, const request_t *request)
{
    ring_enqueue(&client->queue, client, request);
}

void block_client_submit(block_client_t *client)
{
    int cont = 1;
    unsigned length;
    struct sigevent sige;
    struct aiocb *start[client->queue.size];
    sige.sigev_notify = SIGEV_NONE; // TODO: proper signal creation for read and write
    while(cont){
        length = ring_submit_length(&client->queue);
        if(length){
            for(unsigned i = 0; i < length; i++){
                start[i] = &client->queue.buffer[client->queue.submit + i];
                // TODO: this data structure should be available in ring_t
            }
            if(lio_listio(LIO_NOWAIT, start, length, &sige) == -1){
                switch(errno){
                    case EAGAIN:
                        cont = 0;
                        // TODO: check if any request is pending in this instance, if not there might be no signal if we stop here
                        break;
                    case EIO:
                        ring_submitted(&client->queue, length);
                        break;
                    default:
                        perror("lio_listio failed");
                        cont = 0;
                }
            }else{
                ring_submitted(&client->queue, length);
            }
        }else if(client->queue.status[client->queue.submit] == FSYNC){
            aio_fsync(O_SYNC, &client->queue.buffer[client->queue.submit]);
            client->queue.submit = (client->queue.submit + 1) % client->queue.size;
            cont = 1;
        }else{
            cont = 0;
        }
    }
}

void block_client_next(const block_client_t *client, request_t *request)
{
    ring_peek(&client->queue, client, request);
}

void block_client_read(block_client_t *client, const request_t *request)
{
    printf("%s\n", __func__);
}

void block_client_release(block_client_t *client, const request_t *request)
{
    ring_dequeue(&client->queue);
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
