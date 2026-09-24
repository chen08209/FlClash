#include "window_geometry.h"

#include <gtk/gtk.h>

#include <cstring>

#include "window_plugin_internal.h"

// "geometry-changed" waits for the configure-event stream to go quiet.
static const guint kSettleMilliseconds = 150;
static const int kMaxRestoreCorrections = 5;

static gboolean is_geometry_owned_by_wm(WindowPlugin* self) {
  GtkWindow* window = window_plugin_get_window(self);
  if (window == nullptr) {
    return true;
  }
  if (gtk_window_is_maximized(window)) {
    return true;
  }

  GdkWindow* gdk_window = window_plugin_get_gdk_window(self);
  if (gdk_window == nullptr) {
    return false;
  }

  return gdk_window_get_state(gdk_window) & GDK_WINDOW_STATE_FULLSCREEN;
}

void window_geometry_init(WindowGeometryState* state) {
  memset(state, 0, sizeof(*state));
}

void window_geometry_dispose(WindowGeometryState* state) {
  if (state->settle_timeout_id != 0) {
    g_source_remove(state->settle_timeout_id);
    state->settle_timeout_id = 0;
  }
  if (state->restore_timeout_id != 0) {
    g_source_remove(state->restore_timeout_id);
    state->restore_timeout_id = 0;
  }
}

static void apply_saved_geometry(WindowPlugin* self) {
  GtkWindow* window = window_plugin_get_window(self);
  if (window == nullptr) {
    return;
  }
  gtk_window_move(window, self->geometry.saved_x, self->geometry.saved_y);
  gtk_window_resize(window, self->geometry.saved_width,
                    self->geometry.saved_height);
}

void window_geometry_on_hide(WindowPlugin* self) {
  GtkWindow* window = window_plugin_get_window(self);
  if (window == nullptr) {
    return;
  }

  // GTK drops an unmapped window's placement; reapplied on the next map.
  self->geometry.has_saved_geometry = !is_geometry_owned_by_wm(self);
  if (self->geometry.has_saved_geometry) {
    gtk_window_get_position(window, &self->geometry.saved_x,
                            &self->geometry.saved_y);
    gtk_window_get_size(window, &self->geometry.saved_width,
                        &self->geometry.saved_height);
  }

  gtk_widget_hide(GTK_WIDGET(window));
  if (self->geometry.has_saved_geometry) {
    apply_saved_geometry(self);
  }
}

static gboolean on_restore_settled(gpointer data) {
  WindowPlugin* self = WINDOW_PLUGIN(data);
  self->geometry.restore_timeout_id = 0;
  if (self->geometry.has_saved_geometry) {
    self->geometry.has_saved_geometry = false;
    apply_saved_geometry(self);
  }
  return G_SOURCE_REMOVE;
}

static bool is_saved_position_on_monitor(WindowPlugin* self) {
  GtkWindow* window = window_plugin_get_window(self);
  if (window == nullptr) {
    return false;
  }
  GdkDisplay* display = gdk_screen_get_display(gtk_window_get_screen(window));
  GdkRectangle saved = {self->geometry.saved_x, self->geometry.saved_y,
                        self->geometry.saved_width,
                        self->geometry.saved_height};
  int n_monitors = gdk_display_get_n_monitors(display);
  for (int i = 0; i < n_monitors; i++) {
    GdkRectangle workarea;
    gdk_monitor_get_workarea(gdk_display_get_monitor(display, i), &workarea);
    if (gdk_rectangle_intersect(&saved, &workarea, nullptr)) {
      return true;
    }
  }
  return false;
}

static void center_on_primary_monitor(WindowPlugin* self, GtkWindow* window) {
  GdkDisplay* display = gdk_screen_get_display(gtk_window_get_screen(window));
  GdkMonitor* monitor = gdk_display_get_primary_monitor(display);
  if (monitor == nullptr) {
    monitor = gdk_display_get_monitor(display, 0);
  }
  gint width = self->geometry.saved_width;
  gint height = self->geometry.saved_height;
  gtk_window_resize(window, width, height);
  if (monitor == nullptr) {
    return;
  }
  GdkRectangle workarea;
  gdk_monitor_get_workarea(monitor, &workarea);
  gtk_window_move(window, workarea.x + MAX(0, (workarea.width - width) / 2),
                  workarea.y + MAX(0, (workarea.height - height) / 2));
}

// The window manager may place the window after this handler restored the
// geometry, so the restore stays open until the placement settles.
void window_geometry_on_map_event(WindowPlugin* self) {
  if (!self->geometry.has_saved_geometry) {
    return;
  }
  if (!is_saved_position_on_monitor(self)) {
    self->geometry.has_saved_geometry = false;
    GtkWindow* window = window_plugin_get_window(self);
    if (window != nullptr) {
      center_on_primary_monitor(self, window);
    }
    return;
  }
  self->geometry.restore_corrections = 0;
  apply_saved_geometry(self);
  if (self->geometry.restore_timeout_id != 0) {
    g_source_remove(self->geometry.restore_timeout_id);
  }
  self->geometry.restore_timeout_id =
      g_timeout_add(kSettleMilliseconds, on_restore_settled, self);
}

static void correct_restored_placement(WindowPlugin* self) {
  if (!self->geometry.has_saved_geometry ||
      self->geometry.restore_timeout_id == 0 ||
      self->geometry.restore_corrections >= kMaxRestoreCorrections) {
    return;
  }
  GtkWindow* window = window_plugin_get_window(self);
  if (window == nullptr) {
    return;
  }
  gint x, y;
  gtk_window_get_position(window, &x, &y);
  if (x == self->geometry.saved_x && y == self->geometry.saved_y) {
    return;
  }
  self->geometry.restore_corrections++;
  apply_saved_geometry(self);
}

static gboolean on_settle_timeout(gpointer data) {
  WindowPlugin* self = WINDOW_PLUGIN(data);
  self->geometry.settle_timeout_id = 0;

  GtkWindow* window = window_plugin_get_window(self);
  if (window == nullptr) {
    return G_SOURCE_REMOVE;
  }

  gint x, y, width, height;
  gtk_window_get_position(window, &x, &y);
  gtk_window_get_size(window, &width, &height);

  bool changed = self->geometry.has_settled_geometry &&
                 (x != self->geometry.settled_x ||
                  y != self->geometry.settled_y ||
                  width != self->geometry.settled_width ||
                  height != self->geometry.settled_height);

  self->geometry.settled_x = x;
  self->geometry.settled_y = y;
  self->geometry.settled_width = width;
  self->geometry.settled_height = height;
  self->geometry.has_settled_geometry = true;

  if (changed) {
    window_plugin_emit_event(self, "geometry-changed");
  }
  return G_SOURCE_REMOVE;
}

void window_geometry_on_configure_event(WindowPlugin* self) {
  correct_restored_placement(self);
  if (self->geometry.settle_timeout_id != 0) {
    g_source_remove(self->geometry.settle_timeout_id);
  }
  self->geometry.settle_timeout_id =
      g_timeout_add(kSettleMilliseconds, on_settle_timeout, self);
}
