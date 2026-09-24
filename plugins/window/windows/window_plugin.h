#ifndef FLUTTER_PLUGIN_WINDOW_PLUGIN_H_
#define FLUTTER_PLUGIN_WINDOW_PLUGIN_H_

#include <windows.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <optional>
#include <string>
#include <unordered_map>

#include "window_controller.h"
#include "window_style.h"

namespace window {

class WindowPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

  explicit WindowPlugin(flutter::PluginRegistrarWindows* registrar);
  ~WindowPlugin() override;

  WindowPlugin(const WindowPlugin&) = delete;
  WindowPlugin& operator=(const WindowPlugin&) = delete;

 private:
  using Result = flutter::MethodResult<flutter::EncodableValue>;
  using Handler = void (WindowPlugin::*)(const flutter::EncodableMap* args,
                                         std::unique_ptr<Result> result);

  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& call,
      std::unique_ptr<Result> result);
  std::optional<LRESULT> HandleWindowProc(HWND hwnd, UINT message,
                                          WPARAM wparam, LPARAM lparam);
  void EmitEvent(const std::string& name);
  void BuildHandlerTable();

  void HandleEnsureInitialized(const flutter::EncodableMap* args, std::unique_ptr<Result> result);
  void HandleShow(const flutter::EncodableMap* args, std::unique_ptr<Result> result);
  void HandleHide(const flutter::EncodableMap* args, std::unique_ptr<Result> result);
  void HandleIsVisible(const flutter::EncodableMap* args, std::unique_ptr<Result> result);
  void HandleFocus(const flutter::EncodableMap* args, std::unique_ptr<Result> result);
  void HandleClose(const flutter::EncodableMap* args, std::unique_ptr<Result> result);
  void HandleSetPreventClose(const flutter::EncodableMap* args, std::unique_ptr<Result> result);
  void HandleIsMaximized(const flutter::EncodableMap* args, std::unique_ptr<Result> result);
  void HandleMaximize(const flutter::EncodableMap* args, std::unique_ptr<Result> result);
  void HandleUnmaximize(const flutter::EncodableMap* args, std::unique_ptr<Result> result);
  void HandleIsMinimized(const flutter::EncodableMap* args, std::unique_ptr<Result> result);
  void HandleMinimize(const flutter::EncodableMap* args, std::unique_ptr<Result> result);
  void HandleRestore(const flutter::EncodableMap* args, std::unique_ptr<Result> result);
  void HandleIsFullScreen(const flutter::EncodableMap* args, std::unique_ptr<Result> result);
  void HandleSetFullScreen(const flutter::EncodableMap* args, std::unique_ptr<Result> result);
  void HandleGetBounds(const flutter::EncodableMap* args, std::unique_ptr<Result> result);
  void HandleSetBounds(const flutter::EncodableMap* args, std::unique_ptr<Result> result);
  void HandleIsPositionSupported(const flutter::EncodableMap* args, std::unique_ptr<Result> result);
  void HandleSetMinimumSize(const flutter::EncodableMap* args, std::unique_ptr<Result> result);
  void HandleIsAlwaysOnTop(const flutter::EncodableMap* args, std::unique_ptr<Result> result);
  void HandleSetAlwaysOnTop(const flutter::EncodableMap* args, std::unique_ptr<Result> result);
  void HandleSetTitleBarStyle(const flutter::EncodableMap* args, std::unique_ptr<Result> result);
  void HandleSetSkipTaskbar(const flutter::EncodableMap* args, std::unique_ptr<Result> result);
  void HandleSetRoundedCorners(const flutter::EncodableMap* args, std::unique_ptr<Result> result);
  void HandleIsEffectSupported(const flutter::EncodableMap* args, std::unique_ptr<Result> result);
  void HandleSetEffect(const flutter::EncodableMap* args, std::unique_ptr<Result> result);
  void HandleStartDragging(const flutter::EncodableMap* args, std::unique_ptr<Result> result);

  flutter::PluginRegistrarWindows* registrar_;
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel_;
  std::unordered_map<std::string, Handler> handlers_;

  WindowStyle style_;
  WindowController controller_;

  int window_proc_id_ = -1;
  bool relaunch_messages_allowed_ = false;
};

}  // namespace window

#endif  // FLUTTER_PLUGIN_WINDOW_PLUGIN_H_
