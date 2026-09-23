#include "window_plugin.h"

#include <cstdint>
#include <variant>

#include "running_instance.h"

namespace window {

namespace {

std::optional<bool> GetBool(const flutter::EncodableMap* args,
                            const char* key) {
  if (args == nullptr) return std::nullopt;
  const auto it = args->find(flutter::EncodableValue(key));
  if (it == args->end()) return std::nullopt;
  const auto* value = std::get_if<bool>(&it->second);
  return value == nullptr ? std::nullopt : std::optional<bool>(*value);
}

std::optional<double> GetDouble(const flutter::EncodableMap* args,
                                const char* key) {
  if (args == nullptr) return std::nullopt;
  const auto it = args->find(flutter::EncodableValue(key));
  if (it == args->end()) return std::nullopt;
  const auto* value = std::get_if<double>(&it->second);
  return value == nullptr ? std::nullopt : std::optional<double>(*value);
}

std::optional<int64_t> GetInt(const flutter::EncodableMap* args,
                              const char* key) {
  if (args == nullptr) return std::nullopt;
  const auto it = args->find(flutter::EncodableValue(key));
  if (it == args->end()) return std::nullopt;
  if (const auto* value32 = std::get_if<int32_t>(&it->second)) {
    return static_cast<int64_t>(*value32);
  }
  if (const auto* value64 = std::get_if<int64_t>(&it->second)) {
    return *value64;
  }
  return std::nullopt;
}

std::optional<std::string> GetString(const flutter::EncodableMap* args,
                                     const char* key) {
  if (args == nullptr) return std::nullopt;
  const auto it = args->find(flutter::EncodableValue(key));
  if (it == args->end()) return std::nullopt;
  const auto* value = std::get_if<std::string>(&it->second);
  return value == nullptr ? std::nullopt : std::optional<std::string>(*value);
}

}  // namespace

void WindowPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto plugin = std::make_unique<WindowPlugin>(registrar);
  registrar->AddPlugin(std::move(plugin));
}

WindowPlugin::WindowPlugin(flutter::PluginRegistrarWindows* registrar)
    : registrar_(registrar),
      controller_([this](const std::string& name) { EmitEvent(name); }) {
  controller_.SetStyle(&style_);
  BuildHandlerTable();

  channel_ = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      registrar_->messenger(), "window",
      &flutter::StandardMethodCodec::GetInstance());
  channel_->SetMethodCallHandler([this](const auto& call, auto result) {
    HandleMethodCall(call, std::move(result));
  });

  window_proc_id_ = registrar_->RegisterTopLevelWindowProcDelegate(
      [this](HWND hwnd, UINT message, WPARAM wparam, LPARAM lparam) {
        return HandleWindowProc(hwnd, message, wparam, lparam);
      });

  const HWND root =
      ::GetAncestor(registrar_->GetView()->GetNativeWindow(), GA_ROOT);
  AllowActivateMessageThroughUipi(root);
}

WindowPlugin::~WindowPlugin() {
  registrar_->UnregisterTopLevelWindowProcDelegate(window_proc_id_);
}

void WindowPlugin::EmitEvent(const std::string& name) {
  if (channel_ == nullptr) return;
  flutter::EncodableMap args;
  args[flutter::EncodableValue("name")] = flutter::EncodableValue(name);
  channel_->InvokeMethod("onEvent",
                         std::make_unique<flutter::EncodableValue>(args));
}

std::optional<LRESULT> WindowPlugin::HandleWindowProc(HWND hwnd,
                                                       UINT message,
                                                       WPARAM wparam,
                                                       LPARAM lparam) {
  return controller_.HandleWindowMessage(hwnd, message, wparam, lparam);
}

void WindowPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& call,
    std::unique_ptr<Result> result) {
  const auto it = handlers_.find(call.method_name());
  if (it == handlers_.end()) {
    result->NotImplemented();
    return;
  }
  const auto* args = std::get_if<flutter::EncodableMap>(call.arguments());
  (this->*(it->second))(args, std::move(result));
}

