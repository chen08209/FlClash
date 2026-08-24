#include "include/tray/tray_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "tray_plugin.h"

void TrayPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  tray::TrayPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
