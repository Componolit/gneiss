
#include <stdio.h>
#include <string.h>
#include <dlfcn.h>
#include <sys/types.h>
#include <unistd.h>

#include <list.h>
#include <component.h>
#include <config.h>

#define ENABLE_TRACE
#include <trace.h>

static xmlNode *config;
static list_t component_registry;
static list_t resource_registry;
static component_t component;

static int start_component(list_t *item, unsigned size, void *arg)
{
    void *handle;
    memcpy(&component, (*item)->content, sizeof(component_t));
    pid_t pid = fork();
    switch(pid){
        case 0:
            fprintf(stderr, "loading %s from %s into %i\n", component.name, component.file, getpid());
            handle = dlopen(component.file, RTLD_LAZY);
            if(!handle){
                fprintf(stderr, "dlopen: %s\n", dlerror());
                exit(1);
            }
            component.status = -1;
            TRACE("%p %p\n", dlsym(handle, "component__construct"), dlsym(handle, "component__destruct"));
            *(void **) &(component.construct) = dlsym(handle, "component__construct");
            *(void **) &(component.destruct) = dlsym(handle, "component__destruct");
            exit(component_main(&component));
        case -1:
            perror("fork failed");
            break;
        default:
            break;
    }
    return 0;
}

int main(int argc, char *argv[])
{
    int status;
    if(argc != 2){
        fprintf(stderr, "Usage: %s config\n", argv[0]);
        return 1;
    }

    component_registry = list_new();
    config = read_config(argv[1]);
    status = parse_resources(config, resource_registry);
    if(status){
        fprintf(stderr, "failed to parse resources\n");
        return status;
    }
    status = parse_components(config, component_registry);
    if(status){
        fprintf(stderr, "failed to parse components\n");
        return status;
    }
    list_foreach(component_registry, &start_component, 0);

    return 0;
}
