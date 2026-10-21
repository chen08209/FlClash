cmake_minimum_required(VERSION 3.14)
set(PROJECT_NAME "wifi_ssid")
project(${PROJECT_NAME} LANGUAGES CXX)
cmake_policy(VERSION 3.14...3.25)

set(PLUGIN_NAME "wifi_ssid_plugin")

list(APPEND PLUGIN_SOURCES
  "wifi_ssid_plugin.cpp"
  "wifi_ssid_plugin.h"
)

add_library(${PLUGIN_NAME} SHARED
  "include/wifi_ssid/wifi_ssid_plugin_c_api.h"
  "wifi_ssid_plugin_c_api.cpp"
  ${PLUGIN_SOURCES}
)

apply_standard_settings(${PLUGIN_NAME})
# Below C++20 C++/WinRT includes <experimental/coroutine>, which MSVC 14.50
# (Visual Studio 2026) rejects as an error.
target_compile_features(${PLUGIN_NAME} PRIVATE cxx_std_20)

set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)

target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin WindowsApp)

set(wifi_ssid_bundled_libraries
  ""
  PARENT_SCOPE
)
