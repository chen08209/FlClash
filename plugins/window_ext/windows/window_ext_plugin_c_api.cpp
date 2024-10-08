#include "include/window_ext/window_ext_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "window_ext_plugin.h"

void WindowExtPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  window_ext::WindowExtPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
