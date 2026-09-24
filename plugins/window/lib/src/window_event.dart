enum WindowEvent {
  close('close'),
  focus('focus'),
  blur('blur'),
  show('show'),
  hide('hide'),
  maximize('maximize'),
  unmaximize('unmaximize'),
  minimize('minimize'),
  restore('restore'),
  geometryChanged('geometry-changed'),
  enterFullScreen('enter-full-screen'),
  leaveFullScreen('leave-full-screen'),
  shouldTerminate('should-terminate'),
  activate('activate');

  const WindowEvent(this.wireName);

  /// The name the platform side sends on the method channel.
  final String wireName;

  static WindowEvent? fromWireName(Object? name) {
    for (final event in values) {
      if (event.wireName == name) {
        return event;
      }
    }
    return null;
  }
}
