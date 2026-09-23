#ifndef WINDOW_PLUGIN_INTERNAL_H_
#define WINDOW_PLUGIN_INTERNAL_H_

#include "include/window/window_plugin.h"
#include "window_drag.h"
#include "window_geometry.h"
#include "window_style.h"

G_BEGIN_DECLS

#define WINDOW_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), window_plugin_get_type(), WindowPlugin))

struct _WindowPlugin {
  GObject parent_instance;
  FlPluginRegistrar* registrar;
  FlMethodChannel* channel;
  bool prevent_close;
  bool always_on_top;
  gulong window_signal_ids[8];
  guint window_signal_count;
  WindowGeometryState geometry;
  WindowStyle style;
  WindowDragState drag;
};

GtkWindow* window_plugin_get_window(WindowPlugin* self);
GdkWindow* window_plugin_get_gdk_window(WindowPlugin* self);
void window_plugin_emit_event(WindowPlugin* self, const char* name);

G_END_DECLS

#endif  // WINDOW_PLUGIN_INTERNAL_H_
