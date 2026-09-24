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
  std::wstring path(MAX_PATH, L'\0');
  for (;;) {
    const DWORD length = ::GetModuleFileNameW(
        nullptr, path.data(), static_cast<DWORD>(path.size()));
    if (length == 0) {
      return {};
    }
    if (length < path.size()) {
      path.resize(length);
      break;
    }
    path.resize(path.size() * 2);
  }
  ::CharLowerBuffW(path.data(), static_cast<DWORD>(path.size()));
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
  std::wstring executable(search->executable.size() + 1, L'\0');
  DWORD length = static_cast<DWORD>(executable.size());
  const BOOL queried =
      ::QueryFullProcessImageNameW(process, 0, executable.data(), &length);
  ::CloseHandle(process);
  if (queried &&
      _wcsicmp(executable.c_str(), search->executable.c_str()) == 0) {
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

void AllowRelaunchMessagesThroughUipi(HWND root) {
  ::ChangeWindowMessageFilterEx(root, GetActivateMessage(), MSGFLT_ALLOW,
                                nullptr);
  ::ChangeWindowMessageFilterEx(root, WM_COPYDATA, MSGFLT_ALLOW, nullptr);
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
