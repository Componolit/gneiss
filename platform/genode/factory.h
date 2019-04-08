
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
        T *create(Args &&... args)
        {
            return new (_heap) T(args ...);
        }

        template <typename T>
        void destroy(T *obj)
        {
            Genode::destroy(_heap, obj);
        }
};

#endif /* ifndef _CAI_FACTORY_H_ */
