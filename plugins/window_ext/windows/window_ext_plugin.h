#ifndef FLUTTER_PLUGIN_WINDOW_EXT_PLUGIN_H_
#define FLUTTER_PLUGIN_WINDOW_EXT_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace window_ext {

class WindowExtPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);


  WindowExtPlugin(flutter::PluginRegistrarWindows *registrar);
  virtual ~WindowExtPlugin();

  // Disallow copy and assign.
  WindowExtPlugin(const WindowExtPlugin&) = delete;
  WindowExtPlugin& operator=(const WindowExtPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  std::optional<LRESULT> HandleWindowProc(
              HWND hwnd,
              UINT message,
              WPARAM wparam,
              LPARAM lparam);

  int window_proc_id = -1;
  UINT WM_TASKBARCREATED = 0;
  flutter::PluginRegistrarWindows *registrar;
};

}  // namespace window_ext

#endif  // FLUTTER_PLUGIN_WINDOW_EXT_PLUGIN_H_
