
#include <stdio.h>
#include <mqueue.h>
#include <component.h>
#include <list.h>

#define ENABLE_TRACE
#include <trace.h>

void message_writer_write(list_t *item, void *buffer, long long size)
{
    resource_descriptor_t *res = (resource_descriptor_t *)((*item)->content);
    TRACE("%p %p %lli\n", res, buffer, size);
    if(mq_send(res->fd, buffer, size, 0) < 0){
        perror("mq_send");
    }
}
