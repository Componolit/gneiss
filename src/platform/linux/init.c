
#include <stdio.h>
#include <string.h>
#include <dlfcn.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/wait.h>

#include <list.h>
#include <component.h>
#include <config.h>
#include <resources.h>

//#define ENABLE_TRACE
#include <trace.h>

static xmlNode *config;
static list_t component_registry;
static list_t resource_registry;
static component_t component;

static int allocate_resources(list_t *item, unsigned size, void *arg)
{
    resource_t *res = (resource_t *)((*item)->content);
    return allocate_resource(res);
}

static int find_resources(list_t *item, unsigned size, void *arg)
{
    resource_t *res = (resource_t *)((*item)->content);
    resource_descriptor_t *resd = (resource_descriptor_t *)arg;
    if(!strcmp(res->type, resd->type) && !strcmp(res->name, resd->name)){
        setup_resource(res, resd);
        TRACE("%s %s %i\n", res->type, res->name, resd->fd);
    }
    return 0;
}

static int setup_resources(list_t *item, unsigned size, void *arg)
{
    resource_descriptor_t *res = (resource_descriptor_t *)((*item)->content);
    TRACE("%s %s %s\n", res->type, res->name, res->label);
    list_foreach(resource_registry, &find_resources, res);
    return 0;
}

static int start_component(list_t *item, unsigned size, void *arg)
{
    void *handle;
    memcpy(&component, (*item)->content, sizeof(component_t));
    list_foreach(component.resources, &setup_resources, 0);
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
    pid_t chpid;
    if(argc != 2){
        fprintf(stderr, "Usage: %s <config>\n", argv[0]);
        return 1;
    }

    component_registry = list_new();
    resource_registry = list_new();
    config = read_config(argv[1]);
    if(!config){
        fprintf(stderr, "failed to read config\n");
        return 1;
    }
    TRACE("parse_resources\n");
    status = parse_resources(config, resource_registry);
    if(status){
        fprintf(stderr, "failed to parse resources\n");
        return status;
    }
    TRACE("parse_components\n");
    status = parse_components(config, component_registry);
    if(status){
        fprintf(stderr, "failed to parse components\n");
        return status;
    }
    TRACE("allocate_resources %u\n", list_length(resource_registry));
    if(list_foreach(resource_registry, &allocate_resources, 0)){
        fprintf(stderr, "failed to allocate resources\n");
        return 1;
    }
    TRACE("start_component %u\n", list_length(component_registry));
    list_foreach(component_registry, &start_component, 0);

    while(1){
        chpid = waitpid(-1, &status, 0);
        if(chpid < 0){
            perror("waitpid");
            return 1;
        }else{
            if(WIFEXITED(status)){
                fprintf(stderr, "Child %u terminated with %d\n",
                        chpid, WEXITSTATUS(status));
            }else if(WIFSIGNALED(status)){
                fprintf(stderr, "Child %u was terminated by signal %d\n",
                        chpid, WTERMSIG(status));
            }else{
                fprintf(stderr, "Child %u was terminated for unknown reasons\n");
            }
        }
    }
    return 0;
}
