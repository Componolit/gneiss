
#ifndef _CAI_FACTORY_H_
#define _CAI_FACTORY_H_

#include <base/env.h>
#include <base/heap.h>
#include <util/reconstructible.h>

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
        T *create2(Args &&... args)
        {
            try{
                return new(_heap) T(args ...);
            }catch(...){
                return nullptr;
            }
        }

        template <typename T, typename ... Args>
        void *create(Args &&... args)
        {
            Genode::warning(__func__, " is deprecated");
            try{
                return reinterpret_cast<void *>(new (_heap) T(args ...));
            }catch(...){
                return nullptr;
            }
        }

        template <typename T>
        void destroy(T *obj)
        {
            Genode::destroy(_heap, obj);
        }

        template <typename T>
        void destroy(void *obj)
        {
            Genode::warning(__func__, " is deprecated");
            destroy<T>(reinterpret_cast<T *>(obj));
        }

        Genode::Allocator_avl &alloc()
        {
            return _alloc;
        }
};

/*
 * helper macros to call ada functions that are available as void pointers
 */

/*
 * dereferences attr to
 * Genode::uint64_t attr(void *);
 * and calls it with state as argument
 */
#define Get_attr_64(attr, state) ((Genode::uint64_t (*)(void *))attr)(state)

/*
 * derferences attr to
 * void attr(void);
 * and calls it
 */
#define Call(attr) ((void (*)(void))attr)()

inline void check_factory(Genode::Reconstructible<Factory> &factory, Genode::Env &env)
{
    if(!factory.constructed()){
        factory.construct(env);
    }
}

#endif /* ifndef _CAI_FACTORY_H_ */
