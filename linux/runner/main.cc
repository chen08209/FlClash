#include "my_application.h"

#ifdef GDK_WINDOWING_X11
#include <X11/Xlib.h>
#endif

int main(int argc, char** argv) {
#ifdef GDK_WINDOWING_X11
  // libX11 enables its own locking only from 1.8 on. Nothing in the app calls
  // libX11 off the main thread now that the tray speaks D-Bus, but a plugin
  // that did would abort the process on an older release.
  XInitThreads();
#endif
  g_autoptr(MyApplication) app = my_application_new();
  return g_application_run(G_APPLICATION(app), argc, argv);
}
