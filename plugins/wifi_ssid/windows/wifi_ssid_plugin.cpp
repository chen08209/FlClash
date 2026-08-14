#include "wifi_ssid_plugin.h"

#include <windows.h>
#include <wlanapi.h>

#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <string>
#include <utility>

namespace wifi_ssid {

namespace {

constexpr int kPermissionGranted = 0;
constexpr int kPermissionPermanentlyDenied = 2;
constexpr char kChannelName[] = "wifi_ssid";
constexpr char kGetSsidMethod[] = "getSsid";
constexpr char kCheckPermissionMethod[] = "checkPermission";
constexpr char kRequestPermissionMethod[] = "requestPermission";

struct WlanHandleDeleter {
  using pointer = HANDLE;

  void operator()(HANDLE handle) const {
    if (handle != nullptr) {
      WlanCloseHandle(handle, nullptr);
    }
  }
};

struct WlanMemoryDeleter {
  template <typename T>
  void operator()(T *memory) const {
    if (memory != nullptr) {
      WlanFreeMemory(memory);
    }
  }
};

using ScopedWlanHandle = std::unique_ptr<void, WlanHandleDeleter>;
using ScopedInterfaceList =
    std::unique_ptr<WLAN_INTERFACE_INFO_LIST, WlanMemoryDeleter>;
using ScopedConnectionAttributes =
    std::unique_ptr<WLAN_CONNECTION_ATTRIBUTES, WlanMemoryDeleter>;

// 802.11 SSIDs are arbitrary octets, but the standard codec encodes strings
// as UTF-8; handing it invalid bytes makes the Dart side throw while
// decoding, which leaves the SSID state stale.
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
    for (size_t j = 1; j < length; ++j) {
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
// ERROR_ACCESS_DENIED and GetSsid reads as null, so reporting granted
// unconditionally leaves the user with a silently broken per-SSID feature
// and no indication of why.
int CheckPermission() {
  HANDLE client_handle = nullptr;
  DWORD current_version = 0;
  DWORD result_code = WlanOpenHandle(WLAN_API_VERSION_2_0, nullptr,
                                     &current_version, &client_handle);
  if (result_code == ERROR_ACCESS_DENIED) {
    return kPermissionPermanentlyDenied;
  }
  if (result_code != ERROR_SUCCESS) {
    // No WLAN service or adapter is not a permission problem; reporting
    // denied there would show a misleading prompt.
    return kPermissionGranted;
  }
  ScopedWlanHandle client(client_handle);

  PWLAN_INTERFACE_INFO_LIST interface_list = nullptr;
  result_code = WlanEnumInterfaces(client.get(), nullptr, &interface_list);
  if (result_code != ERROR_SUCCESS) {
    return result_code == ERROR_ACCESS_DENIED ? kPermissionPermanentlyDenied
                                              : kPermissionGranted;
  }
  ScopedInterfaceList interfaces(interface_list);

  for (DWORD i = 0; i < interfaces->dwNumberOfItems; ++i) {
    PWLAN_CONNECTION_ATTRIBUTES connection_attributes = nullptr;
    DWORD data_size = 0;
    result_code = WlanQueryInterface(
        client.get(), &interfaces->InterfaceInfo[i].InterfaceGuid,
        wlan_intf_opcode_current_connection, nullptr, &data_size,
        reinterpret_cast<PVOID *>(&connection_attributes), nullptr);
    if (result_code == ERROR_ACCESS_DENIED) {
      return kPermissionPermanentlyDenied;
    }
    ScopedConnectionAttributes connection(connection_attributes);
  }

  return kPermissionGranted;
}

}  // namespace

void WifiSsidPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), kChannelName,
          &flutter::StandardMethodCodec::GetInstance());
  auto plugin = std::make_unique<WifiSsidPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });
  registrar->AddPlugin(std::move(plugin));
}

WifiSsidPlugin::WifiSsidPlugin() = default;

WifiSsidPlugin::~WifiSsidPlugin() = default;

void WifiSsidPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name() == kGetSsidMethod) {
    GetSsid(std::move(result));
  } else if (method_call.method_name() == kCheckPermissionMethod ||
             method_call.method_name() == kRequestPermissionMethod) {
    // Windows has no in-app location prompt, so requesting simply re-checks.
    result->Success(flutter::EncodableValue(CheckPermission()));
  } else {
    result->NotImplemented();
  }
}

void WifiSsidPlugin::GetSsid(
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  HANDLE client_handle = nullptr;
  DWORD current_version = 0;
  DWORD result_code = WlanOpenHandle(WLAN_API_VERSION_2_0, nullptr,
                                     &current_version, &client_handle);
  if (result_code == ERROR_ACCESS_DENIED) {
    result->Success(flutter::EncodableValue());
    return;
  }
  if (result_code != ERROR_SUCCESS) {
    result->Error("WLAN_ERROR", "Failed to open WLAN handle",
                  flutter::EncodableValue(static_cast<int>(result_code)));
    return;
  }
  ScopedWlanHandle client(client_handle);

  PWLAN_INTERFACE_INFO_LIST interface_list = nullptr;
  result_code = WlanEnumInterfaces(client.get(), nullptr, &interface_list);
  if (result_code == ERROR_ACCESS_DENIED) {
    result->Success(flutter::EncodableValue());
    return;
  }
  if (result_code != ERROR_SUCCESS) {
    result->Error("WLAN_ERROR", "Failed to enumerate WLAN interfaces",
                  flutter::EncodableValue(static_cast<int>(result_code)));
    return;
  }
  ScopedInterfaceList interfaces(interface_list);

  std::string ssid;
  bool access_denied = false;
  for (DWORD i = 0; i < interfaces->dwNumberOfItems; ++i) {
    const auto &interface_info = interfaces->InterfaceInfo[i];
    if (interface_info.isState != wlan_interface_state_connected) {
      continue;
    }

    PWLAN_CONNECTION_ATTRIBUTES connection_attributes = nullptr;
    DWORD data_size = 0;
    result_code = WlanQueryInterface(
        client.get(), &interface_info.InterfaceGuid,
        wlan_intf_opcode_current_connection, nullptr, &data_size,
        reinterpret_cast<PVOID *>(&connection_attributes), nullptr);

    if (result_code == ERROR_ACCESS_DENIED) {
      access_denied = true;
      break;
    }
    if (result_code != ERROR_SUCCESS || connection_attributes == nullptr) {
      continue;
    }

    ScopedConnectionAttributes connection(connection_attributes);
    const auto &dot11_ssid =
        connection->wlanAssociationAttributes.dot11Ssid;
    if (dot11_ssid.uSSIDLength == 0 ||
        dot11_ssid.uSSIDLength > DOT11_SSID_MAX_LENGTH) {
      continue;
    }
    ssid.assign(reinterpret_cast<const char *>(dot11_ssid.ucSSID),
                dot11_ssid.uSSIDLength);
    break;
  }

  if (access_denied || ssid.empty() || !IsValidUtf8(ssid)) {
    result->Success(flutter::EncodableValue());
    return;
  }

  result->Success(flutter::EncodableValue(ssid));
}

}  // namespace wifi_ssid
