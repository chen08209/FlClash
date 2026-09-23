#ifndef WINDOW_DRAG_H_
#define WINDOW_DRAG_H_

#include "include/window/window_plugin.h"

G_BEGIN_DECLS

typedef struct {
  GdkEventButton event_button;
  gulong mouse_press_hook_id;
  gulong event_after_handler_id;
  GtkWidget* event_box;
  bool is_dragging;
} WindowDragState;

void window_drag_init(WindowDragState* state);
void window_drag_dispose(WindowPlugin* self);
void window_drag_connect(WindowPlugin* self);

FlMethodResponse* window_drag_start(WindowPlugin* self);

G_END_DECLS

#endif  // WINDOW_DRAG_H_
