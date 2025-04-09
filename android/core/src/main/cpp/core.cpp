#include <jni.h>

#ifdef LIBCLASH
#include <jni.h>
#include <string>
#include "jni_helper.h"
#include "libclash.h"

extern "C"
JNIEXPORT void JNICALL
Java_com_follow_clash_core_Core_startTun(JNIEnv *env, jobject thiz, jint fd, jobject cb) {
    auto interface = new_global(cb);
    startTUN(fd, interface);
}

extern "C"
JNIEXPORT void JNICALL
Java_com_follow_clash_core_Core_stopTun(JNIEnv *env, jobject thiz) {
    stopTun();
}


static jmethodID m_tun_interface_protect;
static jmethodID m_tun_interface_resolve_process;


static void release_jni_object_impl(void *obj) {
    ATTACH_JNI();
    del_global((jobject) obj);
}

static void call_tun_interface_protect_impl(void *tun_interface, int fd) {
    ATTACH_JNI();
    env->CallVoidMethod((jobject) tun_interface,
                        (jmethodID) m_tun_interface_protect,
                        (jint) fd);
}

static const char*
call_tun_interface_resolve_process_impl(void *tun_interface, int protocol,
                                         const char *source,
                                         const char *target,
                                         int uid) {
    ATTACH_JNI();
    jstring packageName = (jstring)env->CallObjectMethod((jobject) tun_interface,
                              (jmethodID) m_tun_interface_resolve_process,
                              (jint) protocol,
                              (jstring) new_string(source),
                              (jstring) new_string(target),
                              (jint) uid);
    return get_string(packageName);
}

extern "C"
JNIEXPORT jint JNICALL
JNI_OnLoad(JavaVM *vm, void *reserved) {
    JNIEnv *env = nullptr;
    if (vm->GetEnv((void **) &env, JNI_VERSION_1_6) != JNI_OK) {
        return JNI_ERR;
    }

    initialize_jni(vm, env);

    jclass c_tun_interface = find_class("com/follow/clash/core/TunInterface");

    m_tun_interface_protect = find_method(c_tun_interface, "protect", "(I)V");
    m_tun_interface_resolve_process = find_method(c_tun_interface, "resolverProcess",
                                                   "(ILjava/lang/String;Ljava/lang/String;I)Ljava/lang/String;");

    registerCallbacks(&call_tun_interface_protect_impl,
                      &call_tun_interface_resolve_process_impl,
                      &release_jni_object_impl);
    return JNI_VERSION_1_6;
}
#endif