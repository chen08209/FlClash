#ifndef FLUTTER_PLUGIN_WINDOW_PLUGIN_C_API_H_
#define FLUTTER_PLUGIN_WINDOW_PLUGIN_C_API_H_

#include <flutter_plugin_registrar.h>
#include <windows.h>

#ifdef FLUTTER_PLUGIN_IMPL
#define FLUTTER_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FLUTTER_PLUGIN_EXPORT __declspec(dllimport)
#endif

#if defined(__cplusplus)
extern "C" {
#endif

FLUTTER_PLUGIN_EXPORT void WindowPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar);

// Another running instance's top-level window, or nullptr; safe pre-engine.
FLUTTER_PLUGIN_EXPORT HWND WindowPluginFindRunningWindow();

FLUTTER_PLUGIN_EXPORT void WindowPluginActivateWindow(HWND window);

#if defined(__cplusplus)
}  // extern "C"
#endif

#endif  // FLUTTER_PLUGIN_WINDOW_PLUGIN_C_API_H_
