
#ifndef _CAI_FACTORY_H_
#define _CAI_FACTORY_H_

#include <base/heap.h>

class Factory
{
    private:
        Genode::Sliced_heap _heap;
        Genode::Allocator_avl _alloc;
    public:
        Factory(Genode::Env &env) :
            _heap(env.ram(), env.rm()),
            _alloc(&_heap)
        { }

        template <typename T, typename ... Args>
        void *create(Args &&... args)
        {
            return reinterpret_cast<void *>(new (_heap) T(args ...));
        }

        template <typename T>
        void destroy(void *obj)
        {
            Genode::destroy(_heap, reinterpret_cast<T *>(obj));
        }
};

#endif /* ifndef _CAI_FACTORY_H_ */
