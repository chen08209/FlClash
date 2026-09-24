#include "include/window/window_plugin.h"

#include <gtk/gtk.h>
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif

#include <cstdint>
#include <cstring>

#include "window_plugin_internal.h"

G_DEFINE_TYPE(WindowPlugin, window_plugin, g_object_get_type())

static WindowPlugin* activate_target = nullptr;

static constexpr gint64 kMinimizeFocusLossWindow =
    500 * G_TIME_SPAN_MILLISECOND;

GtkWindow* window_plugin_get_window(WindowPlugin* self) {
  FlView* view = fl_plugin_registrar_get_view(self->registrar);
  if (view == nullptr) {
    return nullptr;
  }
  return GTK_WINDOW(gtk_widget_get_toplevel(GTK_WIDGET(view)));
}

GdkWindow* window_plugin_get_gdk_window(WindowPlugin* self) {
  GtkWindow* window = window_plugin_get_window(self);
  if (window == nullptr) {
    return nullptr;
  }
  return gtk_widget_get_window(GTK_WIDGET(window));
}

void window_plugin_emit_event(WindowPlugin* self, const char* name) {
  g_autoptr(FlValue) args = fl_value_new_map();
  fl_value_set_string_take(args, "name", fl_value_new_string(name));
  fl_method_channel_invoke_method(self->channel, "onEvent", args, nullptr,
                                  nullptr, nullptr);
}

static FlMethodResponse* success_response(FlValue* value) {
  return FL_METHOD_RESPONSE(fl_method_success_response_new(value));
}

static FlMethodResponse* success_null() {
  g_autoptr(FlValue) value = fl_value_new_null();
  return success_response(value);
}

static FlMethodResponse* success_bool(bool value) {
  g_autoptr(FlValue) value_out = fl_value_new_bool(value);
  return success_response(value_out);
}

static FlMethodResponse* not_ready_response() {
  return FL_METHOD_RESPONSE(fl_method_error_response_new(
      "not_ready", "Window is not available", nullptr));
}

static FlMethodResponse* bad_args_response(const char* method,
                                           const char* key) {
  g_autofree gchar* message = g_strdup_printf("%s requires '%s'", method, key);
  return FL_METHOD_RESPONSE(
      fl_method_error_response_new("bad_args", message, nullptr));
}

static FlMethodResponse* unsupported_response(const char* message) {
  return FL_METHOD_RESPONSE(
      fl_method_error_response_new("unsupported", message, nullptr));
}

static bool arg_bool(FlValue* args, const char* key, bool* out) {
  if (args == nullptr || fl_value_get_type(args) != FL_VALUE_TYPE_MAP) {
    return false;
  }
  FlValue* value = fl_value_lookup_string(args, key);
  if (value == nullptr || fl_value_get_type(value) != FL_VALUE_TYPE_BOOL) {
    return false;
  }
  *out = fl_value_get_bool(value);
  return true;
}

static bool arg_double(FlValue* args, const char* key, double* out) {
  if (args == nullptr || fl_value_get_type(args) != FL_VALUE_TYPE_MAP) {
    return false;
  }
  FlValue* value = fl_value_lookup_string(args, key);
  if (value == nullptr) {
    return false;
  }
  if (fl_value_get_type(value) == FL_VALUE_TYPE_FLOAT) {
    *out = fl_value_get_float(value);
    return true;
  }
  if (fl_value_get_type(value) == FL_VALUE_TYPE_INT) {
    *out = static_cast<double>(fl_value_get_int(value));
    return true;
  }
  return false;
}

static bool arg_string(FlValue* args, const char* key, const char** out) {
  if (args == nullptr || fl_value_get_type(args) != FL_VALUE_TYPE_MAP) {
    return false;
  }
  FlValue* value = fl_value_lookup_string(args, key);
  if (value == nullptr || fl_value_get_type(value) != FL_VALUE_TYPE_STRING) {
    return false;
  }
  *out = fl_value_get_string(value);
  return true;
}

