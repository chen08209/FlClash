#pragma once

#include <jni.h>

struct scoped_jni {
    JNIEnv *env;
    int require_release;
};

extern void initialize_jni(JavaVM *vm, JNIEnv *env);

extern jstring jni_new_string(JNIEnv *env, const char *str);

extern char *jni_get_string(JNIEnv *env, jstring str);

extern int jni_catch_exception(JNIEnv *env);

extern void jni_attach_thread(scoped_jni *jni);

extern void jni_detach_thread(const scoped_jni *env);

extern void release_string( char **str);

#define ATTACH_JNI() __attribute__((unused, cleanup(jni_detach_thread))) \
                    scoped_jni _jni{}; \
                    jni_attach_thread(&_jni); \
                    JNIEnv *env = _jni.env

#define scoped_string __attribute__((cleanup(release_string))) char*

#define find_class(name) env->FindClass(name)
#define find_method(cls, name, signature) env->GetMethodID(cls, name, signature)
#define new_global(obj) env->NewGlobalRef(obj)
#define del_global(obj) env->DeleteGlobalRef(obj)
#define get_string(jstr) jni_get_string(env, jstr)
#define new_string(cstr) jni_new_string(env, cstr)
