
#include <stdio.h>
#include <string.h>
#include <mqueue.h>
#include <component.h>

#define ENABLE_TRACE
#include <trace.h>

static unsigned char cache[4096];

void message_reader_read(resource_descriptor_t *res, void *buffer, long long size)
{
    TRACE("%p %p %lli\n", res, buffer, size);
    if(mq_receive(res->fd, cache, sizeof(cache), 0) < 0){
        perror("mq_receive");
    }
    memcpy(buffer, cache, size);
}

int message_reader_available(resource_descriptor_t *res)
{
    struct mq_attr attr;
    if(mq_getattr(res->fd, &attr) < 0){
        perror("mq_getattr");
    }
    TRACE("%p %li\n", res, attr.mq_curmsgs);
    return attr.mq_curmsgs > 0;
}
