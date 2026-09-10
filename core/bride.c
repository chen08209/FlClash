//go:build android && cgo

#include "bride.h"

void (*release_object_func)(void *obj);

void (*free_string_func)(char *data);

int (*protect_func)(void *tun_interface, int fd);

int (*resolve_uid_func)(void *tun_interface, int protocol, const char *source, const char *target);

char* (*resolve_package_func)(void *tun_interface, int uid);

void (*result_func)(void *invoke_Interface, const char *data);

int protect(void *tun_interface, int fd) {
    if (protect_func == NULL) {
        return 0;
    }
    return protect_func(tun_interface, fd);
}

int resolve_uid(void *tun_interface, int protocol, const char *source, const char *target) {
    if (resolve_uid_func == NULL) {
        return -1;
    }
    return resolve_uid_func(tun_interface, protocol, source, target);
}

char* resolve_package(void *tun_interface, int uid) {
    if (resolve_package_func == NULL) {
        return NULL;
    }
    return resolve_package_func(tun_interface, uid);
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
