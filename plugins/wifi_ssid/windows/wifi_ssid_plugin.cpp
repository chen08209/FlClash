#include "wifi_ssid_plugin.h"

#include <windows.h>
#include <wlanapi.h>
#include <objbase.h>

#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <string>

#pragma comment(lib, "wlanapi.lib")
#pragma comment(lib, "ole32.lib")

namespace wifi_ssid {

namespace {

std::unique_ptr<
    flutter::MethodChannel<flutter::EncodableValue>,
    std::default_delete<flutter::MethodChannel<flutter::EncodableValue>>>
    channel = nullptr;

constexpr int kPermissionGranted = 0;
constexpr int kPermissionPermanentlyDenied = 2;

bool IsValidUtf8(const std::string &value) {
  const auto *bytes = reinterpret_cast<const unsigned char *>(value.data());
  const size_t size = value.size();
  for (size_t i = 0; i < size;) {
    const unsigned char byte = bytes[i];
    size_t length = 0;
    if (byte <= 0x7F) {
      length = 1;
    } else if ((byte & 0xE0) == 0xC0 && byte >= 0xC2) {
      length = 2;
    } else if ((byte & 0xF0) == 0xE0) {
      length = 3;
    } else if ((byte & 0xF8) == 0xF0 && byte <= 0xF4) {
      length = 4;
    } else {
      return false;
    }
    if (i + length > size) {
      return false;
    }
    for (size_t j = 1; j < length; j++) {
      if ((bytes[i + j] & 0xC0) != 0x80) {
        return false;
      }
    }
    i += length;
  }
  return true;
}

// Probes whether the current Windows location-privacy settings allow WLAN
// SSID queries. Without location access the WLAN APIs report
// ERROR_ACCESS_DENIED and the SSID silently reads as null, so surface that
// state as permanently denied instead of pretending permission is granted.
int CheckPermission() {
  HANDLE hClient = nullptr;
  DWORD dwCurVersion = 0;
  DWORD dwResult = WlanOpenHandle(2, nullptr, &dwCurVersion, &hClient);
  if (dwResult == ERROR_ACCESS_DENIED) {
    return kPermissionPermanentlyDenied;
  }
  if (dwResult != ERROR_SUCCESS) {
    // No WLAN service/adapter: report granted to avoid a false warning.
    return kPermissionGranted;
  }

  PWLAN_INTERFACE_INFO_LIST pIfList = nullptr;
  dwResult = WlanEnumInterfaces(hClient, nullptr, &pIfList);
  if (dwResult != ERROR_SUCCESS) {
    WlanCloseHandle(hClient, nullptr);
    return dwResult == ERROR_ACCESS_DENIED ? kPermissionPermanentlyDenied
                                           : kPermissionGranted;
  }

  int permission = kPermissionGranted;
  for (DWORD i = 0; i < pIfList->dwNumberOfItems; i++) {
    PWLAN_CONNECTION_ATTRIBUTES pConnAttrib = nullptr;
    DWORD dwDataSize = sizeof(WLAN_CONNECTION_ATTRIBUTES);
    dwResult = WlanQueryInterface(
        hClient, &pIfList->InterfaceInfo[i].InterfaceGuid,
        wlan_intf_opcode_current_connection, nullptr, &dwDataSize,
        (PVOID *)&pConnAttrib, nullptr);
    if (dwResult == ERROR_ACCESS_DENIED) {
      permission = kPermissionPermanentlyDenied;
      break;
    }
    if (dwResult == ERROR_SUCCESS && pConnAttrib != nullptr) {
      WlanFreeMemory(pConnAttrib);
    }
  }

  WlanFreeMemory(pIfList);
  WlanCloseHandle(hClient, nullptr);
  return permission;
}

}  // namespace

void WifiSsidPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "wifi_ssid",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<WifiSsidPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

WifiSsidPlugin::WifiSsidPlugin() {}

WifiSsidPlugin::~WifiSsidPlugin() {}

void WifiSsidPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name().compare("getSsid") == 0) {
    GetSsid(std::move(result));
  } else if (method_call.method_name().compare("checkPermission") == 0 ||
             method_call.method_name().compare("requestPermission") == 0) {
    // Windows has no in-app location prompt, so requesting simply re-checks.
    result->Success(flutter::EncodableValue(CheckPermission()));
  } else {
    result->NotImplemented();
  }
}

