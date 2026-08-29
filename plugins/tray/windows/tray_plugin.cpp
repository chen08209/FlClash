#include "tray_plugin.h"

#include <strsafe.h>

#include <variant>

namespace tray {

namespace {

constexpr UINT kTrayCallbackMessage = WM_USER + 1;
constexpr UINT kTrayIconId = 1;

const flutter::EncodableValue* ValueAt(const flutter::EncodableMap& map,
                                       const char* key) {
  const auto it = map.find(flutter::EncodableValue(key));
  return it == map.end() ? nullptr : &(it->second);
}

const std::string* StringAt(const flutter::EncodableMap& map, const char* key) {
  return std::get_if<std::string>(ValueAt(map, key));
}

bool BoolAt(const flutter::EncodableMap& map, const char* key, bool fallback) {
  const auto* value = std::get_if<bool>(ValueAt(map, key));
  return value == nullptr ? fallback : *value;
}

int IntAt(const flutter::EncodableMap& map, const char* key, int fallback) {
  const auto* value = std::get_if<int>(ValueAt(map, key));
  return value == nullptr ? fallback : *value;
}

const flutter::EncodableList* ListAt(const flutter::EncodableMap& map,
                                     const char* key) {
  return std::get_if<flutter::EncodableList>(ValueAt(map, key));
}

const flutter::EncodableMap* MapAt(const flutter::EncodableMap& map,
                                   const char* key) {
  return std::get_if<flutter::EncodableMap>(ValueAt(map, key));
}

std::wstring Utf16FromUtf8(const std::string& value) {
  if (value.empty()) {
    return std::wstring();
  }
  const int size = ::MultiByteToWideChar(
      CP_UTF8, 0, value.data(), static_cast<int>(value.size()), nullptr, 0);
  if (size <= 0) {
    return std::wstring();
  }
  std::wstring result(static_cast<size_t>(size), L'\0');
  ::MultiByteToWideChar(CP_UTF8, 0, value.data(),
                        static_cast<int>(value.size()), result.data(), size);
  return result;
}

}  // namespace

// static
void TrayPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "tray",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<TrayPlugin>(registrar, std::move(channel));
  registrar->AddPlugin(std::move(plugin));
}

TrayPlugin::TrayPlugin(
    flutter::PluginRegistrarWindows* registrar,
    std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel)
    : registrar_(registrar), channel_(std::move(channel)) {
  channel_->SetMethodCallHandler([this](const auto& call, auto result) {
    HandleMethodCall(call, std::move(result));
  });

  window_proc_id_ = registrar_->RegisterTopLevelWindowProcDelegate(
      [this](HWND window, UINT message, WPARAM wparam, LPARAM lparam) {
        return HandleWindowProc(window, message, wparam, lparam);
      });
  taskbar_created_message_ = ::RegisterWindowMessageW(L"TaskbarCreated");
}

TrayPlugin::~TrayPlugin() {
  Hide();
  registrar_->UnregisterTopLevelWindowProcDelegate(window_proc_id_);
}

HWND TrayPlugin::MainWindow() {
  return ::GetAncestor(registrar_->GetView()->GetNativeWindow(), GA_ROOT);
}

void TrayPlugin::SendEvent(const char* name,
                           const flutter::EncodableValue& arguments) {
  channel_->InvokeMethod(name,
                         std::make_unique<flutter::EncodableValue>(arguments));
}

bool TrayPlugin::ApplyIcon(bool add) {
  icon_data_.cbSize = sizeof(NOTIFYICONDATAW);
  icon_data_.hWnd = MainWindow();
  icon_data_.uID = kTrayIconId;
  icon_data_.uCallbackMessage = kTrayCallbackMessage;
  icon_data_.uFlags = NIF_MESSAGE | NIF_ICON | NIF_TIP;
  ::StringCchCopyW(icon_data_.szTip, ARRAYSIZE(icon_data_.szTip),
                   tool_tip_.c_str());

  return ::Shell_NotifyIconW(add ? NIM_ADD : NIM_MODIFY, &icon_data_) != FALSE;
}

void TrayPlugin::RebuildMenu(HMENU menu, const flutter::EncodableList& items) {
  while (::GetMenuItemCount(menu) > 0) {
    ::DeleteMenu(menu, 0, MF_BYPOSITION);
  }

  for (const auto& value : items) {
    const auto* entry = std::get_if<flutter::EncodableMap>(&value);
    if (entry == nullptr) {
      continue;
    }
    const std::string* type = StringAt(*entry, "type");
    if (type == nullptr) {
      continue;
    }

    if (*type == "separator") {
      ::AppendMenuW(menu, MF_SEPARATOR, 0, nullptr);
      continue;
    }

    const std::string* label = StringAt(*entry, "label");
    const std::wstring text = Utf16FromUtf8(label == nullptr ? "" : *label);

    UINT flags = MF_STRING;
    if (!BoolAt(*entry, "enabled", true)) {
      flags |= MF_GRAYED;
    }

    UINT_PTR item_id =
        static_cast<UINT_PTR>(IntAt(*entry, "id", 0));

    if (*type == "checkbox") {
      flags |= BoolAt(*entry, "checked", false) ? MF_CHECKED : MF_UNCHECKED;
    } else if (*type == "submenu") {
      HMENU submenu = ::CreatePopupMenu();
      const flutter::EncodableList* children = ListAt(*entry, "items");
      if (children != nullptr) {
        RebuildMenu(submenu, *children);
      }
      flags |= MF_POPUP;
      item_id = reinterpret_cast<UINT_PTR>(submenu);
    }

    ::AppendMenuW(menu, flags, item_id, text.c_str());
  }
}

