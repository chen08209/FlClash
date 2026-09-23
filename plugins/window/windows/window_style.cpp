#include "window_style.h"

#include <dwmapi.h>

namespace window {

namespace {

#ifndef DWMWA_WINDOW_CORNER_PREFERENCE
#define DWMWA_WINDOW_CORNER_PREFERENCE 33
#endif
#ifndef DWMWA_SYSTEMBACKDROP_TYPE
#define DWMWA_SYSTEMBACKDROP_TYPE 38
#endif
#ifndef DWMWA_USE_IMMERSIVE_DARK_MODE
#define DWMWA_USE_IMMERSIVE_DARK_MODE 20
#endif
// The pre-20H1 value of the same attribute.
#define DWMWA_USE_IMMERSIVE_DARK_MODE_BEFORE_20H1 19

enum WindowCornerPreference {
  kDwmwcpDoNotRound = 1,
  kDwmwcpRound = 2,
};

enum SystemBackdropType {
  kDwmsbtNone = 1,
  kDwmsbtMainWindow = 2,
};

enum AccentState {
  kAccentDisabled = 0,
  kAccentEnableTransparentGradient = 2,
  kAccentEnableBlurBehind = 3,
  kAccentEnableAcrylicBlurBehind = 4,
};

struct AccentPolicy {
  int accent_state;
  int accent_flags;
  int gradient_color;
  int animation_id;
};

struct WindowCompositionAttributeData {
  int attribute;
  PVOID data;
  ULONG size_in_bytes;
};

using SetWindowCompositionAttributeFn =
    BOOL(WINAPI*)(HWND, WindowCompositionAttributeData*);

SetWindowCompositionAttributeFn GetSetWindowCompositionAttribute() {
  static const SetWindowCompositionAttributeFn function = [] {
    const HMODULE user32 = ::GetModuleHandleW(L"user32.dll");
    return user32 == nullptr
               ? nullptr
               : reinterpret_cast<SetWindowCompositionAttributeFn>(
                     ::GetProcAddress(user32,
                                     "SetWindowCompositionAttribute"));
  }();
  return function;
}

using RtlGetVersionFn = LONG(WINAPI*)(OSVERSIONINFOW*);

int QueryBuildNumber() {
  const HMODULE ntdll = ::GetModuleHandleW(L"ntdll.dll");
  if (ntdll == nullptr) {
    return 0;
  }
  const auto rtl_get_version = reinterpret_cast<RtlGetVersionFn>(
      ::GetProcAddress(ntdll, "RtlGetVersion"));
  if (rtl_get_version == nullptr) {
    return 0;
  }
  OSVERSIONINFOW info{};
  info.dwOSVersionInfoSize = sizeof(info);
  if (rtl_get_version(&info) != 0) {
    return 0;
  }
  return static_cast<int>(info.dwBuildNumber);
}

// SetWindowCompositionAttribute takes its color as ABGR.
uint32_t ToAccentColor(uint32_t argb) {
  const uint32_t a = (argb >> 24) & 0xFF;
  const uint32_t r = (argb >> 16) & 0xFF;
  const uint32_t g = (argb >> 8) & 0xFF;
  const uint32_t b = argb & 0xFF;
  return (a << 24) | (b << 16) | (g << 8) | r;
}

}  // namespace

std::optional<TitleBarStyle> ParseTitleBarStyle(const std::string& value) {
  if (value == "normal") return TitleBarStyle::kNormal;
  if (value == "hidden") return TitleBarStyle::kHidden;
  return std::nullopt;
}

std::optional<Effect> ParseEffect(const std::string& value) {
  if (value == "none") return Effect::kNone;
  if (value == "transparent") return Effect::kTransparent;
  if (value == "blur") return Effect::kBlur;
  if (value == "acrylic") return Effect::kAcrylic;
  if (value == "mica") return Effect::kMica;
  return std::nullopt;
}

int WindowsBuildNumber() {
  static const int build = QueryBuildNumber();
  return build;
}

bool IsWindows11OrGreater() {
  return WindowsBuildNumber() >= 22000;
}

// The accent effects need the undocumented SetWindowCompositionAttribute,
// which Apply() skips when user32 lacks it; without it they draw nothing.
bool IsEffectSupported(Effect effect) {
  const bool has_accent = GetSetWindowCompositionAttribute() != nullptr;
  switch (effect) {
    case Effect::kNone:
      return true;
    case Effect::kTransparent:
    case Effect::kBlur:
      return has_accent;
    case Effect::kAcrylic:
      return has_accent && WindowsBuildNumber() >= 17134;
    case Effect::kMica:
      return WindowsBuildNumber() >= 22000;
  }
  return false;
}

void WindowStyle::SetTitleBarStyle(TitleBarStyle style,
                                   bool button_visibility, HWND hwnd) {
  title_bar_style = style;
  window_button_visibility = button_visibility;
  Apply(hwnd);
}

void WindowStyle::SetRoundedCorners(bool value, HWND hwnd) {
  rounded_corners = value;
  Apply(hwnd);
}

void WindowStyle::SetEffect(Effect value, uint32_t tint,
                            std::optional<bool> dark, HWND hwnd) {
  effect = value;
  effect_tint = tint;
  dark_mode = dark;
  Apply(hwnd);
}

void WindowStyle::Apply(HWND hwnd) const {
  if (hwnd == nullptr) {
    return;
  }

  int accent_state = kAccentDisabled;
  uint32_t accent_color = 0;
  int backdrop_type = kDwmsbtNone;

  switch (effect) {
    case Effect::kNone:
      break;
    case Effect::kTransparent:
      accent_state = kAccentEnableTransparentGradient;
      accent_color = ToAccentColor(effect_tint);
      break;
    case Effect::kBlur:
      accent_state = kAccentEnableBlurBehind;
      accent_color = ToAccentColor(effect_tint);
      break;
    case Effect::kAcrylic:
      accent_state = kAccentEnableAcrylicBlurBehind;
      accent_color = ToAccentColor(effect_tint);
      break;
    case Effect::kMica:
      backdrop_type = kDwmsbtMainWindow;
      break;
  }

  // Only the system backdrop draws into an extended frame; Windows 11 fills
  // that frame with an opaque material, which would cover an accent effect.
  MARGINS margins = effect == Effect::kMica ? MARGINS{-1, -1, -1, -1}
                                            : MARGINS{0, 0, 0, 0};
  ::DwmExtendFrameIntoClientArea(hwnd, &margins);

  if (rounded_corners.has_value()) {
    const int corner_preference =
        *rounded_corners ? kDwmwcpRound : kDwmwcpDoNotRound;
    ::DwmSetWindowAttribute(hwnd, DWMWA_WINDOW_CORNER_PREFERENCE,
                            &corner_preference, sizeof(corner_preference));
  }

  if (IsWindows11OrGreater()) {
    ::DwmSetWindowAttribute(hwnd, DWMWA_SYSTEMBACKDROP_TYPE, &backdrop_type,
                            sizeof(backdrop_type));
  }

  // The system backdrops pick their light or dark material from this
  // attribute, which also colors the frame border.
  if (dark_mode.has_value() && WindowsBuildNumber() >= 17763) {
    const BOOL dark = *dark_mode ? TRUE : FALSE;
    const DWORD attribute = WindowsBuildNumber() >= 18985
                                ? DWMWA_USE_IMMERSIVE_DARK_MODE
                                : DWMWA_USE_IMMERSIVE_DARK_MODE_BEFORE_20H1;
    ::DwmSetWindowAttribute(hwnd, attribute, &dark, sizeof(dark));
  }

  // WS_SYSMENU also gates WS_MINIMIZEBOX/WS_MAXIMIZEBOX, so clearing it is
  // what hides the caption buttons for a hidden title bar.
  const bool hide_buttons =
      title_bar_style == TitleBarStyle::kHidden && !window_button_visibility;
  LONG_PTR style_bits = ::GetWindowLongPtrW(hwnd, GWL_STYLE);
  style_bits = hide_buttons ? (style_bits & ~WS_SYSMENU)
                            : (style_bits | WS_SYSMENU);
  ::SetWindowLongPtrW(hwnd, GWL_STYLE, style_bits);

  if (const auto set_composition_attribute =
          GetSetWindowCompositionAttribute();
      set_composition_attribute != nullptr) {
    AccentPolicy policy{accent_state, 2, static_cast<int>(accent_color), 0};
    WindowCompositionAttributeData data{19, &policy, sizeof(policy)};
    set_composition_attribute(hwnd, &data);
  }

  ::SetWindowPos(hwnd, nullptr, 0, 0, 0, 0,
                 SWP_NOZORDER | SWP_NOOWNERZORDER | SWP_NOMOVE | SWP_NOSIZE |
                     SWP_NOACTIVATE | SWP_FRAMECHANGED);
}

}  // namespace window
