cmake_minimum_required(VERSION 3.14)
set(PROJECT_NAME "tray")
project(${PROJECT_NAME} LANGUAGES CXX)
cmake_policy(VERSION 3.14...3.25)

set(PLUGIN_NAME "tray_plugin")

list(APPEND PLUGIN_SOURCES
  "tray_plugin.cpp"
  "tray_plugin.h"
)

add_library(${PLUGIN_NAME} SHARED
  "include/tray/tray_plugin_c_api.h"
  "tray_plugin_c_api.cpp"
  ${PLUGIN_SOURCES}
)

apply_standard_settings(${PLUGIN_NAME})

set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)

target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin)

set(tray_bundled_libraries
  ""
  PARENT_SCOPE
)