static FlMethodResponse* handle_ensure_initialized(WindowPlugin*,
                                                    FlValue*) {
  return success_null();
}

static FlMethodResponse* handle_show(WindowPlugin* self, FlValue* args) {
  bool inactive;
  if (!arg_bool(args, "inactive", &inactive)) {
    return bad_args_response("show", "inactive");
  }
  GtkWindow* window = window_plugin_get_window(self);
  if (window == nullptr) {
    return not_ready_response();
  }
  if (inactive) {
    gtk_window_set_focus_on_map(window, FALSE);
    gtk_widget_show(GTK_WIDGET(window));
    gtk_window_set_focus_on_map(window, TRUE);
  } else {
    gtk_widget_show(GTK_WIDGET(window));
  }
  return success_null();
}

static FlMethodResponse* handle_hide(WindowPlugin* self, FlValue*) {
  window_geometry_on_hide(self);
  return success_null();
}

static FlMethodResponse* handle_is_visible(WindowPlugin* self, FlValue*) {
  GtkWindow* window = window_plugin_get_window(self);
  return success_bool(window != nullptr &&
                      gtk_widget_is_visible(GTK_WIDGET(window)));
}

static FlMethodResponse* handle_focus(WindowPlugin* self, FlValue*) {
  GtkWindow* window = window_plugin_get_window(self);
  if (window == nullptr) {
    return not_ready_response();
  }
  gtk_window_present(window);
  return success_null();
}

static FlMethodResponse* handle_close(WindowPlugin* self, FlValue*) {
  GtkWindow* window = window_plugin_get_window(self);
  if (window == nullptr) {
    return not_ready_response();
  }
  gtk_window_close(window);
  return success_null();
}

static FlMethodResponse* handle_set_prevent_close(WindowPlugin* self,
                                                  FlValue* args) {
  bool value;
  if (!arg_bool(args, "value", &value)) {
    return bad_args_response("setPreventClose", "value");
  }
  self->prevent_close = value;
  return success_null();
}

static FlMethodResponse* handle_is_maximized(WindowPlugin* self,
                                             FlValue*) {
  GtkWindow* window = window_plugin_get_window(self);
  return success_bool(window != nullptr && gtk_window_is_maximized(window));
}

static FlMethodResponse* handle_maximize(WindowPlugin* self, FlValue*) {
  GtkWindow* window = window_plugin_get_window(self);
  if (window == nullptr) {
    return not_ready_response();
  }
  gtk_window_maximize(window);
  return success_null();
}

static FlMethodResponse* handle_unmaximize(WindowPlugin* self, FlValue*) {
  GtkWindow* window = window_plugin_get_window(self);
  if (window == nullptr) {
    return not_ready_response();
  }
  gtk_window_unmaximize(window);
  return success_null();
}

static FlMethodResponse* handle_is_minimized(WindowPlugin* self,
                                             FlValue*) {
  GdkWindow* gdk_window = window_plugin_get_gdk_window(self);
  return success_bool(gdk_window != nullptr &&
                      (gdk_window_get_state(gdk_window) &
                       GDK_WINDOW_STATE_ICONIFIED));
}

static FlMethodResponse* handle_minimize(WindowPlugin* self, FlValue*) {
  GtkWindow* window = window_plugin_get_window(self);
  if (window == nullptr) {
    return not_ready_response();
  }
  gtk_window_iconify(window);
  self->minimize_requested_at = g_get_monotonic_time();
  return success_null();
}

static FlMethodResponse* handle_restore(WindowPlugin* self, FlValue*) {
  GtkWindow* window = window_plugin_get_window(self);
  if (window == nullptr) {
    return not_ready_response();
  }
  gtk_window_deiconify(window);
  gtk_window_present(window);
  return success_null();
}

static FlMethodResponse* handle_is_full_screen(WindowPlugin* self,
                                               FlValue*) {
  GdkWindow* gdk_window = window_plugin_get_gdk_window(self);
  return success_bool(gdk_window != nullptr &&
                      (gdk_window_get_state(gdk_window) &
                       GDK_WINDOW_STATE_FULLSCREEN));
}

