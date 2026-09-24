#include "window_controller.h"

#include "running_instance.h"

namespace window {

namespace {

constexpr UINT_PTR kGeometryTimerId = 0x57494E47;  // "WING"
constexpr UINT kGeometrySettleMilliseconds = 150;

}  // namespace

WindowController::WindowController(EventEmitter emit_event)
    : emit_event_(std::move(emit_event)) {}

WindowController::~WindowController() {
  if (hwnd_ != nullptr && ::IsWindow(hwnd_)) {
    ::KillTimer(hwnd_, kGeometryTimerId);
  }
  if (taskbar_ != nullptr) {
    taskbar_->Release();
    taskbar_ = nullptr;
  }
}

void WindowController::Initialize(HWND hwnd) {
  if (hwnd_ == hwnd) {
    return;
  }
  hwnd_ = hwnd;
  GetTaskbarList();
  ::ShowWindow(hwnd_, SW_HIDE);
}

double WindowController::DpiScale() const {
  if (hwnd_ == nullptr) {
    return 1.0;
  }
  return ::GetDpiForWindow(hwnd_) / static_cast<double>(USER_DEFAULT_SCREEN_DPI);
}

ITaskbarList3* WindowController::GetTaskbarList() {
  if (taskbar_ == nullptr) {
    ::CoCreateInstance(CLSID_TaskbarList, nullptr, CLSCTX_INPROC_SERVER,
                       IID_PPV_ARGS(&taskbar_));
    if (taskbar_ != nullptr) {
      taskbar_->HrInit();
    }
  }
  return taskbar_;
}

void WindowController::Show(bool inactive) {
  if (hwnd_ == nullptr) {
    return;
  }
  ::ShowWindow(hwnd_, inactive ? SW_SHOWNOACTIVATE : SW_SHOW);
  if (!inactive) {
    ::SetForegroundWindow(hwnd_);
  }
}

void WindowController::Hide() {
  if (hwnd_ != nullptr) {
    ::ShowWindow(hwnd_, SW_HIDE);
  }
}

bool WindowController::IsVisible() const {
  return hwnd_ != nullptr && ::IsWindowVisible(hwnd_) != FALSE;
}

void WindowController::Focus() {
  if (hwnd_ == nullptr) {
    return;
  }
  if (IsMinimized()) {
    Restore();
  }
  ::SetWindowPos(hwnd_, HWND_TOP, 0, 0, 0, 0, SWP_NOSIZE | SWP_NOMOVE);
  ::SetForegroundWindow(hwnd_);
}

void WindowController::Close() {
  if (hwnd_ != nullptr) {
    ::PostMessageW(hwnd_, WM_SYSCOMMAND, SC_CLOSE, 0);
  }
}

bool WindowController::IsMaximized() const {
  if (hwnd_ == nullptr) {
    return false;
  }
  WINDOWPLACEMENT placement{sizeof(WINDOWPLACEMENT)};
  ::GetWindowPlacement(hwnd_, &placement);
  return placement.showCmd == SW_MAXIMIZE;
}

void WindowController::Maximize() {
  if (hwnd_ != nullptr && !IsMaximized()) {
    ::PostMessageW(hwnd_, WM_SYSCOMMAND, SC_MAXIMIZE, 0);
  }
}

void WindowController::Unmaximize() {
  if (hwnd_ != nullptr && IsMaximized()) {
    ::PostMessageW(hwnd_, WM_SYSCOMMAND, SC_RESTORE, 0);
  }
}

bool WindowController::IsMinimized() const {
  if (hwnd_ == nullptr) {
    return false;
  }
  WINDOWPLACEMENT placement{sizeof(WINDOWPLACEMENT)};
  ::GetWindowPlacement(hwnd_, &placement);
  return placement.showCmd == SW_SHOWMINIMIZED;
}

void WindowController::Minimize() {
  if (hwnd_ == nullptr || is_fullscreen_ || IsMinimized()) {
    return;
  }
  ::PostMessageW(hwnd_, WM_SYSCOMMAND, SC_MINIMIZE, 0);
}

void WindowController::Restore() {
  if (hwnd_ == nullptr) {
    return;
  }
  WINDOWPLACEMENT placement{sizeof(WINDOWPLACEMENT)};
  ::GetWindowPlacement(hwnd_, &placement);
  if (placement.showCmd != SW_NORMAL) {
    ::PostMessageW(hwnd_, WM_SYSCOMMAND, SC_RESTORE, 0);
  }
}

void WindowController::SetFullScreen(bool value) {
  if (hwnd_ == nullptr || value == is_fullscreen_) {
    return;
  }

  if (value) {
    fullscreen_saved_.maximized = ::IsZoomed(hwnd_);
    fullscreen_saved_.style = ::GetWindowLongW(hwnd_, GWL_STYLE);
    ::GetWindowRect(hwnd_, &fullscreen_saved_.frame);
    is_fullscreen_ = true;
    last_state_ = WindowState::kNormal;

    MONITORINFO monitor_info{sizeof(MONITORINFO)};
    ::GetMonitorInfo(::MonitorFromWindow(hwnd_, MONITOR_DEFAULTTONEAREST),
                     &monitor_info);
    ::SetWindowLongPtrW(
        hwnd_, GWL_STYLE,
        fullscreen_saved_.style & ~(WS_THICKFRAME | WS_MAXIMIZEBOX));
    ::SetWindowPos(hwnd_, HWND_TOP, monitor_info.rcMonitor.left,
                   monitor_info.rcMonitor.top, 0, 0,
                   SWP_NOSIZE | SWP_NOOWNERZORDER | SWP_FRAMECHANGED);
    ::SetWindowPos(hwnd_, HWND_TOP, 0, 0,
                   monitor_info.rcMonitor.right - monitor_info.rcMonitor.left,
                   monitor_info.rcMonitor.bottom - monitor_info.rcMonitor.top,
                   SWP_NOMOVE | SWP_NOOWNERZORDER | SWP_FRAMECHANGED);
    emit_event_("enter-full-screen");
    return;
  }

  is_fullscreen_ = false;
  ::SetWindowLongPtrW(
      hwnd_, GWL_STYLE,
      fullscreen_saved_.style | (WS_THICKFRAME | WS_MAXIMIZEBOX));
  if (::IsZoomed(hwnd_)) {
    ::SetWindowPos(hwnd_, nullptr, 0, 0, 0, 0,
                   SWP_NOACTIVATE | SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER |
                       SWP_FRAMECHANGED);
    if (fullscreen_saved_.maximized) {
      ::PostMessageW(hwnd_, WM_SYSCOMMAND, SC_MAXIMIZE, 0);
    }
  } else {
    ::SetWindowPos(hwnd_, nullptr, fullscreen_saved_.frame.left,
                   fullscreen_saved_.frame.top,
                   fullscreen_saved_.frame.right - fullscreen_saved_.frame.left,
                   fullscreen_saved_.frame.bottom - fullscreen_saved_.frame.top,
                   SWP_NOACTIVATE | SWP_NOZORDER);
  }
  if (style_ != nullptr) {
    style_->Apply(hwnd_);
  }
  emit_event_("leave-full-screen");
}

WindowBounds WindowController::GetBounds() const {
  WindowBounds bounds{};
  RECT rect{};
  if (hwnd_ != nullptr && ::GetWindowRect(hwnd_, &rect)) {
    const double scale = DpiScale();
    bounds.x = rect.left / scale;
    bounds.y = rect.top / scale;
    bounds.width = (rect.right - rect.left) / scale;
    bounds.height = (rect.bottom - rect.top) / scale;
  }
  return bounds;
}

void WindowController::SetBounds(std::optional<double> x,
                                 std::optional<double> y,
                                 std::optional<double> width,
                                 std::optional<double> height) {
  if (hwnd_ == nullptr) {
    return;
  }
  const double scale = DpiScale();
  int ix = 0;
  int iy = 0;
  int iw = 0;
  int ih = 0;
  UINT flags = SWP_NOZORDER | SWP_NOACTIVATE;
  if (x.has_value() && y.has_value()) {
    ix = static_cast<int>(*x * scale);
    iy = static_cast<int>(*y * scale);
  } else {
    flags |= SWP_NOMOVE;
  }
  if (width.has_value() && height.has_value()) {
    iw = static_cast<int>(*width * scale);
    ih = static_cast<int>(*height * scale);
  } else {
    flags |= SWP_NOSIZE;
  }
  ::SetWindowPos(hwnd_, nullptr, ix, iy, iw, ih, flags);
}

void WindowController::SetMinimumSize(double width, double height) {
  minimum_size_ = (width >= 0 && height >= 0)
                      ? POINT{static_cast<LONG>(width),
                             static_cast<LONG>(height)}
                      : POINT{0, 0};
}

bool WindowController::IsAlwaysOnTop() const {
  return hwnd_ != nullptr &&
        (::GetWindowLongW(hwnd_, GWL_EXSTYLE) & WS_EX_TOPMOST) != 0;
}

void WindowController::SetAlwaysOnTop(bool value) {
  if (hwnd_ != nullptr) {
    ::SetWindowPos(hwnd_, value ? HWND_TOPMOST : HWND_NOTOPMOST, 0, 0, 0, 0,
                   SWP_NOMOVE | SWP_NOSIZE);
  }
}

void WindowController::SetSkipTaskbar(bool value) {
  if (hwnd_ == nullptr) {
    return;
  }
  ITaskbarList3* taskbar = GetTaskbarList();
  if (taskbar == nullptr) {
    return;
  }
  if (value) {
    taskbar->DeleteTab(hwnd_);
  } else {
    taskbar->AddTab(hwnd_);
  }
}

void WindowController::StartDragging() {
  if (hwnd_ == nullptr) {
    return;
  }
  ::ReleaseCapture();
  ::SendMessageW(hwnd_, WM_SYSCOMMAND, SC_MOVE | HTCAPTION, 0);
}

std::optional<LRESULT> WindowController::HandleWindowMessage(
    HWND hwnd, UINT message, WPARAM wparam, LPARAM lparam) {
  if (wparam && message == WM_NCCALCSIZE) {
    const bool title_bar_hidden =
        style_ != nullptr && style_->title_bar_style == TitleBarStyle::kHidden;
    if (!title_bar_hidden) {
      return std::nullopt;
    }
    if (is_fullscreen_) {
      return 0;
    }
    // The insets come from the window's styles rather than DefWindowProc, so
    // they do not hinge on what it returns for the runner's window class.
    // Maximized windows hang past the monitor edge by one frame width.
    RECT frame{};
    ::AdjustWindowRectExForDpi(
        &frame, static_cast<DWORD>(::GetWindowLongPtrW(hwnd, GWL_STYLE)), FALSE,
        static_cast<DWORD>(::GetWindowLongPtrW(hwnd, GWL_EXSTYLE)),
        ::GetDpiForWindow(hwnd));
    RECT* rect = &reinterpret_cast<NCCALCSIZE_PARAMS*>(lparam)->rgrc[0];
    rect->left -= frame.left;
    rect->right -= frame.right;
    rect->bottom -= frame.bottom;
    // Windows 11 draws the top border only into a non-client strip, and
    // Windows 10 paints a white line when none is left.
    rect->top += IsMaximized() ? frame.bottom : 1;
    return 0;
  } else if (message == WM_GETMINMAXINFO) {
    auto* info = reinterpret_cast<MINMAXINFO*>(lparam);
    const double scale = DpiScale();
    if (minimum_size_.x != 0)
      info->ptMinTrackSize.x = static_cast<LONG>(minimum_size_.x * scale);
    if (minimum_size_.y != 0)
      info->ptMinTrackSize.y = static_cast<LONG>(minimum_size_.y * scale);
    return 0;
  } else if (message == WM_NCACTIVATE) {
    emit_event_(wparam != 0 ? "focus" : "blur");
    if (style_ != nullptr && style_->title_bar_style == TitleBarStyle::kHidden) {
      return TRUE;
    }
  } else if (message == WM_WINDOWPOSCHANGED) {
    const auto* pos = reinterpret_cast<const WINDOWPOS*>(lparam);
    if ((pos->flags & SWP_NOMOVE) == 0 || (pos->flags & SWP_NOSIZE) == 0) {
      ::SetTimer(hwnd, kGeometryTimerId, kGeometrySettleMilliseconds, nullptr);
    }
  } else if (message == WM_TIMER && wparam == kGeometryTimerId) {
    ::KillTimer(hwnd, kGeometryTimerId);
    emit_event_("geometry-changed");
    return 0;
  } else if (message == WM_SIZE) {
    if (is_fullscreen_) {
      return std::nullopt;
    }
    if (wparam == SIZE_MAXIMIZED) {
      emit_event_("maximize");
      last_state_ = WindowState::kMaximized;
    } else if (wparam == SIZE_MINIMIZED) {
      emit_event_("minimize");
      last_state_ = WindowState::kMinimized;
      return 0;
    } else if (wparam == SIZE_RESTORED) {
      if (last_state_ == WindowState::kMaximized) {
        emit_event_("unmaximize");
        last_state_ = WindowState::kNormal;
      } else if (last_state_ == WindowState::kMinimized) {
        emit_event_("restore");
        last_state_ = WindowState::kNormal;
      }
    }
  } else if (message == WM_CLOSE) {
    emit_event_("close");
    if (is_prevent_close_) {
      return -1;
    }
  } else if (message == WM_SHOWWINDOW) {
    emit_event_(wparam == TRUE ? "show" : "hide");
  } else if (message != WM_NULL && message == GetActivateMessage()) {
    emit_event_("activate");
    return 0;
  }

  return std::nullopt;
}

}  // namespace window
