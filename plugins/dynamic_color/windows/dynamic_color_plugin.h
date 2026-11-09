#ifndef FLUTTER_PLUGIN_DYNAMIC_COLOR_PLUGIN_H_
#define FLUTTER_PLUGIN_DYNAMIC_COLOR_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace dynamic_color {

class DynamicColorPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  DynamicColorPlugin();

  virtual ~DynamicColorPlugin();

  // Disallow copy and assign.
  DynamicColorPlugin(const DynamicColorPlugin&) = delete;
  DynamicColorPlugin& operator=(const DynamicColorPlugin&) = delete;

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace dynamic_color

#endif  // FLUTTER_PLUGIN_DYNAMIC_COLOR_PLUGIN_H_
