
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include <list.h>
#include <config.h>
#include <component.h>

#define ENABLE_TRACE
#include <trace.h>

int parse_resources(xmlNode *root, list_t resources)
{
    resource_t res;
    char *value;
    for(xmlNode *node = root->children; node; node = node->next){
        memset(&res, 0, sizeof(res));
        if(strcmp(node->name, "service")){
            continue;
        }
        res.type = xmlGetProp(node, "type");
        res.name = xmlGetProp(node, "name");
        res.fd = -1;
        if(!res.name || !res.type){
            fprintf(stderr, "resource without name or type\n");
            return 1;
        }
        value = xmlGetProp(node, "read");
        res.read = value ? atoi(value) : 0;
        value = xmlGetProp(node, "write");
        res.write = value ? atoi(value) : 0;
        value = xmlGetProp(node, "read_write");
        res.read_write = value ? atoi(value) : 0;
        list_append(resources, (void *)&res, sizeof(res));
    }
    return 0;
}

int parse_components(xmlNode *root, list_t components)
{
    component_t comp;
    for(xmlNode *node = root->children; node; node = node->next){
        memset(&comp, 0, sizeof(comp));
        if(strcmp(node->name, "component")){
            continue;
        }
        comp.name = xmlGetProp(node, "name");
        if(!comp.name){
            fprintf(stderr, "component without name\n");
            return 1;
        }
        comp.file = xmlGetProp(node, "file");
        if(!comp.file){
            comp.file = (char *)malloc(strlen(comp.name) + 17);
            if(!comp.file){
                perror("component file");
                return 1;
            }
            memset(comp.file, 0, strlen(comp.name) + 17);
            strcat(comp.file, "libcomponent_");
            strcat(comp.file, comp.name);
            strcat(comp.file, ".so");
        }
        list_append(components, (void *)&comp, sizeof(comp));
    }
    return 0;
}

xmlNode *read_config(const char *file)
{
    xmlDoc *document;
    xmlNode *root;
    int status;

    document = xmlReadFile(file, 0, 0);
    root = xmlDocGetRootElement(document);
    return root;
}
