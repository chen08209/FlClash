#include "proxy_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include <WinInet.h>
#include <Ras.h>
#include <RasError.h>
#include <algorithm>
#include <string>
#include <vector>
#include <map>

#pragma comment(lib, "wininet")
#pragma comment(lib, "Rasapi32")

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>

namespace
{

constexpr int kMinProxyPort = 1;
constexpr int kMaxProxyPort = 65535;

std::wstring Utf8ToWide(const std::string& value)
{
  if (value.empty())
  {
    return {};
  }
  const int size = MultiByteToWideChar(
      CP_UTF8, 0, value.c_str(), static_cast<int>(value.size()), nullptr, 0);
  if (size <= 0)
  {
    return std::wstring(value.begin(), value.end());
  }
  std::wstring result(size, L'\0');
  MultiByteToWideChar(
      CP_UTF8, 0, value.c_str(), static_cast<int>(value.size()),
      result.data(), size);
  return result;
}

std::wstring BuildBypassList(const flutter::EncodableList& bypassDomain)
{
  std::wstring bypassList;
  for (const auto& domain : bypassDomain)
  {
    const auto& value = std::get<std::string>(domain);
    if (!bypassList.empty())
    {
      bypassList += L";";
    }
    bypassList += Utf8ToWide(value);
  }
  return bypassList;
}

bool IsStringList(const flutter::EncodableList& values)
{
  return std::all_of(
      values.begin(), values.end(), [](const auto& value)
      {
        return std::holds_alternative<std::string>(value);
      });
}

bool SetOptionsForConnection(
    INTERNET_PER_CONN_OPTION_LIST& list,
    LPTSTR connection)
{
  list.pszConnection = connection;
  return InternetSetOption(
      nullptr,
      INTERNET_OPTION_PER_CONNECTION_OPTION,
      &list,
      sizeof(list)) != FALSE;
}

bool ApplyOptionsToConnections(INTERNET_PER_CONN_OPTION_LIST& list)
{
  bool success = SetOptionsForConnection(list, nullptr);

  DWORD size = 0;
  DWORD count = 0;
  auto ret = RasEnumEntries(nullptr, nullptr, nullptr, &size, &count);
  if (ret == ERROR_BUFFER_TOO_SMALL && count > 0)
  {
    std::vector<RASENTRYNAME> entries(count);
    for (auto& entry : entries)
    {
      entry.dwSize = sizeof(RASENTRYNAME);
    }
    ret = RasEnumEntries(nullptr, nullptr, entries.data(), &size, &count);
    if (ret == ERROR_SUCCESS)
    {
      for (DWORD i = 0; i < count; i++)
      {
        success = SetOptionsForConnection(list, entries[i].szEntryName) && success;
      }
    }
    else
    {
      success = false;
    }
  }
  else if (ret != ERROR_SUCCESS)
  {
    success = false;
  }

  return success;
}

bool NotifySettingsChanged()
{
  const bool changed = InternetSetOption(
      nullptr, INTERNET_OPTION_SETTINGS_CHANGED, nullptr, 0) != FALSE;
  const bool refreshed = InternetSetOption(
      nullptr, INTERNET_OPTION_REFRESH, nullptr, 0) != FALSE;
  return changed && refreshed;
}


constexpr const wchar_t* const kProxyUrlEnvVars[] = {
    L"HTTP_PROXY", L"HTTPS_PROXY", L"http_proxy", L"https_proxy"};
constexpr const wchar_t* const kNoProxyEnvVars[] = {L"NO_PROXY", L"no_proxy"};
constexpr const wchar_t* const kAllProxyEnvVars[] = {
    L"HTTP_PROXY", L"HTTPS_PROXY", L"NO_PROXY",
    L"http_proxy", L"https_proxy", L"no_proxy"};

struct ProxyEnvironmentBackup
{
  bool taken = false;
  std::map<std::wstring, std::optional<std::wstring>> originals;
};

ProxyEnvironmentBackup g_proxyEnvironmentBackup;

std::wstring BuildNoProxyList(const flutter::EncodableList& bypassDomain)
{
  std::wstring noProxy;
  for (const auto& domain : bypassDomain)
  {
    const auto& value = std::get<std::string>(domain);
    if (!noProxy.empty())
    {
      noProxy += L",";
    }
    noProxy += Utf8ToWide(value);
  }
  return noProxy;
}

bool SetUserEnvironmentVariable(const std::wstring& name, const std::wstring& value)
{
  if (SetEnvironmentVariableW(name.c_str(), value.c_str()) == FALSE)
  {
    return false;
  }
  HKEY key = nullptr;
  if (RegOpenKeyExW(HKEY_CURRENT_USER, L"Environment", 0, KEY_SET_VALUE, &key) !=
      ERROR_SUCCESS)
  {
    return false;
  }
  const LSTATUS status = RegSetValueExW(
      key, name.c_str(), 0, REG_SZ, reinterpret_cast<const BYTE*>(value.c_str()),
      static_cast<DWORD>((value.size() + 1) * sizeof(wchar_t)));
  RegCloseKey(key);
  return status == ERROR_SUCCESS;
}

bool DeleteUserEnvironmentVariable(const std::wstring& name)
{
  if (SetEnvironmentVariableW(name.c_str(), nullptr) == FALSE)
  {
    return false;
  }
  HKEY key = nullptr;
  if (RegOpenKeyExW(HKEY_CURRENT_USER, L"Environment", 0, KEY_SET_VALUE, &key) !=
      ERROR_SUCCESS)
  {
    return false;
  }
  const LSTATUS status = RegDeleteValueW(key, name.c_str());
  RegCloseKey(key);
  return status == ERROR_SUCCESS || status == ERROR_FILE_NOT_FOUND;
}

std::optional<std::wstring> ReadUserEnvironmentVariable(const std::wstring& name)
{
  HKEY key = nullptr;
  if (RegOpenKeyExW(HKEY_CURRENT_USER, L"Environment", 0, KEY_READ, &key) !=
      ERROR_SUCCESS)
  {
    return std::nullopt;
  }
  std::optional<std::wstring> value;
  DWORD dataSize = 0;
  if (RegQueryValueExW(key, name.c_str(), nullptr, nullptr, nullptr, &dataSize) ==
          ERROR_SUCCESS &&
      dataSize >= sizeof(wchar_t))
  {
    value = std::wstring(dataSize / sizeof(wchar_t), L'\0');
    if (RegQueryValueExW(key, name.c_str(), nullptr, nullptr,
                         reinterpret_cast<LPBYTE>(value->data()),
                         &dataSize) == ERROR_SUCCESS)
    {
      while (!value->empty() && value->back() == L'\0')
      {
        value->pop_back();
      }
    }
    else
    {
      value.reset();
    }
  }
  RegCloseKey(key);
  return value;
}

void BroadcastEnvironmentChange()
{
  SendMessageTimeoutW(HWND_BROADCAST, WM_SETTINGCHANGE, 0, L"Environment",
                      SMTO_BLOCK, 5000, nullptr);
}

void BackupProxyEnvironment()
{
  if (g_proxyEnvironmentBackup.taken)
  {
    return;
  }
  for (const auto* name : kAllProxyEnvVars)
  {
    g_proxyEnvironmentBackup.originals[name] = ReadUserEnvironmentVariable(name);
  }
  g_proxyEnvironmentBackup.taken = true;
}

bool ApplyProxyEnvironment(const std::wstring& proxyUrl, const std::wstring& noProxy)
{
  bool success = true;
  for (const auto* name : kProxyUrlEnvVars)
  {
    success = SetUserEnvironmentVariable(name, proxyUrl) && success;
  }
  for (const auto* name : kNoProxyEnvVars)
  {
    success = SetUserEnvironmentVariable(name, noProxy) && success;
  }
  return success;
}

bool RestoreProxyEnvironment()
{
  if (!g_proxyEnvironmentBackup.taken)
  {
    return true;
  }
  bool success = true;
  for (const auto& [name, original] : g_proxyEnvironmentBackup.originals)
  {
    success = (original.has_value() ? SetUserEnvironmentVariable(name, *original)
                                    : DeleteUserEnvironmentVariable(name)) &&
        success;
  }
  g_proxyEnvironmentBackup = ProxyEnvironmentBackup{};
  return success;
}

bool startProxy(const int port, const flutter::EncodableList& bypassDomain)
{
  auto url = Utf8ToWide("127.0.0.1:" + std::to_string(port));
  auto bypassList = BuildBypassList(bypassDomain);
  std::vector<INTERNET_PER_CONN_OPTION> options(3);

  INTERNET_PER_CONN_OPTION_LIST list = {};
  list.dwSize = sizeof(list);
  list.dwOptionCount = static_cast<DWORD>(options.size());
  list.pOptions = options.data();

  options[0].dwOption = INTERNET_PER_CONN_FLAGS;
  options[0].Value.dwValue = PROXY_TYPE_DIRECT | PROXY_TYPE_PROXY;

  options[1].dwOption = INTERNET_PER_CONN_PROXY_SERVER;
  options[1].Value.pszValue = url.data();

  options[2].dwOption = INTERNET_PER_CONN_PROXY_BYPASS;
  options[2].Value.pszValue = bypassList.data();

  const bool optionsApplied = ApplyOptionsToConnections(list);
  const bool settingsNotified = NotifySettingsChanged();

  // Point CLI, Node.js, Python and Electron apps at the proxy as well. These
  // read the HTTP(S)_PROXY/NO_PROXY environment variables rather than the
  // WinINET registry, so the system-proxy setting alone leaves them going
  // direct. The previous values are restored by stopProxy.
  BackupProxyEnvironment();
  const bool envApplied =
      ApplyProxyEnvironment(L"http://" + url, BuildNoProxyList(bypassDomain));
  if (envApplied)
  {
    BroadcastEnvironmentChange();
  }
  return optionsApplied && settingsNotified && envApplied;
}

bool stopProxy()
{
  std::vector<INTERNET_PER_CONN_OPTION> options(1);

  INTERNET_PER_CONN_OPTION_LIST list = {};
  list.dwSize = sizeof(list);
  list.dwOptionCount = 1;
  list.pOptions = options.data();

  options[0].dwOption = INTERNET_PER_CONN_FLAGS;
  options[0].Value.dwValue = PROXY_TYPE_DIRECT;

  const bool optionsApplied = ApplyOptionsToConnections(list);
  const bool settingsNotified = NotifySettingsChanged();

  // Restore the proxy environment variables to whatever they were before the
  // proxy was applied, or remove them if they were unset.
  const bool envRestored = RestoreProxyEnvironment();
  if (envRestored)
  {
    BroadcastEnvironmentChange();
  }
  return optionsApplied && settingsNotified && envRestored;
}

}  // namespace

