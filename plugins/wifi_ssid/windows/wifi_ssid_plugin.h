#ifndef FLUTTER_PLUGIN_WIFI_SSID_PLUGIN_H_
#define FLUTTER_PLUGIN_WIFI_SSID_PLUGIN_H_

#include <windows.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <optional>

namespace wifi_ssid {

class WifiSsidPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(
      flutter::PluginRegistrarWindows *registrar);

  explicit WifiSsidPlugin(flutter::PluginRegistrarWindows *registrar);
  ~WifiSsidPlugin() override;

  WifiSsidPlugin(const WifiSsidPlugin &) = delete;
  WifiSsidPlugin &operator=(const WifiSsidPlugin &) = delete;

 private:
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  void GetSsid(
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  void RequestPermission(
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  void FinishPermissionRequest();

  std::optional<LRESULT> HandleWindowProc(HWND window, UINT message,
                                          WPARAM wparam, LPARAM lparam);

  flutter::PluginRegistrarWindows *registrar_;
  int window_proc_id_ = -1;
  std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>
      pending_permission_request_;
};

}  // namespace wifi_ssid

#endif  // FLUTTER_PLUGIN_WIFI_SSID_PLUGIN_H_
