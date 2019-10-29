
#include <stdio.h>
#include <string.h>
#include <dlfcn.h>
#include <sys/types.h>
#include <unistd.h>
#include <libxml/parser.h>

#include <list.h>
#include <component.h>

static list_t component_registry;

static void parse_config(const char *file)
{
    xmlDoc *document;
    xmlNode *root;
    component_t component;

    document = xmlReadFile(file, 0, 0);
    root = xmlDocGetRootElement(document);

    for(xmlNode *node = root->children; node; node = node->next){
        if(strcmp(node->name, "component")){
            continue;
        }
        component.name = xmlGetProp(node, "name");
        for(xmlNode *comp = node->children; comp; comp = comp->next){
            if(!strcmp(comp->name, "file")){
                component.file = xmlGetProp(comp, "name");
            }
        }
        list_append(component_registry, (void *)&component, sizeof(component));
    }
}

static int start_component(list_t *item, unsigned size, void *arg)
{
    component_t *c = (component_t *)((*item)->content);
    void *handle;
    pid_t pid = fork();
    switch(pid){
        case 0:
            fprintf(stderr, "loading %s from %s into %i\n", c->name, c->file, getpid());
            handle = dlopen(c->file, RTLD_LAZY);
            if(!handle){
                fprintf(stderr, "dlopen: %s\n", dlerror());
            }
            return 1;
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
