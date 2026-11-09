#include "include/dynamic_color/dynamic_color_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <math.h>

#define DYNAMIC_COLOR_PLUGIN(obj)                                     \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), dynamic_color_plugin_get_type(), \
                              DynamicColorPlugin))

struct _DynamicColorPlugin {
  GObject parent_instance;
  FlPluginRegistrar* registrar;
};

G_DEFINE_TYPE(DynamicColorPlugin, dynamic_color_plugin, g_object_get_type())

static int get_accent_color(GtkWidget* widget) {
  GdkRGBA color;
  GtkStyleContext* context = gtk_widget_get_style_context(widget);
  gtk_style_context_lookup_color(context, "theme_selected_bg_color", &color);
  return lround(color.alpha * 255) << 24 | lround(color.red * 255) << 16 |
         lround(color.green * 255) << 8 | lround(color.blue * 255);
}

static gboolean get_xdg_portal_accent_color(int* out_argb) {
  g_autoptr(GDBusConnection) connection =
      g_bus_get_sync(G_BUS_TYPE_SESSION, nullptr, nullptr);
  if (!connection) {
    return FALSE;
  }

  g_autoptr(GVariant) result = g_dbus_connection_call_sync(
      connection, "org.freedesktop.portal.Desktop",
      "/org/freedesktop/portal/desktop", "org.freedesktop.portal.Settings",
      "Read",
      g_variant_new("(ss)", "org.freedesktop.appearance", "accent-color"),
      G_VARIANT_TYPE("(v)"), G_DBUS_CALL_FLAGS_NONE, -1, nullptr, nullptr);

  if (!result) {
    return FALSE;
  }

  g_autoptr(GVariant) inner = nullptr;
  g_variant_get(result, "(v)", &inner);
  if (!inner) {
    return FALSE;
  }

  g_autoptr(GVariant) actual_value = g_variant_get_variant(inner);
  if (actual_value &&
      g_variant_is_of_type(actual_value, G_VARIANT_TYPE("(ddd)"))) {
    double r, g, b;
    g_variant_get(actual_value, "(ddd)", &r, &g, &b);
    *out_argb = (255 << 24) | (lround(r * 255) << 16) | (lround(g * 255) << 8) |
                lround(b * 255);
    return TRUE;
  }

  return FALSE;
}

static void dynamic_color_plugin_handle_method_call(DynamicColorPlugin* self,
                                                    FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar* method = fl_method_call_get_name(method_call);
  if (strcmp(method, "getAccentColor") == 0) {
    int argb;
    if (!get_xdg_portal_accent_color(&argb)) {
      FlView* view = fl_plugin_registrar_get_view(self->registrar);
      argb = get_accent_color(GTK_WIDGET(view));
    }
    g_autoptr(FlValue) result = fl_value_new_int(argb);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

static void dynamic_color_plugin_dispose(GObject* object) {
  g_object_unref(DYNAMIC_COLOR_PLUGIN(object)->registrar);
  G_OBJECT_CLASS(dynamic_color_plugin_parent_class)->dispose(object);
}

static void dynamic_color_plugin_class_init(DynamicColorPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = dynamic_color_plugin_dispose;
}

static void dynamic_color_plugin_init(DynamicColorPlugin* self) {}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  DynamicColorPlugin* plugin = DYNAMIC_COLOR_PLUGIN(user_data);
  dynamic_color_plugin_handle_method_call(plugin, method_call);
}

void dynamic_color_plugin_register_with_registrar(
    FlPluginRegistrar* registrar) {
  DynamicColorPlugin* plugin = DYNAMIC_COLOR_PLUGIN(
      g_object_new(dynamic_color_plugin_get_type(), nullptr));
  plugin->registrar = FL_PLUGIN_REGISTRAR(g_object_ref(registrar));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel = fl_method_channel_new(
      fl_plugin_registrar_get_messenger(registrar),
      "io.material.plugins/dynamic_color", FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(
      channel, method_call_cb, g_object_ref(plugin), g_object_unref);

  g_object_unref(plugin);
}
