#ifndef FLUTTER_PLUGIN_WIFI_SSID_PLUGIN_H_
#define FLUTTER_PLUGIN_WIFI_SSID_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>

namespace wifi_ssid {

class WifiSsidPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(
      flutter::PluginRegistrarWindows *registrar);

  WifiSsidPlugin();
  ~WifiSsidPlugin() override;

  WifiSsidPlugin(const WifiSsidPlugin &) = delete;
  WifiSsidPlugin &operator=(const WifiSsidPlugin &) = delete;

 private:
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  void GetSsid(
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

};

}  // namespace wifi_ssid

#endif  // FLUTTER_PLUGIN_WIFI_SSID_PLUGIN_H_
