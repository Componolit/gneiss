
#include <stdio.h>
#include <stdlib.h>
#include <block_client.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/ioctl.h>

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
            (*client)->event = event;
            (*client)->rw = rw;
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
{ }

int block_client_supported(const block_client_t *client, uint32_t kind)
{ }

void block_client_enqueue(block_client_t *client, const request_t *request)
{ }

void block_client_submit(block_client_t *client)
{ }

void block_client_next(const block_client_t *client, request_t *request)
{ }

void block_client_read(block_client_t *client, const request_t *request)
{ }

void block_client_release(block_client_t *client, const request_t *request)
{ }

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
