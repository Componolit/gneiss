
#include <stdio.h>
#include <string.h>
#include <dlfcn.h>
#include <sys/types.h>
#include <unistd.h>
#include <libxml/parser.h>

#include <list.h>
#include <component.h>

#define ENABLE_TRACE
#include <trace.h>

static list_t component_registry;
static component_t component;

static void parse_config(const char *file)
{
    xmlDoc *document;
    xmlNode *root;
    component_t local_component;

    memset(&local_component, 0, sizeof(local_component));

    document = xmlReadFile(file, 0, 0);
    root = xmlDocGetRootElement(document);

    for(xmlNode *node = root->children; node; node = node->next){
        if(strcmp(node->name, "component")){
            continue;
        }
        local_component.name = xmlGetProp(node, "name");
        for(xmlNode *comp = node->children; comp; comp = comp->next){
            if(!strcmp(comp->name, "file")){
                local_component.file = xmlGetProp(comp, "name");
            }
        }
        list_append(component_registry, (void *)&local_component, sizeof(component_t));
    }
}

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
    if(argc != 2){
        fprintf(stderr, "Usage: %s config\n", argv[0]);
        return 1;
    }

    component_registry = list_new();
    parse_config(argv[1]);
    list_foreach(component_registry, &start_component, 0);

    return 0;
}
