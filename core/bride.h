#pragma once

#include <stdlib.h>

extern void (*release_object_func)(void *obj);

extern void (*free_string_func)(char *data);

extern int (*protect_func)(void *tun_interface, int fd);

extern int (*resolve_uid_func)(void *tun_interface, int protocol, const char *source, const char *target);

extern char* (*resolve_package_func)(void *tun_interface, int uid);

extern void (*result_func)(void *invoke_Interface, const char *data);

extern int protect(void *tun_interface, int fd);

// Returns -1 when the system will not name the owner of the connection.
extern int resolve_uid(void *tun_interface, int protocol, const char *source, const char *target);

extern char* resolve_package(void *tun_interface, int uid);

extern void release_object(void *obj);

extern void free_string(char *data);

extern void result(void *invoke_Interface,  const char *data);