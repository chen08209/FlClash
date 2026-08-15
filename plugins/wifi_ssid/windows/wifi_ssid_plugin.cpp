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
    result->Success(flutter::EncodableValue(kPermissionGranted));
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

  if (access_denied || ssid.empty()) {
    result->Success(flutter::EncodableValue());
    return;
  }

  result->Success(flutter::EncodableValue(ssid));
}

}  // namespace wifi_ssid
