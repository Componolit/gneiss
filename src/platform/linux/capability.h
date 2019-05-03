
#ifndef _CAI_CAPABILITY_H_
#define _CAI_CAPABILITY_H_

#define COMPONENT_RUNNING -1
#define COMPONENT_SUCCESS 0
#define COMPONENT_ERROR 1

typedef struct capability
{
    int status;
    void (*enlist)(int, void (*)(int, void *), void *);
    void (*withdraw)(int);
    char *config_file;
} capability_t;

#endif /* ifndef _CAI_CAPABILITY_H_ */
