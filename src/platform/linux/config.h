
#ifndef _GNEISS_CONFIG_H_
#define _GNEISS_CONFIG_H_

#include <list.h>
#include <libxml/parser.h>

xmlNode *read_config(const char *file);
int parse_resources(xmlNode *root, list_t resources);
int parse_components(xmlNode *root, list_t components);

#endif /* ifndef _GNEISS_CONFIG_H_ */
