#include "window_style.h"

#include <gtk/gtk.h>

#include <cstring>

#include "window_plugin_internal.h"

static gboolean is_header_bar(GtkWidget* widget) {
  return widget != nullptr &&
         (GTK_IS_HEADER_BAR(widget) ||
          g_str_has_suffix(G_OBJECT_TYPE_NAME(widget), "HeaderBar"));
}

static GtkWidget* find_header_bar(GtkWidget* widget) {
  if (is_header_bar(widget)) {
    return widget;
  }

  if (GTK_IS_CONTAINER(widget)) {
    g_autoptr(GList) children =
        gtk_container_get_children(GTK_CONTAINER(widget));
    for (GList* l = children; l != nullptr; l = l->next) {
      GtkWidget* header_bar = find_header_bar(GTK_WIDGET(l->data));
      if (header_bar != nullptr) {
        return header_bar;
      }
    }
  }

  return nullptr;
}

static GtkWidget* get_header_bar(GtkWindow* window) {
  GtkWidget* titlebar = gtk_window_get_titlebar(window);
  if (is_header_bar(titlebar)) {
    return titlebar;
  }
  return find_header_bar(GTK_WIDGET(window));
}

void window_style_init(WindowStyle* style) {
  memset(style, 0, sizeof(*style));
  style->window_button_visibility = true;
}

void window_style_dispose(WindowStyle* style) {
  g_free(style->title_bar_style);
  style->title_bar_style = nullptr;
}

void window_style_apply(WindowPlugin* self) {
  GtkWindow* window = window_plugin_get_window(self);
  if (window == nullptr) {
    return;
  }

  gboolean normal = g_strcmp0(self->style.title_bar_style, "hidden") != 0;

  GtkWidget* header_bar = get_header_bar(window);
  if (header_bar != nullptr) {
    gtk_widget_set_visible(header_bar, normal);
    if (GTK_IS_HEADER_BAR(header_bar)) {
      gtk_header_bar_set_show_close_button(
          GTK_HEADER_BAR(header_bar), self->style.window_button_visibility);
    }
  } else if (gtk_window_get_title(window) != nullptr) {
    gtk_window_set_decorated(window, normal);
  }

  if (normal) {
    gtk_window_set_decorated(window, true);
  }
}
