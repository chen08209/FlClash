abstract mixin class WindowExtListener {
  void onTaskbarCreated() {}

  Future<void> onWindowActivated() async {}

  void onShouldTerminate() {}
}