bool TrayPlugin::Show(const flutter::EncodableMap& arguments) {
  const flutter::EncodableMap* icon = MapAt(arguments, "icon");
  const std::string* icon_path =
      icon == nullptr ? nullptr : StringAt(*icon, "path");
  if (icon_path == nullptr) {
    return false;
  }

  const HICON loaded = static_cast<HICON>(::LoadImageW(
      nullptr, Utf16FromUtf8(*icon_path).c_str(), IMAGE_ICON,
      ::GetSystemMetrics(SM_CXSMICON), ::GetSystemMetrics(SM_CYSMICON),
      LR_LOADFROMFILE));
  if (loaded == nullptr) {
    return false;
  }
  if (icon_data_.hIcon != nullptr) {
    ::DestroyIcon(icon_data_.hIcon);
  }
  icon_data_.hIcon = loaded;

  const std::string* tool_tip = StringAt(arguments, "toolTip");
  if (tool_tip != nullptr) {
    tool_tip_ = Utf16FromUtf8(*tool_tip);
  }

  bool applied = ApplyIcon(!visible_);
  if (!applied && visible_) {
    applied = ApplyIcon(true);
  }
  if (!applied) {
    return false;
  }
  visible_ = true;

  const flutter::EncodableList* items = ListAt(arguments, "menu");
  if (items != nullptr) {
    if (menu_ == nullptr) {
      menu_ = ::CreatePopupMenu();
    }
    RebuildMenu(menu_, *items);
  }

  return true;
}

void TrayPlugin::Hide() {
  if (visible_) {
    ::Shell_NotifyIconW(NIM_DELETE, &icon_data_);
  }
  if (icon_data_.hIcon != nullptr) {
    ::DestroyIcon(icon_data_.hIcon);
  }
  icon_data_ = NOTIFYICONDATAW{};

  if (menu_ != nullptr) {
    ::DestroyMenu(menu_);
    menu_ = nullptr;
  }

  tool_tip_.clear();
  visible_ = false;
}

bool TrayPlugin::OpenMenu() {
  if (menu_ == nullptr || !visible_) {
    return false;
  }

  const HWND window = MainWindow();
  POINT cursor;
  ::GetCursorPos(&cursor);

  ::SetForegroundWindow(window);
  const int command = ::TrackPopupMenu(
      menu_, TPM_BOTTOMALIGN | TPM_LEFTALIGN | TPM_RETURNCMD | TPM_RIGHTBUTTON,
      cursor.x, cursor.y, 0, window, nullptr);
  ::PostMessageW(window, WM_NULL, 0, 0);

  if (command != 0) {
    flutter::EncodableMap arguments;
    arguments[flutter::EncodableValue("id")] = flutter::EncodableValue(command);
    SendEvent("onMenuItemSelected", flutter::EncodableValue(arguments));
  }
  return true;
}

std::optional<LRESULT> TrayPlugin::HandleWindowProc(HWND window,
                                                    UINT message,
                                                    WPARAM wparam,
                                                    LPARAM lparam) {
  if (message == WM_DESTROY) {
    Hide();
    return std::nullopt;
  }

  if (message == kTrayCallbackMessage) {
    if (lparam == WM_LBUTTONUP) {
      SendEvent("onIconActivated", flutter::EncodableValue());
    } else if (lparam == WM_RBUTTONUP) {
      SendEvent("onMenuRequested", flutter::EncodableValue());
    }
    return std::nullopt;
  }

  const bool should_restore =
      (taskbar_created_message_ != 0 && message == taskbar_created_message_) ||
      (message == WM_POWERBROADCAST && (wparam == PBT_APMRESUMEAUTOMATIC ||
                                        wparam == PBT_APMRESUMESUSPEND));
  if (should_restore && visible_) {
    ApplyIcon(true);
  }

  return std::nullopt;
}

void TrayPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  const std::string& method = method_call.method_name();

  if (method == "show") {
    const auto* arguments =
        std::get_if<flutter::EncodableMap>(method_call.arguments());
    result->Success(flutter::EncodableValue(
        arguments != nullptr && Show(*arguments)));
    return;
  }

  if (method == "hide") {
    Hide();
    result->Success(flutter::EncodableValue(true));
    return;
  }

  if (method == "openMenu") {
    result->Success(flutter::EncodableValue(OpenMenu()));
    return;
  }

  if (method == "setTitle") {
    result->Success(flutter::EncodableValue(false));
    return;
  }

  result->NotImplemented();
}

}  // namespace tray
