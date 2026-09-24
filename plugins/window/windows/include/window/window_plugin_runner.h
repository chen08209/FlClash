#ifndef FLUTTER_PLUGIN_WINDOW_PLUGIN_RUNNER_H_
#define FLUTTER_PLUGIN_WINDOW_PLUGIN_RUNNER_H_

#include <flutter/flutter_view_controller.h>
#include <windows.h>

// The engine hides the view only once it is sized to zero, and hiding or
// minimizing the top-level window never resizes it. Call this before
// HandleTopLevelWindowProc, where the plugin consumes a minimize's WM_SIZE.
inline void WindowPluginForwardVisibility(
    flutter::FlutterViewController& controller, UINT message, WPARAM wparam,
    LPARAM lparam) {
  if (message == WM_SHOWWINDOW || message == WM_SIZE) {
    controller.engine()->ProcessExternalWindowMessage(
        controller.view()->GetNativeWindow(), message, wparam, lparam);
  }
}

#endif  // FLUTTER_PLUGIN_WINDOW_PLUGIN_RUNNER_H_
