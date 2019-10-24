
#ifndef _GNEISS_GENODE_TRACE_H_
#define _GNEISS_GENODE_TRACE_H_

#ifdef ENABLE_TRACE

#include <base/log.h>
#define TLOG(...) Genode::log(__FILE__, ":", __LINE__," (", __func__, "): ",##__VA_ARGS__)
#define TWRN(...) Genode::warning(__FILE__, ":", __LINE__," (", __func__, "): ",##__VA_ARGS__)
#define TERR(...) Genode::error(__FILE__, ":", __LINE__," (", __func__, "): ",##__VA_ARGS__)

#else

#define TLOG(...)
#define TWRN(...)
#define TERR(...)

#endif

#endif /* ifndef _GNEISS_GENODE_TRACE_H_ */
