#include "include/wifi_ssid/wifi_ssid_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gio/gio.h>

#include <cstring>

#define WIFI_SSID_PLUGIN(obj)                                     \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), wifi_ssid_plugin_get_type(), \
                              WifiSsidPlugin))

struct _WifiSsidPlugin {
  GObject parent_instance;
};

G_DEFINE_TYPE(WifiSsidPlugin, wifi_ssid_plugin, G_TYPE_OBJECT)

static constexpr guint32 kNmDeviceTypeWifi = 2;
static constexpr guint32 kNmDeviceStateActivated = 100;
static constexpr guint kDbusTimeoutMs = 1000;

static gchar* unescape_nmcli_value(const char* value) {
  GString* output = g_string_new(nullptr);
  for (const char* cursor = value; *cursor != '\0'; cursor++) {
    if (*cursor == '\\' && *(cursor + 1) != '\0') {
      cursor++;
    }
    g_string_append_c(output, *cursor);
  }
  return g_string_free(output, FALSE);
}

static gchar* ssid_from_variant(GVariant* value) {
  if (value == nullptr || !g_variant_is_of_type(value, G_VARIANT_TYPE("ay"))) {
    return nullptr;
  }

  gsize length = 0;
  const guint8* bytes = static_cast<const guint8*>(
      g_variant_get_fixed_array(value, &length, sizeof(guint8)));
  if (bytes == nullptr || length == 0) {
    return nullptr;
  }

  if (g_utf8_validate(reinterpret_cast<const gchar*>(bytes), length, nullptr)) {
    return g_strndup(reinterpret_cast<const gchar*>(bytes), length);
  }
  return g_utf8_make_valid(reinterpret_cast<const gchar*>(bytes), length);
}

static GVariant* get_dbus_property(GDBusProxy* proxy,
                                   const gchar* interface_name,
                                   const gchar* property_name) {
  g_autoptr(GVariant) cached =
      g_dbus_proxy_get_cached_property(proxy, property_name);
  if (cached != nullptr) {
    return g_steal_pointer(&cached);
  }

  g_autoptr(GError) error = nullptr;
  g_autoptr(GVariant) response = g_dbus_proxy_call_sync(
      proxy, "org.freedesktop.DBus.Properties.Get",
      g_variant_new("(ss)", interface_name, property_name),
      G_DBUS_CALL_FLAGS_NONE, kDbusTimeoutMs, nullptr, &error);
  if (response == nullptr) {
    return nullptr;
  }

  GVariant* value = nullptr;
  g_variant_get(response, "(v)", &value);
  return value;
}

static GDBusProxy* new_network_manager_proxy(const gchar* object_path,
                                             const gchar* interface_name) {
  g_autoptr(GError) error = nullptr;
  return g_dbus_proxy_new_for_bus_sync(
      G_BUS_TYPE_SYSTEM, G_DBUS_PROXY_FLAGS_DO_NOT_CONNECT_SIGNALS, nullptr,
      "org.freedesktop.NetworkManager", object_path, interface_name, nullptr,
      &error);
}

static GDBusProxy* new_system_proxy(const gchar* bus_name,
                                    const gchar* object_path,
                                    const gchar* interface_name) {
  g_autoptr(GError) error = nullptr;
  return g_dbus_proxy_new_for_bus_sync(
      G_BUS_TYPE_SYSTEM, G_DBUS_PROXY_FLAGS_DO_NOT_CONNECT_SIGNALS, nullptr,
      bus_name, object_path, interface_name, nullptr, &error);
}

static gchar* get_ssid_from_network_manager() {
  g_autoptr(GDBusProxy) manager = new_network_manager_proxy(
      "/org/freedesktop/NetworkManager", "org.freedesktop.NetworkManager");
  if (manager == nullptr) {
    return nullptr;
  }

  g_autoptr(GError) error = nullptr;
  g_autoptr(GVariant) response =
      g_dbus_proxy_call_sync(manager, "GetDevices", nullptr,
                             G_DBUS_CALL_FLAGS_NONE, kDbusTimeoutMs, nullptr,
                             &error);
  if (response == nullptr) {
    return nullptr;
  }

  GVariantIter* devices = nullptr;
  g_variant_get(response, "(ao)", &devices);
  if (devices == nullptr) {
    return nullptr;
  }

  gchar* ssid = nullptr;
  const gchar* device_path = nullptr;
  while (ssid == nullptr && g_variant_iter_loop(devices, "&o", &device_path)) {
    g_autoptr(GDBusProxy) device = new_network_manager_proxy(
        device_path, "org.freedesktop.NetworkManager.Device");
    if (device == nullptr) {
      continue;
    }

    g_autoptr(GVariant) device_type = get_dbus_property(
        device, "org.freedesktop.NetworkManager.Device", "DeviceType");
    if (device_type == nullptr ||
        g_variant_get_uint32(device_type) != kNmDeviceTypeWifi) {
      continue;
    }

    g_autoptr(GVariant) device_state = get_dbus_property(
        device, "org.freedesktop.NetworkManager.Device", "State");
    if (device_state == nullptr ||
        g_variant_get_uint32(device_state) != kNmDeviceStateActivated) {
      continue;
    }

    g_autoptr(GDBusProxy) wireless = new_network_manager_proxy(
        device_path, "org.freedesktop.NetworkManager.Device.Wireless");
    if (wireless == nullptr) {
      continue;
    }

    g_autoptr(GVariant) active_access_point =
        get_dbus_property(wireless,
                          "org.freedesktop.NetworkManager.Device.Wireless",
                          "ActiveAccessPoint");
    if (active_access_point == nullptr) {
      continue;
    }

    const gchar* access_point_path =
        g_variant_get_string(active_access_point, nullptr);
    if (access_point_path == nullptr ||
        g_strcmp0(access_point_path, "/") == 0) {
      continue;
    }

    g_autoptr(GDBusProxy) access_point = new_network_manager_proxy(
        access_point_path, "org.freedesktop.NetworkManager.AccessPoint");
    if (access_point == nullptr) {
      continue;
    }

    g_autoptr(GVariant) ssid_value = get_dbus_property(
        access_point, "org.freedesktop.NetworkManager.AccessPoint", "Ssid");
    ssid = ssid_from_variant(ssid_value);
  }

  g_variant_iter_free(devices);
  return ssid;
}

