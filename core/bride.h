#pragma once

#include <stdlib.h>

extern void (*release_object_func)(void *obj);

extern void (*protect_func)(void *tun_interface, int fd);

extern const char* (*resolve_process_func)(void *tun_interface, int protocol, const char *source, const char *target, int uid);

extern const char* (*result_func)(void *invoke_Interface, const char *data);

extern void protect(void *tun_interface, int fd);

extern const char* resolve_process(void *tun_interface, int protocol, const char *source, const char *target, int uid);

extern void release_object(void *obj);

extern const char* result(void *invoke_Interface,  const char *data);