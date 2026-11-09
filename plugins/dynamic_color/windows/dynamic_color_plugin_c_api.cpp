#include "include/dynamic_color/dynamic_color_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "dynamic_color_plugin.h"

void DynamicColorPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  dynamic_color::DynamicColorPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
