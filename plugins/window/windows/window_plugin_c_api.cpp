#include "include/window/window_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "running_instance.h"
#include "window_plugin.h"

void WindowPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  window::WindowPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}

HWND WindowPluginFindRunningWindow() {
  return window::FindRunningWindow();
}

void WindowPluginActivateWindow(HWND window) {
  window::ActivateWindow(window);
}