static FlMethodResponse* handle_set_full_screen(WindowPlugin* self,
                                                FlValue* args) {
  bool value;
  if (!arg_bool(args, "value", &value)) {
    return bad_args_response("setFullScreen", "value");
  }
  GtkWindow* window = window_plugin_get_window(self);
  if (window == nullptr) {
    return not_ready_response();
  }
  if (value) {
    gtk_window_fullscreen(window);
  } else {
    gtk_window_unfullscreen(window);
  }
  return success_null();
}

static FlMethodResponse* handle_get_bounds(WindowPlugin* self, FlValue*) {
  GtkWindow* window = window_plugin_get_window(self);
  if (window == nullptr) {
    return not_ready_response();
  }

  gint x, y, width, height;
  gtk_window_get_position(window, &x, &y);
  gtk_window_get_size(window, &width, &height);

  g_autoptr(FlValue) result = fl_value_new_map();
  fl_value_set_string_take(result, "x", fl_value_new_float(x));
  fl_value_set_string_take(result, "y", fl_value_new_float(y));
  fl_value_set_string_take(result, "width", fl_value_new_float(width));
  fl_value_set_string_take(result, "height", fl_value_new_float(height));
  return success_response(result);
}

static FlMethodResponse* handle_set_bounds(WindowPlugin* self, FlValue* args) {
  GtkWindow* window = window_plugin_get_window(self);
  if (window == nullptr) {
    return not_ready_response();
  }

  double x, y;
  if (arg_double(args, "x", &x) && arg_double(args, "y", &y)) {
    gtk_window_move(window, static_cast<gint>(x), static_cast<gint>(y));
  }

  double width, height;
  if (arg_double(args, "width", &width) && arg_double(args, "height", &height)) {
    gint w = static_cast<gint>(width);
    gint h = static_cast<gint>(height);
    if (gtk_widget_get_mapped(GTK_WIDGET(window))) {
      gtk_window_resize(window, w, h);
    } else {
      // A resize request loses to the default-size hint when an unmapped
      // window is mapped, so the default size is set instead.
      gtk_window_set_default_size(window, w, h);
    }
  }

  return success_null();
}

static FlMethodResponse* handle_is_position_supported([[maybe_unused]] WindowPlugin* self,
                                                       FlValue*) {
  bool supported = false;
#ifdef GDK_WINDOWING_X11
  GtkWindow* window = window_plugin_get_window(self);
  if (window != nullptr) {
    GdkScreen* screen = gtk_window_get_screen(window);
    supported = screen != nullptr && GDK_IS_X11_SCREEN(screen);
  }
#endif
  return success_bool(supported);
}

static FlMethodResponse* handle_set_minimum_size(WindowPlugin* self,
                                                 FlValue* args) {
  double width, height;
  if (!arg_double(args, "width", &width)) {
    return bad_args_response("setMinimumSize", "width");
  }
  if (!arg_double(args, "height", &height)) {
    return bad_args_response("setMinimumSize", "height");
  }

  GdkWindow* gdk_window = window_plugin_get_gdk_window(self);
  if (gdk_window == nullptr) {
    return not_ready_response();
  }

  GdkGeometry hints;
  memset(&hints, 0, sizeof(hints));
  GdkWindowHints mask = static_cast<GdkWindowHints>(0);
  if (width >= 0 && height >= 0) {
    hints.min_width = static_cast<gint>(width);
    hints.min_height = static_cast<gint>(height);
    mask = GDK_HINT_MIN_SIZE;
  }
  gdk_window_set_geometry_hints(gdk_window, &hints, mask);
  return success_null();
}

static FlMethodResponse* handle_is_always_on_top(WindowPlugin* self,
                                                 FlValue*) {
  return success_bool(self->always_on_top);
}

