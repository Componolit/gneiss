
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include <list.h>
#include <config.h>
#include <component.h>

//#define ENABLE_TRACE
#include <trace.h>

int parse_resources(xmlNode *root, list_t resources)
{
    resource_t res;
    char *value;
    for(xmlNode *node = root->children; node; node = node->next){
        memset(&res, 0, sizeof(res));
        if(strcmp(node->name, "resource")){
            continue;
        }
        res.type = xmlGetProp(node, "type");
        res.name = xmlGetProp(node, "name");
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
        TRACE("add resource %s %s\n", res.type, res.name);
        list_append(resources, (void *)&res, sizeof(res));
    }
    return 0;
}

int parse_components(xmlNode *root, list_t components)
{
    component_t comp;
    resource_descriptor_t resd;
    char *mode;
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
        comp.resources = list_new();
        for(xmlNode *res = node->children; res; res = res->next){
            memset(&resd, 0, sizeof(resd));
            mode = 0;
            if(strcmp(res->name, "resource")){
                continue;
            }
            resd.type = xmlGetProp(res, "type");
            resd.name = xmlGetProp(res, "name");
            resd.label = xmlGetProp(res, "label");
            mode = xmlGetProp(res, "mode");
            if(!resd.type || !resd.name || !resd.label || !mode){
                fprintf(stderr, "ignoring invalid resource\n");
                continue;
            }
            if(!strcmp(mode, "read")){
                resd.mode = RESOURCE_READ;
            }else if(!strcmp(mode, "write")){
                resd.mode = RESOURCE_WRITE;
            }else if(!strcmp(mode, "read_write")){
                resd.mode = RESOURCE_READ_WRITE;
            }else{
                fprintf(stderr, "resource %s of %s has invalid mode %s\n",
                        resd.name, comp.name, mode);
                continue;
            }
            TRACE("add resource desc %s %s %s %s\n", resd.type, resd.name, resd.label, mode);
            resd.fd = -1;
            resd.event = 0;
            list_append(comp.resources, (void *)&resd, sizeof(resd));
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