void WindowPlugin::BuildHandlerTable() {
  handlers_["ensureInitialized"] = &WindowPlugin::HandleEnsureInitialized;
  handlers_["show"] = &WindowPlugin::HandleShow;
  handlers_["hide"] = &WindowPlugin::HandleHide;
  handlers_["isVisible"] = &WindowPlugin::HandleIsVisible;
  handlers_["focus"] = &WindowPlugin::HandleFocus;
  handlers_["close"] = &WindowPlugin::HandleClose;
  handlers_["setPreventClose"] = &WindowPlugin::HandleSetPreventClose;
  handlers_["isMaximized"] = &WindowPlugin::HandleIsMaximized;
  handlers_["maximize"] = &WindowPlugin::HandleMaximize;
  handlers_["unmaximize"] = &WindowPlugin::HandleUnmaximize;
  handlers_["isMinimized"] = &WindowPlugin::HandleIsMinimized;
  handlers_["minimize"] = &WindowPlugin::HandleMinimize;
  handlers_["restore"] = &WindowPlugin::HandleRestore;
  handlers_["isFullScreen"] = &WindowPlugin::HandleIsFullScreen;
  handlers_["setFullScreen"] = &WindowPlugin::HandleSetFullScreen;
  handlers_["getBounds"] = &WindowPlugin::HandleGetBounds;
  handlers_["setBounds"] = &WindowPlugin::HandleSetBounds;
  handlers_["isPositionSupported"] = &WindowPlugin::HandleIsPositionSupported;
  handlers_["setMinimumSize"] = &WindowPlugin::HandleSetMinimumSize;
  handlers_["isAlwaysOnTop"] = &WindowPlugin::HandleIsAlwaysOnTop;
  handlers_["setAlwaysOnTop"] = &WindowPlugin::HandleSetAlwaysOnTop;
  handlers_["setTitleBarStyle"] = &WindowPlugin::HandleSetTitleBarStyle;
  handlers_["setSkipTaskbar"] = &WindowPlugin::HandleSetSkipTaskbar;
  handlers_["setRoundedCorners"] = &WindowPlugin::HandleSetRoundedCorners;
  handlers_["isEffectSupported"] = &WindowPlugin::HandleIsEffectSupported;
  handlers_["setEffect"] = &WindowPlugin::HandleSetEffect;
  handlers_["startDragging"] = &WindowPlugin::HandleStartDragging;
}

void WindowPlugin::HandleEnsureInitialized(const flutter::EncodableMap*,
                                           std::unique_ptr<Result> result) {
  const HWND root =
      ::GetAncestor(registrar_->GetView()->GetNativeWindow(), GA_ROOT);
  controller_.Initialize(root);
  result->Success();
}

void WindowPlugin::HandleShow(const flutter::EncodableMap* args,
                              std::unique_ptr<Result> result) {
  const auto inactive = GetBool(args, "inactive");
  if (!inactive.has_value()) {
    result->Error("bad_args", "show: inactive");
    return;
  }
  controller_.Show(*inactive);
  result->Success();
}

void WindowPlugin::HandleHide(const flutter::EncodableMap*,
                              std::unique_ptr<Result> result) {
  controller_.Hide();
  result->Success();
}

void WindowPlugin::HandleIsVisible(const flutter::EncodableMap*,
                                   std::unique_ptr<Result> result) {
  result->Success(flutter::EncodableValue(controller_.IsVisible()));
}

void WindowPlugin::HandleFocus(const flutter::EncodableMap*,
                               std::unique_ptr<Result> result) {
  controller_.Focus();
  result->Success();
}

void WindowPlugin::HandleClose(const flutter::EncodableMap*,
                               std::unique_ptr<Result> result) {
  controller_.Close();
  result->Success();
}

void WindowPlugin::HandleSetPreventClose(const flutter::EncodableMap* args,
                                         std::unique_ptr<Result> result) {
  const auto value = GetBool(args, "value");
  if (!value.has_value()) {
    result->Error("bad_args", "setPreventClose: value");
    return;
  }
  controller_.SetPreventClose(*value);
  result->Success();
}

void WindowPlugin::HandleIsMaximized(const flutter::EncodableMap*,
                                     std::unique_ptr<Result> result) {
  result->Success(flutter::EncodableValue(controller_.IsMaximized()));
}

void WindowPlugin::HandleMaximize(const flutter::EncodableMap*,
                                  std::unique_ptr<Result> result) {
  controller_.Maximize();
  result->Success();
}

void WindowPlugin::HandleUnmaximize(const flutter::EncodableMap*,
                                    std::unique_ptr<Result> result) {
  controller_.Unmaximize();
  result->Success();
}

void WindowPlugin::HandleIsMinimized(const flutter::EncodableMap*,
                                     std::unique_ptr<Result> result) {
  result->Success(flutter::EncodableValue(controller_.IsMinimized()));
}

void WindowPlugin::HandleMinimize(const flutter::EncodableMap*,
                                  std::unique_ptr<Result> result) {
  controller_.Minimize();
  result->Success();
}

void WindowPlugin::HandleRestore(const flutter::EncodableMap*,
                                 std::unique_ptr<Result> result) {
  controller_.Restore();
  result->Success();
}

void WindowPlugin::HandleIsFullScreen(const flutter::EncodableMap*,
                                      std::unique_ptr<Result> result) {
  result->Success(flutter::EncodableValue(controller_.IsFullScreen()));
}

void WindowPlugin::HandleSetFullScreen(const flutter::EncodableMap* args,
                                       std::unique_ptr<Result> result) {
  const auto value = GetBool(args, "value");
  if (!value.has_value()) {
    result->Error("bad_args", "setFullScreen: value");
    return;
  }
  controller_.SetFullScreen(*value);
  result->Success();
}

void WindowPlugin::HandleGetBounds(const flutter::EncodableMap*,
                                   std::unique_ptr<Result> result) {
  const WindowBounds bounds = controller_.GetBounds();
  flutter::EncodableMap value;
  value[flutter::EncodableValue("x")] = flutter::EncodableValue(bounds.x);
  value[flutter::EncodableValue("y")] = flutter::EncodableValue(bounds.y);
  value[flutter::EncodableValue("width")] =
      flutter::EncodableValue(bounds.width);
  value[flutter::EncodableValue("height")] =
      flutter::EncodableValue(bounds.height);
  result->Success(flutter::EncodableValue(value));
}

