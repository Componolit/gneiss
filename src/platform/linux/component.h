
#ifndef _GNEISS_COMPONENT_H_
#define _GNEISS_COMPONENT_H_

#define COMPONENT_RUNNING -1
#define COMPONENT_SUCCESS 0
#define COMPONENT_ERROR 1

typedef struct component component_t;
typedef struct capability capability_t;

struct capability {
    component_t *component;
    void (*set_status)(capability_t *, int);
};

struct component {
    capability_t capability;
    int status;
    char *name;
    char *file;
    void (*construct)(capability_t *);
    void (*destruct)(void);
};

int component_main(component_t *component);

#endif /* ifndef _COMPONENT_H_ */
