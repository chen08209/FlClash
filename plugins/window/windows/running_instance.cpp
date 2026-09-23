#include "running_instance.h"

#include <cstdint>
#include <sstream>
#include <string>

namespace window {

namespace {

constexpr wchar_t kRunnerWindowClass[] = L"FLUTTER_RUNNER_WIN32_WINDOW";

// Lower-cased because GetModuleFileNameW keeps launch-time casing, and the
// same executable must always hash to one message.
std::wstring GetExecutablePath() {
  wchar_t path[MAX_PATH] = {};
  ::GetModuleFileNameW(nullptr, path, MAX_PATH);
  ::CharLowerW(path);
  return path;
}

struct RunningWindowSearch {
  std::wstring executable;
  HWND found = nullptr;
};

BOOL CALLBACK MatchRunningWindow(HWND hwnd, LPARAM lparam) {
  auto* search = reinterpret_cast<RunningWindowSearch*>(lparam);
  wchar_t window_class[64] = {};
  ::GetClassNameW(hwnd, window_class, 64);
  if (_wcsicmp(window_class, kRunnerWindowClass) != 0) {
    return TRUE;
  }
  DWORD pid = 0;
  ::GetWindowThreadProcessId(hwnd, &pid);
  if (pid == ::GetCurrentProcessId()) {
    return TRUE;
  }
  HANDLE process =
      ::OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, FALSE, pid);
  if (process == nullptr) {
    return TRUE;
  }
  wchar_t executable[MAX_PATH] = {};
  DWORD length = MAX_PATH;
  const BOOL queried =
      ::QueryFullProcessImageNameW(process, 0, executable, &length);
  ::CloseHandle(process);
  if (queried && _wcsicmp(executable, search->executable.c_str()) == 0) {
    search->found = hwnd;
    return FALSE;
  }
  return TRUE;
}

}  // namespace

UINT GetActivateMessage() {
  static const UINT message = [] {
    uint64_t hash = 14695981039346656037ull;
    for (wchar_t c : GetExecutablePath()) {
      hash = (hash ^ static_cast<uint64_t>(c)) * 1099511628211ull;
    }
    std::wostringstream name;
    name << L"window_plugin.activate:" << std::hex << hash;
    return ::RegisterWindowMessageW(name.str().c_str());
  }();
  return message;
}

void AllowActivateMessageThroughUipi(HWND root) {
  ::ChangeWindowMessageFilterEx(root, GetActivateMessage(), MSGFLT_ALLOW,
                                nullptr);
}

HWND FindRunningWindow() {
  RunningWindowSearch search{GetExecutablePath()};
  ::EnumWindows(MatchRunningWindow, reinterpret_cast<LPARAM>(&search));
  return search.found;
}

void ActivateWindow(HWND window) {
  if (window == nullptr) {
    return;
  }
  DWORD pid = 0;
  ::GetWindowThreadProcessId(window, &pid);
  ::AllowSetForegroundWindow(pid);
  ::PostMessageW(window, GetActivateMessage(), 0, 0);
}

}  // namespace window
