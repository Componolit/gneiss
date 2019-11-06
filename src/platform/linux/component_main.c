
#include <string.h>
#include <component.h>
#include <list.h>

#define ENABLE_TRACE
#include <trace.h>

static fd_set write_fds;
static fd_set read_fds;

static void set_status(capability_t *capability, int status)
{
    TRACE("%d\n", status);
    capability->component->status = status;
}

static int search_resource(list_t *item, unsigned size, void *arg)
{
    resource_descriptor_t *res = (resource_descriptor_t *)((*item)->content);
    resource_descriptor_t *check = (resource_descriptor_t *)arg;
    TRACE("%s = %s, %s = %s, %d = %d, %d\n",
            res->type, check->type, res->label, check->label, res->mode, check->mode, res->fd);
    return !strcmp(res->type, check->type)
        && !strcmp(res->label, check->label)
        && res->mode == check->mode
        && res->fd >= 0;
}

static void find_resource(capability_t *capability, char *type, char *name, int mode, void (*event)(void), resource_descriptor_t *resource)
{
    resource_descriptor_t res;
    list_t item;
    res.label = name;
    res.type = type;
    res.mode = mode;
    item = list_foreach(capability->component->resources, &search_resource, &res);
    TRACE("%s %s %d %p %p\n", type, name, mode, event, item);
    if(item){
        ((resource_descriptor_t *)(item->content))->event = event;
        memcpy(resource, item->content, sizeof(resource_descriptor_t));
    }else{
        memset(resource, 0, sizeof(resource_descriptor_t));
        resource->fd = -1;
    }
}

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

    component->capability.component = component;
    component->capability.set_status = &set_status;
    component->capability.find_resource = &find_resource;

    TRACE("%d %p %p %p\n", component->status, component->construct, component->destruct, component->capability.set_status);
    component->construct(&(component->capability));
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
