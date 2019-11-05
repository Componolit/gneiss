
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <unistd.h>
#include <mqueue.h>

#include <resources.h>

#define ENABLE_TRACE
#include <trace.h>

static int allocate_message_queue(resource_t *resource)
{
    struct mq_attr attr;
    const size_t namelen = strlen(resource->type) + strlen(resource->name) + 3;
    char name[namelen];
    int fd;

    memset(name, 0, namelen);
    name[0] = '/';
    strcat(name, resource->type);
    strcat(name, "_");
    strcat(name, resource->name);
    attr.mq_flags = 0;
    attr.mq_maxmsg = 10;
    attr.mq_msgsize = 4096;
    attr.mq_curmsgs = 0;
    mq_unlink(name);
    fd = mq_open(name, O_RDWR | O_CREAT, 0660, &attr);
    if(fd < 0){
        perror("mq_open");
        return 1;
    }
    TRACE("%s %d\n", name, fd);
    close(fd);
    return 0;
}

static int open_message_queue(resource_t *resource, int mode)
{
    int unix_mode;
    const size_t namelen = strlen(resource->type) + strlen(resource->name) + 3;
    char name[namelen];

    memset(name, 0, namelen);
    name[0] = '/';
    strcat(name, resource->type);
    strcat(name, "_");
    strcat(name, resource->name);
    switch(mode){
        case RESOURCE_READ:
            unix_mode = O_RDONLY;
            break;
        case RESOURCE_WRITE:
            unix_mode = O_WRONLY;
            break;
        case RESOURCE_READ_WRITE:
            unix_mode = O_RDWR;
            break;
        default:
            return -1;
    }
    return mq_open(name, unix_mode | O_NONBLOCK);
}

int allocate_resource(resource_t *resource)
{
    if(!resource->name || !resource->type){
        fprintf(stderr, "invalid resource\n");
        return 1;
    }

    if(!strcmp(resource->type, "Message")){
        return allocate_message_queue(resource);
    }else{
        fprintf(stderr, "resource %s has invalid type %s\n",
                resource->name, resource->type);
        return 1;
    }
}

int setup_resource(resource_t *resource, resource_descriptor_t *resource_descriptor)
{
    if(!strcmp(resource->type, "Message")){
        resource_descriptor->fd = open_message_queue(resource, resource_descriptor->mode);
        return 0;
    }else{
        fprintf(stderr, "cannot setup unknown resource %s\n", resource->name);
        return 1;
    }
}
