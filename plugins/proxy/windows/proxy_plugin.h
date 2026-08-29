#ifndef FLUTTER_PLUGIN_PROXY_PLUGIN_H_
#define FLUTTER_PLUGIN_PROXY_PLUGIN_H_

#include <windows.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>
#include <optional>

namespace proxy {

class ProxyPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  ProxyPlugin() = default;

  explicit ProxyPlugin(flutter::PluginRegistrarWindows* registrar);

  ~ProxyPlugin() override;

  // Disallow copy and assign.
  ProxyPlugin(const ProxyPlugin&) = delete;
  ProxyPlugin& operator=(const ProxyPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  static bool IsSessionEnding(UINT message, WPARAM wparam);

  std::optional<LRESULT> HandleWindowProc(
      HWND window, UINT message, WPARAM wparam, LPARAM lparam);

 private:
  flutter::PluginRegistrarWindows* registrar_ = nullptr;
  int window_proc_id_ = -1;
  // Whether this process is the one that pointed Windows at a proxy.
  bool proxy_applied_ = false;
};

}  // namespace proxy

#endif  // FLUTTER_PLUGIN_PROXY_PLUGIN_H_