static FlMethodResponse* handle_set_always_on_top(WindowPlugin* self,
                                                   FlValue* args) {
  bool value;
  if (!arg_bool(args, "value", &value)) {
    return bad_args_response("setAlwaysOnTop", "value");
  }
  GtkWindow* window = window_plugin_get_window(self);
  if (window == nullptr) {
    return not_ready_response();
  }
  gtk_window_set_keep_above(window, value);
  self->always_on_top = value;
  return success_null();
}

static FlMethodResponse* handle_set_title_bar_style(WindowPlugin* self,
                                                    FlValue* args) {
  const char* style;
  if (!arg_string(args, "style", &style)) {
    return bad_args_response("setTitleBarStyle", "style");
  }
  bool window_button_visibility;
  if (!arg_bool(args, "windowButtonVisibility", &window_button_visibility)) {
    return bad_args_response("setTitleBarStyle", "windowButtonVisibility");
  }

  g_free(self->style.title_bar_style);
  self->style.title_bar_style = g_strdup(style);
  self->style.window_button_visibility = window_button_visibility;
  window_style_apply(self);
  return success_null();
}

static FlMethodResponse* handle_set_skip_taskbar(WindowPlugin* self,
                                                 FlValue* args) {
  bool value;
  if (!arg_bool(args, "value", &value)) {
    return bad_args_response("setSkipTaskbar", "value");
  }
  GtkWindow* window = window_plugin_get_window(self);
  if (window == nullptr) {
    return not_ready_response();
  }
  gtk_window_set_skip_taskbar_hint(window, value);
  return success_null();
}

static FlMethodResponse* handle_set_rounded_corners(WindowPlugin*,
                                                    FlValue* args) {
  bool value;
  if (!arg_bool(args, "value", &value)) {
    return bad_args_response("setRoundedCorners", "value");
  }
  return success_null();
}

static FlMethodResponse* handle_is_effect_supported(WindowPlugin*,
                                                     FlValue* args) {
  const char* effect;
  if (!arg_string(args, "effect", &effect)) {
    return bad_args_response("isEffectSupported", "effect");
  }
  return success_bool(g_strcmp0(effect, "none") == 0);
}

static FlMethodResponse* handle_set_effect(WindowPlugin*, FlValue* args) {
  const char* effect;
  if (!arg_string(args, "effect", &effect)) {
    return bad_args_response("setEffect", "effect");
  }
  if (g_strcmp0(effect, "none") != 0) {
    return unsupported_response("Linux supports only the \"none\" effect");
  }
  return success_null();
}

static FlMethodResponse* handle_start_dragging(WindowPlugin* self,
                                               FlValue*) {
  return window_drag_start(self);
}

typedef FlMethodResponse* (*MethodHandler)(WindowPlugin*, FlValue*);

typedef struct {
  const char* name;
  MethodHandler handler;
} MethodEntry;

static const MethodEntry kMethods[] = {
    {"ensureInitialized", handle_ensure_initialized},
    {"show", handle_show},
    {"hide", handle_hide},
    {"isVisible", handle_is_visible},
    {"focus", handle_focus},
    {"close", handle_close},
    {"setPreventClose", handle_set_prevent_close},
    {"isMaximized", handle_is_maximized},
    {"maximize", handle_maximize},
    {"unmaximize", handle_unmaximize},
    {"isMinimized", handle_is_minimized},
    {"minimize", handle_minimize},
    {"restore", handle_restore},
    {"isFullScreen", handle_is_full_screen},
    {"setFullScreen", handle_set_full_screen},
    {"getBounds", handle_get_bounds},
    {"setBounds", handle_set_bounds},
    {"isPositionSupported", handle_is_position_supported},
    {"setMinimumSize", handle_set_minimum_size},
    {"isAlwaysOnTop", handle_is_always_on_top},
    {"setAlwaysOnTop", handle_set_always_on_top},
    {"setTitleBarStyle", handle_set_title_bar_style},
    {"setSkipTaskbar", handle_set_skip_taskbar},
    {"setRoundedCorners", handle_set_rounded_corners},
    {"isEffectSupported", handle_is_effect_supported},
    {"setEffect", handle_set_effect},
    {"startDragging", handle_start_dragging},
};

