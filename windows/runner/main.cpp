#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include <app_links/app_links_plugin_c_api.h>
#include <proxy/proxy_plugin_c_api.h>
#include <window/window_plugin_c_api.h>

#include <algorithm>
#include <cstdlib>
#include <iterator>
#include <string>

#include "flutter_window.h"
#include "utils.h"

// The installer and the uninstaller run this after killing the app, whose exit
// path is what normally turns the system proxy off.
constexpr char kClearStaleProxyArgument[] = "--clear-stale-proxy";

constexpr char kWatchProxyArgument[] = "--watch-proxy";

// The Core outlives the app by up to its exit timeout, and a skipped live port answers like a cleared one.
constexpr DWORD kProxyRetryDelaysMs[] = {0, 1000, 2000, 4000};

int RunWatchProxy(const std::string &pid_argument) {
  const DWORD pid = static_cast<DWORD>(
      std::strtoul(pid_argument.c_str(), nullptr, 10));
  if (const HANDLE process = OpenProcess(SYNCHRONIZE, FALSE, pid)) {
    WaitForSingleObject(process, INFINITE);
    CloseHandle(process);
  }
  for (const DWORD delay : kProxyRetryDelaysMs) {
    Sleep(delay);
    ProxyPluginClearStaleProxy();
  }
  return EXIT_SUCCESS;
}

std::vector<std::string>::const_iterator FindArgument(
    const std::vector<std::string> &arguments, const char *name) {
  return std::find(arguments.begin(), arguments.end(), name);
}

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();
  if (FindArgument(command_line_arguments, kClearStaleProxyArgument) !=
      command_line_arguments.end()) {
    return ProxyPluginClearStaleProxy() ? EXIT_SUCCESS : EXIT_FAILURE;
  }
  if (const auto watch = FindArgument(command_line_arguments,
                                      kWatchProxyArgument);
      watch != command_line_arguments.end() &&
      std::next(watch) != command_line_arguments.end()) {
    return RunWatchProxy(*std::next(watch));
  }

  if (HWND running = WindowPluginFindRunningWindow()) {
    SendAppLink(running);
    WindowPluginActivateWindow(running);
    return EXIT_SUCCESS;
  }

  ProxyPluginClearStaleProxy();

  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");
  // See "Impeller disabled on Windows" in .agents/flutter-upgrade.md.
  project.set_impeller_switch(flutter::ImpellerSwitch::Disabled);

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"FlClash", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
