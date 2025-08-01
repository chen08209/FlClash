#include <jni.h>

#ifdef LIBCLASH
#include "jni_helper.h"
#include "libclash.h"
#include "bride.h"

extern "C"
JNIEXPORT void JNICALL
Java_com_follow_clash_core_Core_startTun(JNIEnv *env, jobject, const jint fd, jobject cb) {
    const auto interface = new_global(cb);
    startTUN(interface, fd);
}

extern "C"
JNIEXPORT void JNICALL
Java_com_follow_clash_core_Core_stopTun(JNIEnv *) {
    stopTun();
}

extern "C"
JNIEXPORT void JNICALL
Java_com_follow_clash_core_Core_invokeAction(JNIEnv *env, jobject thiz, jstring data, jobject cb) {
    const auto interface = new_global(cb);
    scoped_string sd = get_string(data);
    invokeAction(interface, sd);
}


static jmethodID m_tun_interface_protect;
static jmethodID m_tun_interface_resolve_process;
static jmethodID m_invoke_interface_result;


static void release_jni_object_impl(void *obj) {
    ATTACH_JNI();
    del_global(static_cast<jobject>(obj));
}

static void call_tun_interface_protect_impl(void *tun_interface, const int fd) {
    ATTACH_JNI();
    env->CallVoidMethod(static_cast<jobject>(tun_interface),
                        m_tun_interface_protect,
                        fd);
}

static const char *
call_tun_interface_resolve_process_impl(void *tun_interface, int protocol,
                                        const char *source,
                                        const char *target,
                                        const int uid) {
    ATTACH_JNI();
    const auto packageName = reinterpret_cast<jstring>(env->CallObjectMethod(static_cast<jobject>(tun_interface),
                                                                             m_tun_interface_resolve_process,
                                                                             protocol,
                                                                             new_string(source),
                                                                             new_string(target),
                                                                             uid));
    const scoped_string sp = get_string(packageName);
    return sp;
}

static const char *
call_invoke_interface_result_impl(void *invoke_interface, const char *data) {
    ATTACH_JNI();
    const auto res = reinterpret_cast<jstring>(env->CallObjectMethod(static_cast<jobject>(invoke_interface),
                                                                     m_invoke_interface_result,
                                                                     new_string(data)));
    const scoped_string sr = get_string(res);
    return sr;
}

extern "C"
JNIEXPORT jint JNICALL
JNI_OnLoad(JavaVM *vm, void *) {
    JNIEnv *env = nullptr;
    if (vm->GetEnv(reinterpret_cast<void **>(&env), JNI_VERSION_1_6) != JNI_OK) {
        return JNI_ERR;
    }

    initialize_jni(vm, env);

    const auto c_tun_interface = find_class("com/follow/clash/core/TunInterface");

    const auto c_invoke_interface = find_class("com/follow/clash/core/InvokeInterface");

    m_tun_interface_protect = find_method(c_tun_interface, "protect", "(I)V");
    m_tun_interface_resolve_process = find_method(c_tun_interface, "resolverProcess",
                                                  "(ILjava/lang/String;Ljava/lang/String;I)Ljava/lang/String;");
    m_invoke_interface_result = find_method(c_invoke_interface, "onResult",
                                            "(Ljava/lang/String;)V");


    protect_func = &call_tun_interface_protect_impl;
    resolve_process_func = &call_tun_interface_resolve_process_impl;
    result_func = &call_invoke_interface_result_impl;
    release_object_func = &release_jni_object_impl;

    return JNI_VERSION_1_6;
}
#else
extern "C"
JNIEXPORT void JNICALL
Java_com_follow_clash_core_Core_startTun(JNIEnv *env, jobject thiz, jint fd, jobject cb) {
}

extern "C"
JNIEXPORT void JNICALL
Java_com_follow_clash_core_Core_stopTun(JNIEnv *env, jobject thiz) {
}

extern "C"
JNIEXPORT void JNICALL
Java_com_follow_clash_core_Core_invokeAction(JNIEnv *env, jobject thiz, jstring data, jobject cb) {
    // TODO: implement invokeAction()
}
#endif
