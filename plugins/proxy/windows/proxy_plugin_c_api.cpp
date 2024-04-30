#include "include/proxy/proxy_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "proxy_plugin.h"

void ProxyPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  proxy::ProxyPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
