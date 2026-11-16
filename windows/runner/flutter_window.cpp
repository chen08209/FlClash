#include "flutter_window.h"

#include <optional>

#include "flutter/generated_plugin_registrant.h"
#include "rust_api.h"

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project),
      window_message_(RustApiFunction<WindowMessageFunction>(
          "flclash_window_message")) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {

  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    // The engine hides the view only once it is sized to zero, and hiding or
    // minimizing the top-level window never resizes it: rust_api consumes a
    // minimize's WM_SIZE.
    if (message == WM_SHOWWINDOW || message == WM_SIZE) {
      flutter_controller_->engine()->ProcessExternalWindowMessage(
          flutter_controller_->view()->GetNativeWindow(), message, wparam,
          lparam);
    }
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
    LRESULT window_result = 0;
    if (window_message_ != nullptr &&
        window_message_(hwnd, message, wparam, lparam, &window_result)) {
      return window_result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
