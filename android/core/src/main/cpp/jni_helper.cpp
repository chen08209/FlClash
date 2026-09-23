#include "jni_helper.h"

#include <cstdlib>
#include <cstring>
#include <pthread.h>

static JavaVM *global_vm;

static jclass c_string;
static jmethodID m_new_string;
static jmethodID m_get_bytes;

static pthread_key_t detach_key;
static bool detach_key_ready;

static void detach_current_thread(void *) {
    global_vm->DetachCurrentThread();
}

void initialize_jni(JavaVM *vm, JNIEnv *env) {
    global_vm = vm;

    detach_key_ready = pthread_key_create(&detach_key, detach_current_thread) == 0;

    c_string = reinterpret_cast<jclass>(new_global(find_class("java/lang/String")));
    m_new_string = find_method(c_string, "<init>", "([B)V");
    m_get_bytes = find_method(c_string, "getBytes", "()[B");
}

bool jni_clear_exception(JNIEnv *env) {
    if (env->ExceptionCheck() == JNI_FALSE) {
        return false;
    }
    env->ExceptionDescribe();
    env->ExceptionClear();
    return true;
}

static char *empty_string() {
    return static_cast<char *>(calloc(1, 1));
}

char *jni_get_string(JNIEnv *env, jstring str) {
    if (str == nullptr) {
        return empty_string();
    }
    const auto array = reinterpret_cast<jbyteArray>(env->CallObjectMethod(str, m_get_bytes));
    if (jni_clear_exception(env) || array == nullptr) {
        return empty_string();
    }
    const int length = env->GetArrayLength(array);
    const auto content = static_cast<char *>(malloc(length + 1));
    if (content == nullptr) {
        env->DeleteLocalRef(array);
        return empty_string();
    }
    env->GetByteArrayRegion(array, 0, length, reinterpret_cast<jbyte *>(content));
    if (jni_clear_exception(env)) {
        // The copy did not happen, so `content` still holds whatever malloc
        // handed back. Returning it would pass that heap content on as the
        // string the caller asked for.
        free(content);
        env->DeleteLocalRef(array);
        return empty_string();
    }
    env->DeleteLocalRef(array);
    content[length] = 0;
    return content;
}

jstring jni_new_string(JNIEnv *env, const char *str) {
    if (str == nullptr) {
        str = "";
    }
    const auto length = static_cast<int>(strlen(str));
    const auto array = env->NewByteArray(length);
    if (jni_clear_exception(env) || array == nullptr) {
        return env->NewStringUTF("");
    }
    env->SetByteArrayRegion(array, 0, length, reinterpret_cast<const jbyte *>(str));
    if (jni_clear_exception(env)) {
        // Calling NewObject with an exception still pending is undefined, and
        // the array it would read from was not filled in anyway.
        env->DeleteLocalRef(array);
        return env->NewStringUTF("");
    }
    const auto result = reinterpret_cast<jstring>(env->NewObject(c_string, m_new_string, array));
    jni_clear_exception(env);
    env->DeleteLocalRef(array);
    if (result == nullptr) {
        return env->NewStringUTF("");
    }
    return result;
}

void jni_attach_thread(scoped_jni *jni) {
    if (global_vm->GetEnv(reinterpret_cast<void **>(&jni->env), JNI_VERSION_1_6) == JNI_OK) {
        jni->require_release = 0;
        return;
    }
    if (global_vm->AttachCurrentThreadAsDaemon(&jni->env, nullptr) != JNI_OK) {
        abort();
    }
    if (detach_key_ready && pthread_setspecific(detach_key, jni->env) == 0) {
        jni->require_release = 0;
        return;
    }
    jni->require_release = 1;
}

void jni_detach_thread(const scoped_jni *env) {
    if (env->require_release) {
        global_vm->DetachCurrentThread();
    }
}

void release_string(char **value) {
    free(*value);
}