static gchar* get_ssid_from_iwd() {
  g_autoptr(GDBusProxy) object_manager = new_system_proxy(
      "net.connman.iwd", "/", "org.freedesktop.DBus.ObjectManager");
  if (object_manager == nullptr) {
    return nullptr;
  }

  g_autoptr(GError) error = nullptr;
  g_autoptr(GVariant) response = g_dbus_proxy_call_sync(
      object_manager, "GetManagedObjects", nullptr, G_DBUS_CALL_FLAGS_NONE,
      kDbusTimeoutMs, nullptr, &error);
  if (response == nullptr) {
    return nullptr;
  }

  GVariantIter* objects = nullptr;
  g_variant_get(response, "(a{oa{sa{sv}}})", &objects);
  if (objects == nullptr) {
    return nullptr;
  }

  gchar* ssid = nullptr;
  const gchar* object_path = nullptr;
  GVariantIter* interfaces = nullptr;
  while (ssid == nullptr &&
         g_variant_iter_loop(objects, "{&oa{sa{sv}}}", &object_path,
                             &interfaces)) {
    const gchar* interface_name = nullptr;
    GVariantIter* properties = nullptr;
    while (ssid == nullptr &&
           g_variant_iter_loop(interfaces, "{&sa{sv}}", &interface_name,
                               &properties)) {
      if (g_strcmp0(interface_name, "net.connman.iwd.Station") != 0) {
        continue;
      }

      const gchar* property_name = nullptr;
      GVariant* property_value = nullptr;
      while (g_variant_iter_loop(properties, "{&sv}", &property_name,
                                 &property_value)) {
        if (g_strcmp0(property_name, "ConnectedNetwork") != 0) {
          continue;
        }

        const gchar* network_path = g_variant_get_string(property_value, nullptr);
        if (network_path == nullptr || g_strcmp0(network_path, "/") == 0) {
          break;
        }

        g_autoptr(GDBusProxy) network = new_system_proxy(
            "net.connman.iwd", network_path, "net.connman.iwd.Network");
        if (network == nullptr) {
          break;
        }

        g_autoptr(GVariant) name =
            get_dbus_property(network, "net.connman.iwd.Network", "Name");
        if (name != nullptr) {
          ssid = g_strdup(g_variant_get_string(name, nullptr));
        }
        break;
      }
    }
  }

  g_variant_iter_free(objects);
  return ssid;
}

static gchar* get_ssid_from_connman() {
  g_autoptr(GDBusProxy) manager = new_system_proxy(
      "net.connman", "/", "net.connman.Manager");
  if (manager == nullptr) {
    return nullptr;
  }

  g_autoptr(GError) error = nullptr;
  g_autoptr(GVariant) response =
      g_dbus_proxy_call_sync(manager, "GetServices", nullptr,
                             G_DBUS_CALL_FLAGS_NONE, kDbusTimeoutMs, nullptr,
                             &error);
  if (response == nullptr) {
    return nullptr;
  }

  GVariantIter* services = nullptr;
  g_variant_get(response, "(a(oa{sv}))", &services);
  if (services == nullptr) {
    return nullptr;
  }

  gchar* ssid = nullptr;
  const gchar* service_path = nullptr;
  GVariantIter* properties = nullptr;
  while (ssid == nullptr &&
         g_variant_iter_loop(services, "(&oa{sv})", &service_path,
                             &properties)) {
    const gchar* type = nullptr;
    const gchar* state = nullptr;
    const gchar* name = nullptr;
    const gchar* property_name = nullptr;
    GVariant* property_value = nullptr;

    while (g_variant_iter_loop(properties, "{&sv}", &property_name,
                               &property_value)) {
      if (g_strcmp0(property_name, "Type") == 0) {
        type = g_variant_get_string(property_value, nullptr);
      } else if (g_strcmp0(property_name, "State") == 0) {
        state = g_variant_get_string(property_value, nullptr);
      } else if (g_strcmp0(property_name, "Name") == 0) {
        name = g_variant_get_string(property_value, nullptr);
      }
    }

    if (g_strcmp0(type, "wifi") == 0 &&
        (g_strcmp0(state, "online") == 0 ||
         g_strcmp0(state, "ready") == 0) &&
        name != nullptr && strlen(name) > 0) {
      ssid = g_strdup(name);
    }
  }

  g_variant_iter_free(services);
  return ssid;
}

