cmake_minimum_required(VERSION 3.22.1)

project("core")

message("CMAKE_SOURCE_DIR ${CMAKE_SOURCE_DIR}")

message("CMAKE_BUILD_TYPE ${CMAKE_BUILD_TYPE}")


if (NOT "${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
    add_compile_options(-O3 -flto -g0 -fno-exceptions -fno-rtti)
    add_link_options(-flto -Wl,--gc-sections,--strip-all)
endif ()

set(LIB_CLASH_INCLUDE_DIR "${CMAKE_SOURCE_DIR}/../cpp/includes/${ANDROID_ABI}")

# Never make linking libclash conditional on the file existing: AGP's configure
# fingerprint tracks only CMakeLists.txt, so a configure that ran before the build
# hook would stay cached and silently drop the Core. Failing at compile or link
# time is what keeps that decision out of the configure step.
include_directories(${LIB_CLASH_INCLUDE_DIR})
link_directories(${CMAKE_SOURCE_DIR}/../jniLibs/${ANDROID_ABI})
add_library(${CMAKE_PROJECT_NAME} SHARED
        jni_helper.cpp
        core.cpp)
target_link_libraries(${CMAKE_PROJECT_NAME}
        clash)
