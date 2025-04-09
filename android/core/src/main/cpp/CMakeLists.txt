cmake_minimum_required(VERSION 3.22.1)


project("core")


if (NOT "${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
    add_compile_options(-O3)

    add_compile_options(-flto)

    add_compile_options(-g0)

    add_compile_options(-ffunction-sections -fdata-sections)

    add_compile_options(-fno-exceptions -fno-rtti)

    add_link_options(
            -flto
            -Wl,--gc-sections
            -Wl,--strip-all
            -Wl,--exclude-libs=ALL
    )
endif ()
set(LIB_CLASH_PATH "${CMAKE_SOURCE_DIR}/../jniLibs/${ANDROID_ABI}/libclash.so")
if (EXISTS ${LIB_CLASH_PATH})
    message(STATUS "Found libclash.so for ABI ${ANDROID_ABI}")
    add_definitions(-D_LIBCLASH)
    include_directories(${CMAKE_SOURCE_DIR}/../jniLibs/${ANDROID_ABI})
    link_directories(${CMAKE_SOURCE_DIR}/../jniLibs/${ANDROID_ABI})
    add_library(${CMAKE_PROJECT_NAME} SHARED
            jni_helper.cpp
            core.cpp)
    target_link_libraries(${CMAKE_PROJECT_NAME}
            clash)
else ()
    add_library(${CMAKE_PROJECT_NAME} SHARED
            jni_helper.cpp
            core.cpp)
    target_link_libraries(${CMAKE_PROJECT_NAME})
endif ()