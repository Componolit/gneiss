
#include <string.h>
#include <component.h>
#include <list.h>

//#define ENABLE_TRACE
#include <trace.h>

static fd_set write_fds;
static fd_set read_fds;

static int initialize_fds(list_t *item, unsigned size, void *max)
{
    resource_descriptor_t *res = ((resource_descriptor_t *)((*item)->content));
    if((res->mode == RESOURCE_READ || res->mode == RESOURCE_READ_WRITE) && res->event){
        FD_SET(res->fd, &read_fds);
    }
    if((res->mode == RESOURCE_WRITE || res->mode == RESOURCE_READ_WRITE) && res->event){
        FD_SET(res->fd, &write_fds);
    }
    if(res->fd > *(int *)max){
        *(int *)max = res->fd;
    }
    return 0;
}

static int execute_events(list_t *item, unsigned size, void *arg)
{
    resource_descriptor_t *res = (resource_descriptor_t *)((*item)->content);
    if(FD_ISSET(res->fd, &read_fds) || FD_ISSET(res->fd, &write_fds)){
        if(res->event){
            res->event();
        }
    }
}

int component_main(component_t *component)
{
    int max_fd;

    TRACE("%d %p %p\n", component->status, component->construct, component->destruct);
    component->construct(component);
    while(component->status == COMPONENT_RUNNING){
        FD_ZERO(&read_fds);
        FD_ZERO(&write_fds);
        max_fd = 0;
        list_foreach(component->resources, &initialize_fds, &max_fd);
        select(max_fd + 1, &read_fds, &write_fds, 0, 0);
        list_foreach(component->resources, &execute_events, 0);
    }
    component->destruct();
    return component->status;
}
