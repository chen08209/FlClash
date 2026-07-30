#include "window_ext_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <dwmapi.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <sstream>

#ifndef DWMWA_WINDOW_CORNER_PREFERENCE
#define DWMWA_WINDOW_CORNER_PREFERENCE 33
#endif

#ifndef DWMWCP_DONOTROUND
#define DWMWCP_DONOTROUND 1
#endif

#ifndef DWMWCP_ROUND
#define DWMWCP_ROUND 2
#endif

namespace window_ext {


std::unique_ptr<
    flutter::MethodChannel<flutter::EncodableValue>,
    std::default_delete<flutter::MethodChannel<flutter::EncodableValue>>>
    channel = nullptr;


// static
void WindowExtPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "window_ext",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<WindowExtPlugin>(registrar);

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

WindowExtPlugin::WindowExtPlugin(flutter::PluginRegistrarWindows* registrar)
    : registrar(registrar) {
  WM_TASKBARCREATED = RegisterWindowMessage(TEXT("TaskbarCreated"));
  WM_FLCLASH_ACTIVATE =
      RegisterWindowMessage(TEXT("FlClash.ActivateWindow"));
  window_proc_id = registrar->RegisterTopLevelWindowProcDelegate(
      [this](HWND hwnd, UINT message, WPARAM wparam, LPARAM lparam) {
        return HandleWindowProc(hwnd, message, wparam, lparam);
      });
}

WindowExtPlugin::~WindowExtPlugin() {
  registrar->UnregisterTopLevelWindowProcDelegate(window_proc_id);
}

std::optional<LRESULT> WindowExtPlugin::HandleWindowProc(HWND hWnd,
                                                           UINT message,
                                                           WPARAM wParam,
                                                           LPARAM lParam) {
  std::optional<LRESULT> result;
  if(message == WM_TASKBARCREATED){
    channel -> InvokeMethod("taskbarCreated", std::make_unique<flutter::EncodableValue>());
  } else if (message == WM_FLCLASH_ACTIVATE) {
    channel->InvokeMethod("windowActivated",
                          std::make_unique<flutter::EncodableValue>());
  }
  return result;
}



void WindowExtPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name().compare("getPlatformVersion") == 0) {
    std::ostringstream version_stream;
    version_stream << "Windows ";
    if (IsWindows10OrGreater()) {
      version_stream << "10+";
    } else if (IsWindows8OrGreater()) {
      version_stream << "8";
    } else if (IsWindows7OrGreater()) {
      version_stream << "7";
    }
    result->Success(flutter::EncodableValue(version_stream.str()));
  } else if (method_call.method_name().compare("setWindowCornerPreference") == 0) {
    HWND hWnd = ::GetAncestor(registrar->GetView()->GetNativeWindow(), GA_ROOT);
    if (hWnd) {
      const auto *args = std::get_if<flutter::EncodableMap>(method_call.arguments());
      if (args) {
        auto round_it = args->find(flutter::EncodableValue("round"));
        if (round_it != args->end()) {
          bool round = std::get<bool>(round_it->second);
          DWORD preference = round ? DWMWCP_ROUND : DWMWCP_DONOTROUND;
          DwmSetWindowAttribute(hWnd, DWMWA_WINDOW_CORNER_PREFERENCE,
                                &preference, sizeof(preference));
        }
      }
    }
    result->Success();
  } else {
    result->NotImplemented();
  }
}

}  // namespace window_ext