static void window_plugin_handle_method_call(WindowPlugin* self,
                                              FlMethodCall* method_call) {
  const gchar* method = fl_method_call_get_name(method_call);
  FlValue* args = fl_method_call_get_args(method_call);

  g_autoptr(FlMethodResponse) response = nullptr;
  for (const MethodEntry& entry : kMethods) {
    if (g_strcmp0(method, entry.name) == 0) {
      response = entry.handler(self, args);
      break;
    }
  }
  if (response == nullptr) {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

static void method_call_cb(FlMethodChannel*,
                           FlMethodCall* method_call,
                           gpointer user_data) {
  window_plugin_handle_method_call(WINDOW_PLUGIN(user_data), method_call);
}

static gboolean on_window_close(GtkWidget*, GdkEvent*,
                                gpointer data) {
  WindowPlugin* self = WINDOW_PLUGIN(data);
  window_plugin_emit_event(self, "close");
  return self->prevent_close;
}

static gboolean on_window_focus(GtkWidget*, GdkEvent*,
                                gpointer data) {
  window_plugin_emit_event(WINDOW_PLUGIN(data), "focus");
  return FALSE;
}

static gboolean on_window_blur(GtkWidget*, GdkEvent*,
                               gpointer data) {
  window_plugin_emit_event(WINDOW_PLUGIN(data), "blur");
  return FALSE;
}

static void on_window_show(GtkWidget*, gpointer data) {
  window_plugin_emit_event(WINDOW_PLUGIN(data), "show");
}

static void on_window_hide(GtkWidget*, gpointer data) {
  window_plugin_emit_event(WINDOW_PLUGIN(data), "hide");
}

static gboolean on_window_map_event(GtkWidget*, GdkEvent*,
                                    gpointer data) {
  window_geometry_on_map_event(WINDOW_PLUGIN(data));
  return FALSE;
}

static gboolean on_window_configure_event(GtkWidget*, GdkEvent*,
                                          gpointer data) {
  window_geometry_on_configure_event(WINDOW_PLUGIN(data));
  return FALSE;
}

static void send_lifecycle_hidden(WindowPlugin* self) {
  g_autoptr(FlStringCodec) codec = fl_string_codec_new();
  g_autoptr(FlValue) state = fl_value_new_string("AppLifecycleState.hidden");
  g_autoptr(GBytes) message = fl_message_codec_encode_message(
      FL_MESSAGE_CODEC(codec), state, nullptr);
  fl_binary_messenger_send_on_channel(
      fl_plugin_registrar_get_messenger(self->registrar), "flutter/lifecycle",
      message, nullptr, nullptr, nullptr);
}

static gboolean on_window_state_event(GtkWidget*,
                                      GdkEventWindowState* event,
                                      gpointer data) {
  WindowPlugin* self = WINDOW_PLUGIN(data);
  if (self->minimize_requested_at != 0 &&
      (event->changed_mask & GDK_WINDOW_STATE_FOCUSED)) {
    gint64 elapsed = g_get_monotonic_time() - self->minimize_requested_at;
    self->minimize_requested_at = 0;
    if (!(event->new_window_state & GDK_WINDOW_STATE_FOCUSED) &&
        elapsed < kMinimizeFocusLossWindow) {
      send_lifecycle_hidden(self);
    }
  }
  if (event->changed_mask & GDK_WINDOW_STATE_MAXIMIZED) {
    window_plugin_emit_event(
        self, (event->new_window_state & GDK_WINDOW_STATE_MAXIMIZED)
                  ? "maximize"
                  : "unmaximize");
  }
  if (event->changed_mask & GDK_WINDOW_STATE_ICONIFIED) {
    window_plugin_emit_event(
        self, (event->new_window_state & GDK_WINDOW_STATE_ICONIFIED)
                  ? "minimize"
                  : "restore");
  }
  if (event->changed_mask & GDK_WINDOW_STATE_FULLSCREEN) {
    window_plugin_emit_event(
        self, (event->new_window_state & GDK_WINDOW_STATE_FULLSCREEN)
                  ? "enter-full-screen"
                  : "leave-full-screen");
  }
  return FALSE;
}

static void connect_window_signals(WindowPlugin* self, GtkWindow* window) {
  guint i = 0;
  self->window_signal_ids[i++] =
      g_signal_connect(window, "delete-event", G_CALLBACK(on_window_close), self);
  self->window_signal_ids[i++] = g_signal_connect(
      window, "focus-in-event", G_CALLBACK(on_window_focus), self);
  self->window_signal_ids[i++] = g_signal_connect(
      window, "focus-out-event", G_CALLBACK(on_window_blur), self);
  self->window_signal_ids[i++] =
      g_signal_connect(window, "show", G_CALLBACK(on_window_show), self);
  self->window_signal_ids[i++] =
      g_signal_connect(window, "hide", G_CALLBACK(on_window_hide), self);
  self->window_signal_ids[i++] = g_signal_connect(
      window, "map-event", G_CALLBACK(on_window_map_event), self);
  self->window_signal_ids[i++] = g_signal_connect(
      window, "configure-event", G_CALLBACK(on_window_configure_event), self);
  // After the engine's lifecycle monitor, so a minimize reads as hidden.
  self->window_signal_ids[i++] = g_signal_connect_after(
      window, "window-state-event", G_CALLBACK(on_window_state_event), self);
  self->window_signal_count = i;
}

static void window_plugin_dispose(GObject* object) {
  WindowPlugin* self = WINDOW_PLUGIN(object);
  if (activate_target == self) {
    activate_target = nullptr;
  }

  GtkWindow* window = window_plugin_get_window(self);
  if (window != nullptr) {
    for (guint i = 0; i < self->window_signal_count; i++) {
      g_signal_handler_disconnect(window, self->window_signal_ids[i]);
    }
  }
  window_drag_dispose(self);
  window_geometry_dispose(&self->geometry);
  window_style_dispose(&self->style);

  g_clear_object(&self->registrar);
  g_clear_object(&self->channel);

  G_OBJECT_CLASS(window_plugin_parent_class)->dispose(object);
}

static void window_plugin_class_init(WindowPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = window_plugin_dispose;
}

static void window_plugin_init(WindowPlugin* self) {
  window_geometry_init(&self->geometry);
  window_style_init(&self->style);
  window_drag_init(&self->drag);
}

void window_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  WindowPlugin* plugin =
      WINDOW_PLUGIN(g_object_new(window_plugin_get_type(), nullptr));
  plugin->registrar = FL_PLUGIN_REGISTRAR(g_object_ref(registrar));

  GtkWindow* window = window_plugin_get_window(plugin);
  if (window != nullptr) {
    // The engine's own delete-event handler on this widget consumes the
    // signal before this plugin's runs (flutter/engine#40033), so it is
    // disconnected first; matching no handler leaves this a no-op.
    guint handler_id = g_signal_handler_find(
        window, G_SIGNAL_MATCH_DATA, 0, 0, nullptr, nullptr,
        fl_plugin_registrar_get_view(registrar));
    if (handler_id > 0) {
      g_signal_handler_disconnect(window, handler_id);
    }
    connect_window_signals(plugin, window);
  }
  window_drag_connect(plugin);

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  plugin->channel = fl_method_channel_new(
      fl_plugin_registrar_get_messenger(registrar), "window",
      FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(
      plugin->channel, method_call_cb, g_object_ref(plugin), g_object_unref);

  activate_target = plugin;
  g_object_unref(plugin);
}

void window_plugin_activate() {
  if (activate_target != nullptr) {
    window_plugin_emit_event(activate_target, "activate");
  }
}
