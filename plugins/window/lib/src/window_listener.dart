import 'package:window/src/window_event.dart';

abstract mixin class WindowListener {
  void onWindowClose() {}

  void onWindowFocus() {}

  void onWindowBlur() {}

  void onWindowShow() {}

  void onWindowHide() {}

  void onWindowMaximize() {}

  void onWindowUnmaximize() {}

  void onWindowMinimize() {}

  void onWindowRestore() {}

  void onWindowGeometryChanged() {}

  void onWindowEnterFullScreen() {}

  void onWindowLeaveFullScreen() {}

  void onWindowShouldTerminate() {}

  void onWindowActivate() {}

  void onWindowEvent(WindowEvent event) {}
}
