#ifndef FLUTTER_PLUGIN_WINDOW_CONTROLLER_H_
#define FLUTTER_PLUGIN_WINDOW_CONTROLLER_H_

#include <windows.h>

#include <shobjidl_core.h>

#include <functional>
#include <optional>
#include <string>

#include "window_style.h"

namespace window {

struct WindowBounds {
  double x = 0;
  double y = 0;
  double width = 0;
  double height = 0;
};

// Owns the HWND, the WM_* handling for it and the state that handling
// depends on. WindowStyle::Apply is the only thing touching DWM or
// composition attributes; this class only reads title_bar_style from it.
class WindowController {
 public:
  using EventEmitter = std::function<void(const std::string&)>;

  explicit WindowController(EventEmitter emit_event);
  ~WindowController();

  WindowController(const WindowController&) = delete;
  WindowController& operator=(const WindowController&) = delete;

  void Initialize(HWND hwnd);
  HWND GetWindow() const { return hwnd_; }
  void SetStyle(const WindowStyle* style) { style_ = style; }

  std::optional<LRESULT> HandleWindowMessage(HWND hwnd, UINT message,
                                             WPARAM wparam, LPARAM lparam);

  void Show(bool inactive);
  void Hide();
  bool IsVisible() const;
  void Focus();
  void Close();
  void SetPreventClose(bool value) { is_prevent_close_ = value; }

  bool IsMaximized() const;
  void Maximize();
  void Unmaximize();
  bool IsMinimized() const;
  void Minimize();
  void Restore();

  bool IsFullScreen() const { return is_fullscreen_; }
  void SetFullScreen(bool value);

  WindowBounds GetBounds() const;
  void SetBounds(std::optional<double> x, std::optional<double> y,
                 std::optional<double> width, std::optional<double> height);
  void SetMinimumSize(double width, double height);

  bool IsAlwaysOnTop() const;
  void SetAlwaysOnTop(bool value);

  void SetSkipTaskbar(bool value);

  void StartDragging();

 private:
  enum class WindowState {
    kNormal,
    kMaximized,
    kMinimized,
  };

  struct FullScreenSavedState {
    bool maximized = false;
    LONG style = 0;
    RECT frame{};
  };

  double DpiScale() const;
  ITaskbarList3* GetTaskbarList();

  HWND hwnd_ = nullptr;
  const WindowStyle* style_ = nullptr;
  EventEmitter emit_event_;

  WindowState last_state_ = WindowState::kNormal;
  bool is_prevent_close_ = false;
  POINT minimum_size_{0, 0};

  bool is_fullscreen_ = false;
  FullScreenSavedState fullscreen_saved_;

  ITaskbarList3* taskbar_ = nullptr;
};

}  // namespace window

#endif  // FLUTTER_PLUGIN_WINDOW_CONTROLLER_H_
