#ifndef FLUTTER_PLUGIN_WINDOW_PLUGIN_H_
#define FLUTTER_PLUGIN_WINDOW_PLUGIN_H_

#include <flutter_linux/flutter_linux.h>

G_BEGIN_DECLS

#ifdef FLUTTER_PLUGIN_IMPL
#define FLUTTER_PLUGIN_EXPORT __attribute__((visibility("default")))
#else
#define FLUTTER_PLUGIN_EXPORT
#endif

typedef struct _WindowPlugin WindowPlugin;
typedef struct {
  GObjectClass parent_class;
} WindowPluginClass;

FLUTTER_PLUGIN_EXPORT GType window_plugin_get_type();

FLUTTER_PLUGIN_EXPORT void window_plugin_register_with_registrar(
    FlPluginRegistrar* registrar);

// Reports "activate" to Dart, targeting the most recently registered plugin.
FLUTTER_PLUGIN_EXPORT void window_plugin_activate();

G_END_DECLS

#endif  // FLUTTER_PLUGIN_WINDOW_PLUGIN_H_
