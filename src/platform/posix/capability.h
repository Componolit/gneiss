
#ifndef _CAI_CAPABILITY_H_
#define _CAI_CAPABILITY_H_

typedef struct capability
{
    void (*enlist)(int, void (*)(int, void *), void *);
    void (*withdraw)(int);
    char *config_file;
} capability_t;

#endif /* ifndef _CAI_CAPABILITY_H_ */
