#ifndef RUNNER_RUST_API_H_
#define RUNNER_RUST_API_H_

#include <windows.h>

// Never freed: Dart's later load must get this module (architecture.md, Desktop Window).
inline HMODULE RustApi() {
  static const HMODULE library = ::LoadLibraryExW(
      L"rust_api.dll", nullptr,
      LOAD_LIBRARY_SEARCH_APPLICATION_DIR | LOAD_LIBRARY_SEARCH_SYSTEM32);
  return library;
}

template <typename Function>
Function RustApiFunction(const char* name) {
  const HMODULE library = RustApi();
  return library == nullptr
             ? nullptr
             : reinterpret_cast<Function>(::GetProcAddress(library, name));
}

#endif  // RUNNER_RUST_API_H_
