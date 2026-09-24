cmake_minimum_required(VERSION 3.10)
set(PROJECT_NAME "window")
project(${PROJECT_NAME} LANGUAGES CXX)

set(PLUGIN_NAME "window_plugin")

find_package(PkgConfig REQUIRED)

add_library(${PLUGIN_NAME} SHARED
  "window_plugin.cc"
  "window_geometry.cc"
  "window_style.cc"
  "window_drag.cc"
)
apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter)
target_link_libraries(${PLUGIN_NAME} PRIVATE PkgConfig::GTK)

set(window_bundled_libraries
  ""
  PARENT_SCOPE
)
