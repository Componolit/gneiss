
#include <stdio.h>
#include <mqueue.h>
#include <component.h>

#define ENABLE_TRACE
#include <trace.h>

void message_writer_write(resource_descriptor_t *res, void *buffer, long long size)
{
    TRACE("%p %p %lli\n", res, buffer, size);
    if(mq_send(res->fd, buffer, size, 0) < 0){
        perror("mq_send");
    }
}
