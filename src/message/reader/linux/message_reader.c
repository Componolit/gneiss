
#include <stdio.h>
#include <string.h>
#include <mqueue.h>
#include <component.h>
#include <list.h>

//#define ENABLE_TRACE
#include <trace.h>

static unsigned char cache[4096];

void message_reader_read(list_t *item, void *buffer, long long size)
{
    resource_descriptor_t *res = (resource_descriptor_t *)((*item)->content);
    TRACE("%p %p %p %lli\n", item, res, buffer, size);
    if(mq_receive(res->fd, cache, sizeof(cache), 0) < 0){
        perror("mq_receive");
    }
    memcpy(buffer, cache, size);
}

int message_reader_available(list_t item)
{
    resource_descriptor_t *res = (resource_descriptor_t *)(item->content);
    struct mq_attr attr;
    if(mq_getattr(res->fd, &attr) < 0){
        perror("mq_getattr");
    }
    TRACE("%p %p %li\n", item, res, attr.mq_curmsgs);
    return attr.mq_curmsgs > 0;
}
