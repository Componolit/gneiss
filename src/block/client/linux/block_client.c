
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

void block_client_allocate_request(block_client_t *client, request_t *request)
{
    printf("%s\n", __func__);
    int aio_opcode;
    struct aiocb *aiocb;
    void *buffer;
    int queue_slot = -1;
    request->status = CAI_BLOCK_RAW;
    for(unsigned i = 0; i < QUEUE_SIZE; i++){
        if(!client->queue[i]){
            queue_slot = i;
            break;
        }
    }
    if(queue_slot < 0){
        return;
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
    aiocb->aio_fildes = client->fd;
    aiocb->aio_offset = request->start * client->block_size;
    aiocb->aio_nbytes = request->length * client->block_size;
    aiocb->aio_lio_opcode = aio_opcode;
    aiocb->aio_buf = buffer;
    request->aio_cb = aiocb;
    request->status = CAI_BLOCK_ALLOCATED;
    client->queue[queue_slot] = request;
}

void block_client_update_response_queue(block_client_t *client, request_handle_t *handle)
{
    printf("%s\n", __func__);
    memset(handle, 0, sizeof(request_handle_t));
    for(unsigned i = 0; i < QUEUE_SIZE; i++){
        if(client->queue[i] && client->queue[i]->status == CAI_BLOCK_SUBMITTED){
            switch(aio_error(client->queue[i]->aio_cb)){
                case EINPROGRESS:
                    break;
                default:
                    client->queue[i]->status = CAI_BLOCK_FINISHED;
                    handle->tag = client->queue[i]->tag;
                    handle->valid = 1;
                    return;
            }
        }
    }
}

void block_client_update_request(block_client_t *client, request_t *request, request_handle_t *handle)
{
    printf("%s\n", __func__);
    if(aio_return(request->aio_cb) == request->aio_cb->aio_nbytes){
        request->status = CAI_BLOCK_OK;
    }else{
        request->status = CAI_BLOCK_ERROR;
    }
}

const block_client_t *block_client_get_instance(const block_client_t *client)
{
    printf("%s\n", __func__);
    return client;
}

void block_client_initialize(block_client_t **client,
                             const char *path,
                             uint64_t buffer_size,
                             void (*event)(void),
                             void (*rw)(block_client_t *, request_t const *, void*))
{
    printf("%s\n", __func__);
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
            memset((*client)->queue, 0, sizeof(request_t *) * QUEUE_SIZE);
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
    printf("%s\n", __func__);
    aio_cancel((*client)->fd, 0);
    close((*client)->fd);
    // we do not free the queues as they should be freed before finalizing
    free(*client);
    *client = 0;
}

void block_client_enqueue(block_client_t *client, request_t *request)
{
    printf("%s\n", __func__);
    request->status = CAI_BLOCK_PENDING;
}

void block_client_submit(block_client_t *client)
{
    printf("%s\n", __func__);
    int cont = 1;
    unsigned length = 0;
    struct sigevent sige;
    struct aiocb *queue[_SC_AIO_LISTIO_MAX];
    memset(queue, 0, sizeof(struct aiocb *) * _SC_AIO_LISTIO_MAX);
    sige.sigev_notify = SIGEV_SIGNAL;
    sige.sigev_signo = SIGIO;
    sige.sigev_value.sival_ptr = (void *)client;
    for(unsigned i = 0; i < QUEUE_SIZE || length;){
        printf("%u: %p\n", i, client->queue[i]);
        if(i < QUEUE_SIZE && (!client->queue[i] || client->queue[i]->status != CAI_BLOCK_PENDING)){
            printf("continue\n");
            i++;
            continue;
        }
        if(i < QUEUE_SIZE && length < _SC_AIO_LISTIO_MAX){
            printf("update queue\n");
            queue[length] = client->queue[i]->aio_cb;
            client->queue[i]->status = CAI_BLOCK_SUBMITTED;
            i++;
            length++;
        }
        if(length == _SC_AIO_LISTIO_MAX || i == QUEUE_SIZE){
            printf("send queue\n");
            if(lio_listio(LIO_NOWAIT, queue, length, &sige) == -1){
                switch(errno){
                    case EAGAIN:
                        break;
                    case EIO:
                        length = 0;
                        break;
                    default:
                        length = 0;
                        perror("lio_listio failed");
                        break;
                }
            }else{
                length = 0;
            }
        }
    }
    printf("%s\n", __func__);
}

void block_client_read(block_client_t *client, const request_t *request)
{
    printf("%s\n", __func__);
    client->rw(client, request, (void *)(request->aio_cb->aio_buf));
}

void block_client_release(block_client_t *client, request_t *request)
{
    printf("%s\n", __func__);
    aio_cancel(client->fd, request->aio_cb);
    free((void *)(request->aio_cb->aio_buf));
    free(request->aio_cb);
    for(unsigned i; i < QUEUE_SIZE; i++){
        if(client->queue[i] = request){
            client->queue[i] = 0;
            memset(request, 0, sizeof(request_t));
            return;
        }
    }
}

int block_client_writable(const block_client_t *client)
{
    printf("%s\n", __func__);
    return client->writable;
}

uint64_t block_client_block_count(const block_client_t *client)
{
    printf("%s\n", __func__);
    return client->block_count;
}

uint64_t block_client_block_size(const block_client_t *client)
{
    printf("%s\n", __func__);
    return client->block_size;
}

uint64_t block_client_maximum_transfer_size(const block_client_t *client)
{
    printf("%s\n", __func__);
    if(client->maximum_transfer_size < client->block_size * client->block_count){
        return client->maximum_transfer_size;
    }else{
        return client->block_size * client->block_count;
    }
}
