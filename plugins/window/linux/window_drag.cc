#include "window_drag.h"

#include <gtk/gtk.h>

#include <cstring>

#include "window_plugin_internal.h"

static void collect_child(GtkWidget* widget, gpointer client_data) {
  GList** children = static_cast<GList**>(client_data);
  *children = g_list_prepend(*children, widget);
}

static void find_event_box(WindowPlugin* self, GtkWidget* widget) {
  g_autoptr(GList) children = nullptr;
  gtk_container_forall(GTK_CONTAINER(widget), collect_child, &children);
  GtkWidget* event_box = nullptr;
  for (GList* l = children; l != nullptr; l = l->next) {
    GtkWidget* child = GTK_WIDGET(l->data);
    if (GTK_IS_EVENT_BOX(child)) {
      event_box = child;
    }
  }
  if (event_box != nullptr) {
    self->drag.event_box = event_box;
    g_object_add_weak_pointer(G_OBJECT(event_box),
                              reinterpret_cast<gpointer*>(&self->drag.event_box));
  }
}

static void emit_button_release(WindowPlugin* self) {
  if (self->drag.event_box == nullptr) {
    return;
  }
  GdkWindow* window = gtk_widget_get_window(self->drag.event_box);
  if (window == nullptr) {
    return;
  }
  GdkEventButton* event =
      reinterpret_cast<GdkEventButton*>(gdk_event_new(GDK_BUTTON_RELEASE));
  event->window = GDK_WINDOW(g_object_ref(window));
  event->send_event = TRUE;
  event->x = self->drag.event_button.x;
  event->y = self->drag.event_button.y;
  event->button = self->drag.event_button.button;
  event->time = self->drag.event_button.time;

  gboolean result;
  g_signal_emit_by_name(self->drag.event_box, "button-release-event", event,
                        &result);
  gdk_event_free(reinterpret_cast<GdkEvent*>(event));
}

static gboolean on_event_after(GtkWidget*,
                               GdkEvent* event,
                               gpointer data) {
  WindowPlugin* self = WINDOW_PLUGIN(data);
  if (event->type == GDK_ENTER_NOTIFY && self->drag.is_dragging) {
    self->drag.is_dragging = false;
    emit_button_release(self);
  }
  return FALSE;
}

// A global hook, since the button-press event is consumed by Flutter's own
// view before it reaches any per-window signal handler.
static gboolean on_mouse_press(GSignalInvocationHint*,
                               guint,
                               const GValue* param_values,
                               gpointer data) {
  WindowPlugin* self = WINDOW_PLUGIN(data);
  GObject* emitter = G_OBJECT(g_value_get_object(param_values + 0));
  FlView* view = fl_plugin_registrar_get_view(self->registrar);
  if (view == nullptr || (emitter != G_OBJECT(view) &&
                          emitter != G_OBJECT(self->drag.event_box))) {
    return TRUE;
  }
  GdkEventButton* event =
      static_cast<GdkEventButton*>(g_value_get_boxed(param_values + 1));
  memcpy(&self->drag.event_button, event, sizeof(self->drag.event_button));
  return TRUE;
}

void window_drag_init(WindowDragState* state) {
  memset(state, 0, sizeof(*state));
}

void window_drag_connect(WindowPlugin* self) {
  GtkWindow* window = window_plugin_get_window(self);
  if (window != nullptr) {
    self->drag.event_after_handler_id =
        g_signal_connect(window, "event-after", G_CALLBACK(on_event_after), self);
    find_event_box(self, GTK_WIDGET(fl_plugin_registrar_get_view(self->registrar)));
  }

  self->drag.mouse_press_hook_id = g_signal_add_emission_hook(
      g_signal_lookup("button-press-event", GTK_TYPE_WIDGET), 0,
      on_mouse_press, self, nullptr);
}

void window_drag_dispose(WindowPlugin* self) {
  if (self->drag.mouse_press_hook_id != 0) {
    g_signal_remove_emission_hook(
        g_signal_lookup("button-press-event", GTK_TYPE_WIDGET),
        self->drag.mouse_press_hook_id);
    self->drag.mouse_press_hook_id = 0;
  }

  if (self->drag.event_box != nullptr) {
    g_object_remove_weak_pointer(
        G_OBJECT(self->drag.event_box),
        reinterpret_cast<gpointer*>(&self->drag.event_box));
    self->drag.event_box = nullptr;
  }

  GtkWindow* window = window_plugin_get_window(self);
  if (window != nullptr && self->drag.event_after_handler_id != 0) {
    g_signal_handler_disconnect(window, self->drag.event_after_handler_id);
  }
  self->drag.event_after_handler_id = 0;
}

FlMethodResponse* window_drag_start(WindowPlugin* self) {
  GtkWindow* window = window_plugin_get_window(self);
  if (window == nullptr) {
    return FL_METHOD_RESPONSE(fl_method_error_response_new(
        "not_ready", "Window is not available", nullptr));
  }

  GdkDisplay* display = gdk_screen_get_display(gtk_window_get_screen(window));
  GdkDevice* device = gdk_seat_get_pointer(gdk_display_get_default_seat(display));

  gint root_x, root_y;
  gdk_device_get_position(device, nullptr, &root_x, &root_y);
  gtk_window_begin_move_drag(window, GDK_BUTTON_PRIMARY, root_x, root_y,
                             self->drag.event_button.time);
  self->drag.is_dragging = true;

  g_autoptr(FlValue) result = fl_value_new_null();
  return FL_METHOD_RESPONSE(fl_method_success_response_new(result));
}
