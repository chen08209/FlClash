cmake_minimum_required(VERSION 3.22.1)

project("core")

message("CMAKE_SOURCE_DIR ${CMAKE_SOURCE_DIR}")

message("CMAKE_BUILD_TYPE ${CMAKE_BUILD_TYPE}")


if (NOT "${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
    add_compile_options(-O3 -flto -g0 -fno-exceptions -fno-rtti)
    add_link_options(-flto -Wl,--gc-sections,--strip-all)
endif ()

set(LIB_CLASH_PATH "${CMAKE_SOURCE_DIR}/../jniLibs/${ANDROID_ABI}/libclash.so")

message("LIB_CLASH_PATH ${LIB_CLASH_PATH}")
if (EXISTS ${LIB_CLASH_PATH})
    message("Found libclash.so for ABI ${ANDROID_ABI}")
    add_compile_definitions(LIBCLASH)
    include_directories(${CMAKE_SOURCE_DIR}/../cpp/includes/${ANDROID_ABI})
    link_directories(${CMAKE_SOURCE_DIR}/../jniLibs/${ANDROID_ABI})
    add_library(${CMAKE_PROJECT_NAME} SHARED
            jni_helper.cpp
            core.cpp)
    target_link_libraries(${CMAKE_PROJECT_NAME}
            clash)
else ()
    message("Not found libclash.so for ABI ${ANDROID_ABI}")
    add_library(${CMAKE_PROJECT_NAME} SHARED
            jni_helper.cpp
            core.cpp)
    target_link_libraries(${CMAKE_PROJECT_NAME})
endif ()