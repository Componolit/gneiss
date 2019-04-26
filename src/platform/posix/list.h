
#ifndef _LIST_H_
#define _LIST_H_

typedef struct list_s *list_t;

struct list_s {
    void *content;
    unsigned size;
    struct list_s *head;
    struct list_s *next;
};

list_t list_new(void);
list_t list_append(list_t, void*, unsigned);
void list_remove(list_t, list_t);
list_t list_find(list_t, void*, unsigned, int (*)(const void *, const void *, size_t));
list_t list_foreach(list_t, int(*)(list_t*, unsigned, void*), void*);
unsigned list_length(list_t);
void list_delete(list_t);

#endif //_LIST_H_