namespace proxy
{

  // static
  void ProxyPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarWindows *registrar)
  {
    auto channel =
        std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
            registrar->messenger(), "proxy",
            &flutter::StandardMethodCodec::GetInstance());

    auto plugin = std::make_unique<ProxyPlugin>(registrar);

    channel->SetMethodCallHandler(
        [plugin_pointer = plugin.get()](const auto &call, auto result)
        {
          plugin_pointer->HandleMethodCall(call, std::move(result));
        });

    registrar->AddPlugin(std::move(plugin));
  }

  ProxyPlugin::ProxyPlugin(flutter::PluginRegistrarWindows* registrar)
      : registrar_(registrar)
  {
    window_proc_id_ = registrar_->RegisterTopLevelWindowProcDelegate(
        [this](HWND window, UINT message, WPARAM wparam, LPARAM lparam)
        {
          return HandleWindowProc(window, message, wparam, lparam);
        });
  }

  ProxyPlugin::~ProxyPlugin()
  {
    if (registrar_ != nullptr)
    {
      registrar_->UnregisterTopLevelWindowProcDelegate(window_proc_id_);
    }
  }

  bool ProxyPlugin::IsSessionEnding(UINT message, WPARAM wparam)
  {
    return message == WM_ENDSESSION && wparam != FALSE;
  }

  // Shutting Windows down kills the process without running the Dart exit path,
  // so the setting survives into a boot with nothing listening behind it.
  std::optional<LRESULT> ProxyPlugin::HandleWindowProc(
      HWND window, UINT message, WPARAM wparam, LPARAM lparam)
  {
    if (proxy_applied_ && IsSessionEnding(message, wparam))
    {
      proxy_applied_ = !stopProxy();
    }
    return std::nullopt;
  }

  void ProxyPlugin::HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    if (method_call.method_name() == "StopProxy")
    {
      const bool stopped = stopProxy();
      proxy_applied_ = proxy_applied_ && !stopped;
      result->Success(stopped);
    }
    else if (method_call.method_name() == "StartProxy")
    {
      auto *arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
      if (arguments == nullptr)
      {
        result->Error("bad_args", "StartProxy requires argument map");
        return;
      }
      auto portIt = arguments->find(flutter::EncodableValue("port"));
      auto bypassDomainIt = arguments->find(flutter::EncodableValue("bypassDomain"));
      if (portIt == arguments->end() || bypassDomainIt == arguments->end())
      {
        result->Error("bad_args", "StartProxy requires port and bypassDomain");
        return;
      }
      auto *port = std::get_if<int>(&portIt->second);
      auto *bypassDomain = std::get_if<flutter::EncodableList>(&bypassDomainIt->second);
      if (port == nullptr || bypassDomain == nullptr)
      {
        result->Error("bad_args", "StartProxy argument types are invalid");
        return;
      }
      if (*port < kMinProxyPort || *port > kMaxProxyPort)
      {
        result->Error("bad_args", "StartProxy port must be between 1 and 65535");
        return;
      }
      if (!IsStringList(*bypassDomain))
      {
        result->Error(
            "bad_args", "StartProxy bypassDomain must contain only strings");
        return;
      }
      // A start that reports failure can still have written the setting.
      proxy_applied_ = true;
      result->Success(startProxy(*port, *bypassDomain));
    }
    else
    {
      result->NotImplemented();
    }
  }
} // namespace proxy
