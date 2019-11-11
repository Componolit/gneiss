
#include <component.h>
#include <list.h>

//#define ENABLE_TRACE
#include <trace.h>

void set_status(component_t *component, int status)
{
    TRACE("%d\n", status);
    component->status = status;
}

list_t get_resource_pointer(component_t *component)
{
    return component->resources;
}

list_t next_resource_pointer(list_t item)
{
    TRACE("%p %p\n", item, item->next);
    return item->next;
}

int resource_pointer_valid(list_t item)
{
    TRACE("%p\n", item);
    return !!item;
}

char *resource_pointer_label(list_t item)
{
    return ((resource_descriptor_t *)(item->content))->label;
}

char *resource_pointer_type(list_t item)
{
    return ((resource_descriptor_t *)(item->content))->type;
}

int resource_pointer_mode(list_t item)
{
    return ((resource_descriptor_t *)(item->content))->mode;
}

void resource_pointer_set_event(list_t item, void (*event)(void), int *success)
{
    resource_descriptor_t *res = (resource_descriptor_t *)(item->content);
    if(res->event){
        *success = 0;
    }else{
        *success = 1;
        res->event = event;
    }
    TRACE("%p %i\n", event, *success);
}

void resource_pointer_delete_event(list_t item, void (*event)(void), int *success)
{
    resource_descriptor_t *res = (resource_descriptor_t *)(item->content);
    if(res->event = event){
        res->event = 0;
        *success = 1;
    }else{
        *success = 0;
    }
    TRACE("%p %i\n", event, *success);
}

list_t invalid_resource_pointer(void)
{
    return 0;
}
