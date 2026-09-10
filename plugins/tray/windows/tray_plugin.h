#ifndef FLUTTER_PLUGIN_TRAY_PLUGIN_INTERNAL_H_
#define FLUTTER_PLUGIN_TRAY_PLUGIN_INTERNAL_H_

#include <windows.h>

#include <shellapi.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <optional>
#include <string>

namespace tray {

class TrayPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

  TrayPlugin(
      flutter::PluginRegistrarWindows* registrar,
      std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel);

  ~TrayPlugin() override;

  TrayPlugin(const TrayPlugin&) = delete;
  TrayPlugin& operator=(const TrayPlugin&) = delete;

 private:
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  bool Show(const flutter::EncodableMap& arguments);
  void Hide();
  bool OpenMenu();
  bool ApplyIcon(bool add);
  void RebuildMenu(HMENU menu, const flutter::EncodableList& items);
  void SendEvent(const char* name, const flutter::EncodableValue& arguments);

  std::optional<LRESULT> HandleWindowProc(HWND window,
                                          UINT message,
                                          WPARAM wparam,
                                          LPARAM lparam);
  HWND MainWindow();

  flutter::PluginRegistrarWindows* registrar_;
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel_;

  NOTIFYICONDATAW icon_data_{};
  HMENU menu_ = nullptr;
  std::wstring tool_tip_;
  bool visible_ = false;

  UINT taskbar_created_message_ = 0;
  int window_proc_id_ = -1;
};

}  // namespace tray

#endif  // FLUTTER_PLUGIN_TRAY_PLUGIN_INTERNAL_H_
