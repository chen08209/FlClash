#include "jni_helper.h"

#include <cstdlib>
#include <cstring>

static JavaVM *global_vm;

static jclass c_string;
static jmethodID m_new_string;
static jmethodID m_get_bytes;

void initialize_jni(JavaVM *vm, JNIEnv *env) {
    global_vm = vm;

    c_string = reinterpret_cast<jclass>(new_global(find_class("java/lang/String")));
    m_new_string = find_method(c_string, "<init>", "([B)V");
    m_get_bytes = find_method(c_string, "getBytes", "()[B");
}

char *jni_get_string(JNIEnv *env, jstring str) {
    if (str == nullptr) {
        return static_cast<char *>(calloc(1, 1));
    }
    const auto array = reinterpret_cast<jbyteArray>(env->CallObjectMethod(str, m_get_bytes));
    const int length = env->GetArrayLength(array);
    const auto content = static_cast<char *>(malloc(length + 1));
    env->GetByteArrayRegion(array, 0, length, reinterpret_cast<jbyte *>(content));
    env->DeleteLocalRef(array);
    content[length] = 0;
    return content;
}

jstring jni_new_string(JNIEnv *env, const char *str) {
    const auto length = static_cast<int>(strlen(str));
    const auto array = env->NewByteArray(length);
    env->SetByteArrayRegion(array, 0, length, reinterpret_cast<const jbyte *>(str));
    const auto result = reinterpret_cast<jstring>(env->NewObject(c_string, m_new_string, array));
    env->DeleteLocalRef(array);
    return result;
}

void jni_attach_thread(scoped_jni *jni) {
    if (global_vm->GetEnv(reinterpret_cast<void **>(&jni->env), JNI_VERSION_1_6) == JNI_OK) {
        jni->require_release = 0;
        return;
    }
    if (global_vm->AttachCurrentThread(&jni->env, nullptr) != JNI_OK) {
        abort();
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
