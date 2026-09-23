cmake_minimum_required(VERSION 3.10)
set(PROJECT_NAME "wifi_ssid")
project(${PROJECT_NAME} LANGUAGES CXX)

set(PLUGIN_NAME "wifi_ssid_plugin")

find_package(PkgConfig REQUIRED)
pkg_check_modules(GIO REQUIRED IMPORTED_TARGET gio-2.0)

add_library(${PLUGIN_NAME} SHARED
  "wifi_ssid_plugin.cc"
)
apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter PkgConfig::GIO)

set(wifi_ssid_bundled_libraries
  ""
  PARENT_SCOPE
)
