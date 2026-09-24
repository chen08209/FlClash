#ifndef WINDOW_GEOMETRY_H_
#define WINDOW_GEOMETRY_H_

#include "include/window/window_plugin.h"

G_BEGIN_DECLS

typedef struct {
  bool has_saved_geometry;
  gint saved_x;
  gint saved_y;
  gint saved_width;
  gint saved_height;
  guint restore_timeout_id;
  int restore_corrections;

  bool has_settled_geometry;
  gint settled_x;
  gint settled_y;
  gint settled_width;
  gint settled_height;
  guint settle_timeout_id;
} WindowGeometryState;

void window_geometry_init(WindowGeometryState* state);
void window_geometry_dispose(WindowGeometryState* state);

void window_geometry_on_hide(WindowPlugin* self);
void window_geometry_on_map_event(WindowPlugin* self);
void window_geometry_on_configure_event(WindowPlugin* self);

G_END_DECLS

#endif  // WINDOW_GEOMETRY_H_