static gchar* get_ssid_from_nmcli() {
  g_auto(GStrv) arguments = nullptr;
  gint argument_count = 0;
  g_autoptr(GError) error = nullptr;
  if (!g_shell_parse_argv(
          "nmcli --terse --fields active,ssid device wifi", &argument_count,
          &arguments, &error)) {
    return nullptr;
  }

  g_auto(GStrv) environment = g_get_environ();
  environment = g_environ_setenv(environment, "LC_ALL", "C", TRUE);
  g_autofree gchar* standard_output = nullptr;
  gint wait_status = 0;
  const gboolean spawned = g_spawn_sync(
      nullptr, arguments, environment,
      static_cast<GSpawnFlags>(G_SPAWN_SEARCH_PATH |
                               G_SPAWN_STDERR_TO_DEV_NULL),
      nullptr, nullptr, &standard_output, nullptr, &wait_status, &error);
  if (!spawned || standard_output == nullptr) {
    return nullptr;
  }
  if (!g_spawn_check_wait_status(wait_status, &error)) {
    return nullptr;
  }

  g_auto(GStrv) lines = g_strsplit(standard_output, "\n", -1);
  for (gchar** line = lines; *line != nullptr; ++line) {
    if (g_str_has_prefix(*line, "yes:")) {
      return unescape_nmcli_value(*line + strlen("yes:"));
    }
  }
  return nullptr;
}

static gchar* get_ssid_value() {
  g_autofree gchar* ssid = get_ssid_from_network_manager();
  if (ssid == nullptr || strlen(ssid) == 0) {
    g_clear_pointer(&ssid, g_free);
    ssid = get_ssid_from_iwd();
  }
  if (ssid == nullptr || strlen(ssid) == 0) {
    g_clear_pointer(&ssid, g_free);
    ssid = get_ssid_from_connman();
  }
  if (ssid == nullptr || strlen(ssid) == 0) {
    g_clear_pointer(&ssid, g_free);
    ssid = get_ssid_from_nmcli();
  }

  if (ssid == nullptr || strlen(ssid) == 0) {
    return nullptr;
  }

  return g_steal_pointer(&ssid);
}

static void get_ssid_task(GTask* task, gpointer source_object,
                          gpointer task_data, GCancellable* cancellable) {
  g_task_return_pointer(task, get_ssid_value(), g_free);
}

static void get_ssid_done(GObject* source_object, GAsyncResult* result,
                          gpointer user_data) {
  FlMethodCall* method_call = FL_METHOD_CALL(user_data);
  g_autoptr(GError) error = nullptr;
  g_autofree gchar* ssid =
      static_cast<gchar*>(g_task_propagate_pointer(G_TASK(result), &error));

  g_autoptr(FlMethodResponse) response = nullptr;
  if (error != nullptr || ssid == nullptr || strlen(ssid) == 0) {
    response = FL_METHOD_RESPONSE(
        fl_method_success_response_new(fl_value_new_null()));
  } else {
    response = FL_METHOD_RESPONSE(
        fl_method_success_response_new(fl_value_new_string(ssid)));
  }

  fl_method_call_respond(method_call, response, nullptr);
  g_object_unref(method_call);
}

static void wifi_ssid_plugin_handle_method_call(FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;
  const gchar* method = fl_method_call_get_name(method_call);

  if (strcmp(method, "getSsid") == 0) {
    g_autoptr(GTask) task =
        g_task_new(nullptr, nullptr, get_ssid_done, g_object_ref(method_call));
    g_task_run_in_thread(task, get_ssid_task);
    return;
  } else if (strcmp(method, "checkPermission") == 0 ||
             strcmp(method, "requestPermission") == 0) {
    // Linux does not require location permission for the Wi-Fi SSID.
    response = FL_METHOD_RESPONSE(
        fl_method_success_response_new(fl_value_new_int(0)));
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

static void wifi_ssid_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(wifi_ssid_plugin_parent_class)->dispose(object);
}

static void wifi_ssid_plugin_class_init(WifiSsidPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = wifi_ssid_plugin_dispose;
}

static void wifi_ssid_plugin_init(WifiSsidPlugin* self) {}

static void method_call_cb(FlMethodChannel*, FlMethodCall* method_call,
                           gpointer) {
  wifi_ssid_plugin_handle_method_call(method_call);
}

void wifi_ssid_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  WifiSsidPlugin* plugin = WIFI_SSID_PLUGIN(
      g_object_new(wifi_ssid_plugin_get_type(), nullptr));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "wifi_ssid", FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(
      channel, method_call_cb, g_object_ref(plugin), g_object_unref);

  g_object_unref(plugin);
}
