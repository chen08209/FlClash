#include "proxy_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include <WinInet.h>
#include <Ras.h>
#include <RasError.h>
#include <algorithm>
#include <string>
#include <vector>

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
  return optionsApplied && settingsNotified;
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
  return optionsApplied && settingsNotified;
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

    auto plugin = std::make_unique<ProxyPlugin>();

    channel->SetMethodCallHandler(
        [plugin_pointer = plugin.get()](const auto &call, auto result)
        {
          plugin_pointer->HandleMethodCall(call, std::move(result));
        });

    registrar->AddPlugin(std::move(plugin));
  }

  void ProxyPlugin::HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    if (method_call.method_name() == "StopProxy")
    {
      result->Success(stopProxy());
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
      result->Success(startProxy(*port, *bypassDomain));
    }
    else
    {
      result->NotImplemented();
    }
  }
} // namespace proxy
