
#ifndef _GNEISS_COMPONENT_H_
#define _GNEISS_COMPONENT_H_

#include <list.h>

#define COMPONENT_RUNNING -1
#define COMPONENT_SUCCESS 0
#define COMPONENT_ERROR 1

#define RESOURCE_READ 1
#define RESOURCE_WRITE 2
#define RESOURCE_READ_WRITE 3

typedef struct component component_t;
typedef struct capability capability_t;
typedef struct resource resource_t;
typedef struct resource_descriptor resource_descriptor_t;

struct resource {
    char *type;
    char *name;
    int read;
    int write;
    int read_write;
};

struct resource_descriptor {
    char *type;
    char *name;
    char *label;
    int mode;
    int fd;
    void (*event)(void);
};

struct capability {
    component_t *component;
    void (*set_status)(capability_t *, int);
    void (*find_resource)(capability_t *, char *, char *, int, void (*)(void), int *);
};

struct component {
    capability_t capability;
    int status;
    char *name;
    char *file;
    void (*construct)(capability_t *);
    void (*destruct)(void);
    list_t resources;
};

int component_main(component_t *component);

#endif /* ifndef _COMPONENT_H_ */
