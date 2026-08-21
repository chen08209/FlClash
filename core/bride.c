//go:build android && cgo

#include "bride.h"

void (*release_object_func)(void *obj);

void (*free_string_func)(char *data);

void (*protect_func)(void *tun_interface, int fd);

char* (*resolve_process_func)(void *tun_interface,int protocol, const char *source, const char *target, int uid);

void (*result_func)(void *invoke_Interface, const char *data);

void protect(void *tun_interface, int fd) {
    if (protect_func == NULL) {
        return;
    }
    protect_func(tun_interface, fd);
}

char* resolve_process(void *tun_interface, int protocol, const char *source, const char *target, int uid) {
    if (resolve_process_func == NULL) {
        return NULL;
    }
    return resolve_process_func(tun_interface, protocol, source, target, uid);
}

void release_object(void *obj) {
    if (release_object_func == NULL) {
        return;
    }
    release_object_func(obj);
}

void free_string(char *data) {
    if (free_string_func == NULL) {
        return;
    }
    free_string_func(data);
}

void result(void *invoke_Interface, const char *data) {
    if (result_func == NULL) {
        return;
    }
    result_func(invoke_Interface, data);
}
