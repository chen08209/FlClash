#ifndef WINDOW_STYLE_H_
#define WINDOW_STYLE_H_

#include "include/window/window_plugin.h"

G_BEGIN_DECLS

typedef struct {
  gchar* title_bar_style;  // owned; nullptr behaves as "normal"
  bool window_button_visibility;
} WindowStyle;

void window_style_init(WindowStyle* style);
void window_style_dispose(WindowStyle* style);

void window_style_apply(WindowPlugin* self);

G_END_DECLS

#endif  // WINDOW_STYLE_H_
