#include "include/wifi_ssid/wifi_ssid_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "wifi_ssid_plugin.h"

void WifiSsidPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  wifi_ssid::WifiSsidPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