void WindowPlugin::HandleSetBounds(const flutter::EncodableMap* args,
                                   std::unique_ptr<Result> result) {
  controller_.SetBounds(GetDouble(args, "x"), GetDouble(args, "y"),
                        GetDouble(args, "width"), GetDouble(args, "height"));
  result->Success();
}

void WindowPlugin::HandleIsPositionSupported(const flutter::EncodableMap*,
                                             std::unique_ptr<Result> result) {
  result->Success(flutter::EncodableValue(true));
}

void WindowPlugin::HandleSetMinimumSize(const flutter::EncodableMap* args,
                                        std::unique_ptr<Result> result) {
  const auto width = GetDouble(args, "width");
  const auto height = GetDouble(args, "height");
  if (!width.has_value() || !height.has_value()) {
    result->Error("bad_args", "setMinimumSize: width/height");
    return;
  }
  controller_.SetMinimumSize(*width, *height);
  result->Success();
}

void WindowPlugin::HandleIsAlwaysOnTop(const flutter::EncodableMap*,
                                       std::unique_ptr<Result> result) {
  result->Success(flutter::EncodableValue(controller_.IsAlwaysOnTop()));
}

void WindowPlugin::HandleSetAlwaysOnTop(const flutter::EncodableMap* args,
                                        std::unique_ptr<Result> result) {
  const auto value = GetBool(args, "value");
  if (!value.has_value()) {
    result->Error("bad_args", "setAlwaysOnTop: value");
    return;
  }
  controller_.SetAlwaysOnTop(*value);
  result->Success();
}

void WindowPlugin::HandleSetTitleBarStyle(const flutter::EncodableMap* args,
                                          std::unique_ptr<Result> result) {
  const auto style_name = GetString(args, "style");
  const auto button_visibility = GetBool(args, "windowButtonVisibility");
  if (!style_name.has_value() || !button_visibility.has_value()) {
    result->Error("bad_args",
                  "setTitleBarStyle: style/windowButtonVisibility");
    return;
  }
  const auto style = ParseTitleBarStyle(*style_name);
  if (!style.has_value()) {
    result->Error("bad_args", "setTitleBarStyle: style");
    return;
  }
  style_.SetTitleBarStyle(*style, *button_visibility, controller_.GetWindow());
  result->Success();
}

void WindowPlugin::HandleSetSkipTaskbar(const flutter::EncodableMap* args,
                                        std::unique_ptr<Result> result) {
  const auto value = GetBool(args, "value");
  if (!value.has_value()) {
    result->Error("bad_args", "setSkipTaskbar: value");
    return;
  }
  controller_.SetSkipTaskbar(*value);
  result->Success();
}

void WindowPlugin::HandleSetRoundedCorners(const flutter::EncodableMap* args,
                                           std::unique_ptr<Result> result) {
  const auto value = GetBool(args, "value");
  if (!value.has_value()) {
    result->Error("bad_args", "setRoundedCorners: value");
    return;
  }
  style_.SetRoundedCorners(*value, controller_.GetWindow());
  result->Success();
}

void WindowPlugin::HandleIsEffectSupported(const flutter::EncodableMap* args,
                                           std::unique_ptr<Result> result) {
  const auto effect_name = GetString(args, "effect");
  if (!effect_name.has_value()) {
    result->Error("bad_args", "isEffectSupported: effect");
    return;
  }
  const auto effect = ParseEffect(*effect_name);
  if (!effect.has_value()) {
    result->Error("bad_args", "isEffectSupported: effect");
    return;
  }
  result->Success(flutter::EncodableValue(IsEffectSupported(*effect)));
}

void WindowPlugin::HandleSetEffect(const flutter::EncodableMap* args,
                                   std::unique_ptr<Result> result) {
  const auto effect_name = GetString(args, "effect");
  if (!effect_name.has_value()) {
    result->Error("bad_args", "setEffect: effect");
    return;
  }
  const auto effect = ParseEffect(*effect_name);
  if (!effect.has_value()) {
    result->Error("bad_args", "setEffect: effect");
    return;
  }
  if (!IsEffectSupported(*effect)) {
    result->Error("unsupported", "setEffect: " + *effect_name);
    return;
  }
  const uint32_t tint =
      static_cast<uint32_t>(GetInt(args, "tint").value_or(0));
  std::optional<bool> dark;
  if (const auto brightness = GetString(args, "brightness");
      brightness.has_value()) {
    if (*brightness != "light" && *brightness != "dark") {
      result->Error("bad_args", "setEffect: brightness");
      return;
    }
    dark = *brightness == "dark";
  }
  style_.SetEffect(*effect, tint, dark, controller_.GetWindow());
  result->Success();
}

void WindowPlugin::HandleStartDragging(const flutter::EncodableMap*,
                                       std::unique_ptr<Result> result) {
  controller_.StartDragging();
  result->Success();
}

}  // namespace window
