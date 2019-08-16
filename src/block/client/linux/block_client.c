
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

void block_client_allocate_request(block_client_t *client, request_t *request, int *retry)
{
    int aio_opcode;
    struct aiocb *aiocb;
    void *buffer;
    request->status = CAI_BLOCK_RAW;
    *retry = 0;
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
        *retry = 2;
        return;
    }
    memset(aiocb, 0, sizeof(struct aiocb));
    memset(buffer, 0, request->length * client->block_size);
    aiocb->aio_fildes = client->fd;
    aiocb->aio_offset = request->start * client->block_size;
    aiocb->aio_nbytes = request->length * client->block_size;
    aiocb->aio_lio_opcode = aio_opcode;
    aiocb->aio_sigevent.sigev_notify = SIGEV_SIGNAL;
    aiocb->aio_sigevent.sigev_signo = SIGIO;
    aiocb->aio_sigevent.sigev_value.sival_ptr = (void *)client;
    aiocb->aio_buf = buffer;
    request->aio_cb = aiocb;
    request->status = CAI_BLOCK_ALLOCATED;
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
                }else if(S_ISBLK(st.st_mode)){
                    size_t bytes;
                    size_t max_blocks;
                    int ro;
                    // these are some ioctls from /usr/include/linux/fs.h
                    // this code most probably only works on linux
                    ioctl((*client)->fd, _IO(0x12,104), &((*client)->block_size)); // block device sector size
                    ioctl((*client)->fd, _IOR(0x12,114,size_t), &bytes); // number of bytes
                    // writability needs to be checked on the block device itself as device files are always rw
                    ioctl((*client)->fd, _IO(0x12,94), &ro); // read only
                    (*client)->block_count = bytes / (*client)->block_size;
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
        if(*client){
            block_client_finalize(client);
        }
    }
}

void block_client_finalize(block_client_t **client)
{
    aio_cancel((*client)->fd, 0);
    close((*client)->fd);
    free(*client);
    *client = 0;
}

void block_client_enqueue(block_client_t *client, request_t *request)
{
    int status;
    switch(request->kind){
        case CAI_BLOCK_WRITE:
            client->rw(client, block_client_block_size (client), request, (void *)(request->aio_cb->aio_buf));
            status = aio_write(request->aio_cb);
            break;
        case CAI_BLOCK_READ:
            status = aio_read(request->aio_cb);
            break;
        default:
            status = 1;
    }
    if(status == 0){
        request->status = CAI_BLOCK_PENDING;
    }else{
        if(status < 0){
            perror("aio_read|aio_write failed");
        }
    }
}

void block_client_submit(block_client_t *client)
{ }

void block_client_read(block_client_t *client, const request_t *request)
{
    client->rw(client, block_client_block_size (client), request, (void *)(request->aio_cb->aio_buf));
}

void block_client_release(block_client_t *client, request_t *request)
{
    if(request->aio_cb){
        aio_cancel(client->fd, request->aio_cb);
        free((void *)(request->aio_cb->aio_buf));
    }
    free(request->aio_cb);
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