void WifiSsidPlugin::GetSsid(
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  HANDLE hClient = nullptr;
  DWORD dwMaxClient = 2;
  DWORD dwCurVersion = 0;
  DWORD dwResult =
      WlanOpenHandle(dwMaxClient, nullptr, &dwCurVersion, &hClient);
  if (dwResult == ERROR_ACCESS_DENIED) {
    result->Success(flutter::EncodableValue());
    return;
  }
  if (dwResult != ERROR_SUCCESS) {
    result->Error("WLAN_ERROR", "Failed to open WLAN handle",
                  flutter::EncodableValue(static_cast<int>(dwResult)));
    return;
  }

  PWLAN_INTERFACE_INFO_LIST pIfList = nullptr;
  dwResult = WlanEnumInterfaces(hClient, nullptr, &pIfList);
  if (dwResult == ERROR_ACCESS_DENIED) {
    WlanCloseHandle(hClient, nullptr);
    result->Success(flutter::EncodableValue());
    return;
  }
  if (dwResult != ERROR_SUCCESS) {
    WlanCloseHandle(hClient, nullptr);
    result->Error("WLAN_ERROR", "Failed to enumerate WLAN interfaces",
                  flutter::EncodableValue(static_cast<int>(dwResult)));
    return;
  }

  std::string ssid;
  DWORD query_error = ERROR_SUCCESS;
  for (DWORD i = 0; i < pIfList->dwNumberOfItems; i++) {
    PWLAN_CONNECTION_ATTRIBUTES pConnAttrib = nullptr;
    DWORD dwDataSize = sizeof(WLAN_CONNECTION_ATTRIBUTES);
    WLAN_INTF_OPCODE opCode = wlan_intf_opcode_current_connection;

    dwResult = WlanQueryInterface(
        hClient, &pIfList->InterfaceInfo[i].InterfaceGuid, opCode, nullptr,
        &dwDataSize, (PVOID *)&pConnAttrib, nullptr);

    if (dwResult == ERROR_SUCCESS && pConnAttrib != nullptr) {
      if (pConnAttrib->isState == wlan_interface_state_connected) {
        DWORD ssidLen =
            pConnAttrib->wlanAssociationAttributes.dot11Ssid.uSSIDLength;
        if (ssidLen > 0 && ssidLen <= 32) {
          ssid.assign(
              reinterpret_cast<const char *>(
                  pConnAttrib->wlanAssociationAttributes.dot11Ssid.ucSSID),
              ssidLen);
        }
        WlanFreeMemory(pConnAttrib);
        break;
      }
      WlanFreeMemory(pConnAttrib);
    } else if (dwResult == ERROR_ACCESS_DENIED) {
      query_error = dwResult;
      break;
    } else if (query_error == ERROR_SUCCESS) {
      query_error = dwResult;
    }
  }

  WlanFreeMemory(pIfList);
  WlanCloseHandle(hClient, nullptr);

  if (query_error == ERROR_ACCESS_DENIED || ssid.empty()) {
    result->Success(flutter::EncodableValue());
    return;
  }

  // 802.11 SSIDs are arbitrary bytes; sending non-UTF-8 over the channel
  // makes the Dart side throw and leaves the SSID state stale.
  if (!IsValidUtf8(ssid)) {
    result->Success(flutter::EncodableValue());
    return;
  }

  result->Success(flutter::EncodableValue(ssid));
}

}  // namespace wifi_ssid
