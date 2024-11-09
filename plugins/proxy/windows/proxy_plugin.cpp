#include "proxy_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include <WinInet.h>
#include <Ras.h>
#include <RasError.h>
#include <vector>
#include <iostream>

#pragma comment(lib, "wininet")
#pragma comment(lib, "Rasapi32")

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <sstream>

void startProxy(const int port, const flutter::EncodableList& bypassDomain)
{
  INTERNET_PER_CONN_OPTION_LIST list;
  DWORD dwBufSize = sizeof(list);
  list.dwSize = sizeof(list);
  list.pszConnection = nullptr;

  auto url = "127.0.0.1:" + std::to_string(port);
  auto wUrl = std::wstring(url.begin(), url.end());
  auto fullAddr = new WCHAR[url.length() + 1];
  wcscpy_s(fullAddr, url.length() + 1, wUrl.c_str());

  std::wstring wBypassList;

  for (const auto& domain : bypassDomain) {
    if (!wBypassList.empty()) {
       wBypassList += L";";
    }
    wBypassList += std::wstring(std::get<std::string>(domain).begin(), std::get<std::string>(domain).end());
  }

  auto bypassAddr = new WCHAR[wBypassList.length() + 1];
  wcscpy_s(bypassAddr, wBypassList.length() + 1, wBypassList.c_str());

  list.dwOptionCount = 3;
  list.pOptions = new INTERNET_PER_CONN_OPTION[3];

  if (!list.pOptions)
  {
    return;
  }

  list.pOptions[0].dwOption = INTERNET_PER_CONN_FLAGS;
  list.pOptions[0].Value.dwValue = PROXY_TYPE_DIRECT | PROXY_TYPE_PROXY;

  list.pOptions[1].dwOption = INTERNET_PER_CONN_PROXY_SERVER;
  list.pOptions[1].Value.pszValue = fullAddr;

  list.pOptions[2].dwOption = INTERNET_PER_CONN_PROXY_BYPASS;
  list.pOptions[2].Value.pszValue = bypassAddr;

  InternetSetOption(nullptr, INTERNET_OPTION_PER_CONNECTION_OPTION, &list, dwBufSize);

  RASENTRYNAME entry;
  entry.dwSize = sizeof(entry);
  std::vector<RASENTRYNAME> entries;
  DWORD size = sizeof(entry), count;
  LPRASENTRYNAME entryAddr = &entry;
  auto ret = RasEnumEntries(nullptr, nullptr, entryAddr, &size, &count);
  if (ret == ERROR_BUFFER_TOO_SMALL)
  {
    entries.resize(count);
    entries[0].dwSize = sizeof(RASENTRYNAME);
    entryAddr = entries.data();
    ret = RasEnumEntries(nullptr, nullptr, entryAddr, &size, &count);
  }
  if (ret != ERROR_SUCCESS)
  {
    return;
  }
  for (DWORD i = 0; i < count; i++)
  {
    list.pszConnection = entryAddr[i].szEntryName;
    InternetSetOption(nullptr, INTERNET_OPTION_PER_CONNECTION_OPTION, &list, dwBufSize);
  }

  delete[] fullAddr;
  delete[] bypassAddr;
  delete[] list.pOptions;

  InternetSetOption(nullptr, INTERNET_OPTION_SETTINGS_CHANGED, nullptr, 0);
  InternetSetOption(nullptr, INTERNET_OPTION_REFRESH, nullptr, 0);
}

void stopProxy()
{
  INTERNET_PER_CONN_OPTION_LIST list;
  DWORD dwBufSize = sizeof(list);

  list.dwSize = sizeof(list);
  list.pszConnection = nullptr;
  list.dwOptionCount = 1;
  list.pOptions = new INTERNET_PER_CONN_OPTION[1];
  if (nullptr == list.pOptions)
  {
    return;
  }
  list.pOptions[0].dwOption = INTERNET_PER_CONN_FLAGS;
  list.pOptions[0].Value.dwValue = PROXY_TYPE_DIRECT;

  InternetSetOption(nullptr, INTERNET_OPTION_PER_CONNECTION_OPTION, &list, dwBufSize);

  RASENTRYNAME entry;
  entry.dwSize = sizeof(entry);
  std::vector<RASENTRYNAME> entries;
  DWORD size = sizeof(entry), count;
  LPRASENTRYNAME entryAddr = &entry;
  auto ret = RasEnumEntries(nullptr, nullptr, entryAddr, &size, &count);
  if (ret == ERROR_BUFFER_TOO_SMALL)
  {
    entries.resize(count);
    entries[0].dwSize = sizeof(RASENTRYNAME);
    entryAddr = entries.data();
    ret = RasEnumEntries(nullptr, nullptr, entryAddr, &size, &count);
  }
  if (ret != ERROR_SUCCESS)
  {
    return;
  }
  for (DWORD i = 0; i < count; i++)
  {
    list.pszConnection = entryAddr[i].szEntryName;
    InternetSetOption(nullptr, INTERNET_OPTION_PER_CONNECTION_OPTION, &list, dwBufSize);
  }
  delete[] list.pOptions;
  InternetSetOption(nullptr, INTERNET_OPTION_SETTINGS_CHANGED, nullptr, 0);
  InternetSetOption(nullptr, INTERNET_OPTION_REFRESH, nullptr, 0);
}

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

  ProxyPlugin::ProxyPlugin() {}

  ProxyPlugin::~ProxyPlugin() {}

  void ProxyPlugin::HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    if (method_call.method_name().compare("StopProxy") == 0)
    {
      stopProxy();
      result->Success(true);
    }
    else if (method_call.method_name().compare("StartProxy") == 0)
    {
      auto *arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
      auto port = std::get<int>(arguments->at(flutter::EncodableValue("port")));
      auto bypassDomain = std::get<flutter::EncodableList>(arguments->at(flutter::EncodableValue("bypassDomain")));
      startProxy(port, bypassDomain);
      result->Success(true);
    }
    else
    {
      result->NotImplemented();
    }
  }
} // namespace proxy
