#include "include/tray/tray_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>

#ifdef HAVE_AYATANA
#include <libayatana-appindicator/app-indicator.h>
#else
#include <libappindicator/app-indicator.h>
#endif

#include <cstring>

#define TRAY_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), tray_plugin_get_type(), TrayPlugin))

struct _TrayPlugin {
  GObject parent_instance;
  FlMethodChannel* channel;
  AppIndicator* indicator;
  GtkWidget* menu;
};

G_DEFINE_TYPE(TrayPlugin, tray_plugin, g_object_get_type())

static TrayPlugin* active_plugin = nullptr;

static FlMethodResponse* respond(bool value) {
  return FL_METHOD_RESPONSE(
      fl_method_success_response_new(fl_value_new_bool(value)));
}

static const char* string_value(FlValue* map, const char* key) {
  if (map == nullptr || fl_value_get_type(map) != FL_VALUE_TYPE_MAP) {
    return nullptr;
  }
  FlValue* value = fl_value_lookup_string(map, key);
  if (value == nullptr || fl_value_get_type(value) != FL_VALUE_TYPE_STRING) {
    return nullptr;
  }
  return fl_value_get_string(value);
}

static bool bool_value(FlValue* map, const char* key, bool fallback) {
  FlValue* value = fl_value_lookup_string(map, key);
  if (value == nullptr || fl_value_get_type(value) != FL_VALUE_TYPE_BOOL) {
    return fallback;
  }
  return fl_value_get_bool(value);
}

static void on_menu_item_activate(GtkMenuItem* item, gpointer user_data) {
  if (active_plugin == nullptr) {
    return;
  }
  g_autoptr(FlValue) arguments = fl_value_new_map();
  fl_value_set_string_take(arguments, "id",
                           fl_value_new_int(GPOINTER_TO_INT(user_data)));
  fl_method_channel_invoke_method(active_plugin->channel, "onMenuItemSelected",
                                  arguments, nullptr, nullptr, nullptr);
}

static GtkWidget* build_menu(FlValue* items) {
  GtkWidget* menu = gtk_menu_new();
  if (items == nullptr || fl_value_get_type(items) != FL_VALUE_TYPE_LIST) {
    return menu;
  }

  for (size_t i = 0; i < fl_value_get_length(items); i++) {
    FlValue* entry = fl_value_get_list_value(items, i);
    if (fl_value_get_type(entry) != FL_VALUE_TYPE_MAP) {
      continue;
    }

    const char* type = string_value(entry, "type");
    if (type == nullptr) {
      continue;
    }

    if (strcmp(type, "separator") == 0) {
      gtk_menu_shell_append(GTK_MENU_SHELL(menu),
                            gtk_separator_menu_item_new());
      continue;
    }

    const char* label = string_value(entry, "label");
    if (label == nullptr) {
      label = "";
    }

    GtkWidget* item;
    bool dispatches = true;
    if (strcmp(type, "checkbox") == 0) {
      item = gtk_check_menu_item_new_with_label(label);
      gtk_check_menu_item_set_active(GTK_CHECK_MENU_ITEM(item),
                                     bool_value(entry, "checked", false));
    } else if (strcmp(type, "submenu") == 0) {
      item = gtk_menu_item_new_with_label(label);
      gtk_menu_item_set_submenu(GTK_MENU_ITEM(item),
                                build_menu(fl_value_lookup_string(entry,
                                                                  "items")));
      dispatches = false;
    } else {
      item = gtk_menu_item_new_with_label(label);
    }

    if (!bool_value(entry, "enabled", true)) {
      gtk_widget_set_sensitive(item, FALSE);
    }

    if (dispatches) {
      FlValue* id = fl_value_lookup_string(entry, "id");
      if (id != nullptr && fl_value_get_type(id) == FL_VALUE_TYPE_INT) {
        g_signal_connect(G_OBJECT(item), "activate",
                         G_CALLBACK(on_menu_item_activate),
                         GINT_TO_POINTER(fl_value_get_int(id)));
      }
    }

    gtk_menu_shell_append(GTK_MENU_SHELL(menu), item);
  }
  return menu;
}

static void attach_menu(TrayPlugin* self, FlValue* items) {
  GtkWidget* previous = self->menu;

  GtkWidget* menu = build_menu(items);
  g_object_ref_sink(menu);
  self->menu = menu;

  app_indicator_set_menu(self->indicator, GTK_MENU(menu));
  gtk_widget_show_all(menu);

  if (previous != nullptr) {
    gtk_widget_destroy(previous);
    g_object_unref(previous);
  }
}

static void apply_title(TrayPlugin* self, const char* title) {
  if (title == nullptr || title[0] == '\0') {
    app_indicator_set_label(self->indicator, nullptr, nullptr);
  } else {
    app_indicator_set_label(self->indicator, title, nullptr);
  }
}

static void release_tray(TrayPlugin* self) {
  if (self->indicator != nullptr) {
    app_indicator_set_status(self->indicator, APP_INDICATOR_STATUS_PASSIVE);
    g_object_unref(self->indicator);
    self->indicator = nullptr;
  }
  if (self->menu != nullptr) {
    GtkWidget* menu = self->menu;
    self->menu = nullptr;
    gtk_widget_destroy(menu);
    g_object_unref(menu);
  }
}

static FlMethodResponse* handle_show(TrayPlugin* self, FlValue* args) {
  const char* id = string_value(args, "id");
  FlValue* icon = fl_value_lookup_string(args, "icon");
  const char* icon_path = string_value(icon, "path");
  if (id == nullptr || icon_path == nullptr ||
      !g_file_test(icon_path, G_FILE_TEST_EXISTS)) {
    return respond(false);
  }

  const bool is_new = self->indicator == nullptr;
  if (is_new) {
    self->indicator =
        app_indicator_new(id, icon_path, APP_INDICATOR_CATEGORY_APPLICATION_STATUS);
  }

  attach_menu(self, fl_value_lookup_string(args, "menu"));

  if (!is_new) {
    app_indicator_set_status(self->indicator, APP_INDICATOR_STATUS_PASSIVE);
  }

  app_indicator_set_icon_full(self->indicator, icon_path, "");

  const char* tool_tip = string_value(args, "toolTip");
  if (tool_tip != nullptr) {
    app_indicator_set_title(self->indicator, tool_tip);
  }

  apply_title(self, string_value(args, "title"));

  app_indicator_set_status(self->indicator, APP_INDICATOR_STATUS_ACTIVE);

  return respond(true);
}

static FlMethodResponse* handle_set_title(TrayPlugin* self, FlValue* args) {
  if (self->indicator == nullptr) {
    return respond(false);
  }
  apply_title(self, string_value(args, "title"));
  return respond(true);
}

static FlMethodResponse* handle_hide(TrayPlugin* self) {
  release_tray(self);
  return respond(true);
}

static void tray_plugin_handle_method_call(TrayPlugin* self,
                                           FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar* method = fl_method_call_get_name(method_call);
  FlValue* args = fl_method_call_get_args(method_call);

  if (strcmp(method, "show") == 0) {
    response = handle_show(self, args);
  } else if (strcmp(method, "setTitle") == 0) {
    response = handle_set_title(self, args);
  } else if (strcmp(method, "hide") == 0) {
    response = handle_hide(self);
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

static void tray_plugin_dispose(GObject* object) {
  TrayPlugin* self = TRAY_PLUGIN(object);

  release_tray(self);
  g_clear_object(&self->channel);

  if (active_plugin == self) {
    active_plugin = nullptr;
  }

  G_OBJECT_CLASS(tray_plugin_parent_class)->dispose(object);
}

static void tray_plugin_class_init(TrayPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = tray_plugin_dispose;
}

static void tray_plugin_init(TrayPlugin* self) {
  self->channel = nullptr;
  self->indicator = nullptr;
  self->menu = nullptr;
}

static void method_call_cb(FlMethodChannel* channel,
                           FlMethodCall* method_call,
                           gpointer user_data) {
  tray_plugin_handle_method_call(TRAY_PLUGIN(user_data), method_call);
}

void tray_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  if (active_plugin != nullptr) {
    return;
  }

  TrayPlugin* plugin =
      TRAY_PLUGIN(g_object_new(tray_plugin_get_type(), nullptr));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  plugin->channel = fl_method_channel_new(
      fl_plugin_registrar_get_messenger(registrar), "tray",
      FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(
      plugin->channel, method_call_cb, g_object_ref(plugin), g_object_unref);

  active_plugin = plugin;

  g_object_unref(plugin);
}
