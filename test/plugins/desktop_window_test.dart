import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rust_api/window.dart';

import '../helpers/fake_desktop_window.dart';

class _RecordingListener with WindowListener {
  final List<String> log = <String>[];

  @override
  void onWindowEvent(WindowEvent event) => log.add('event:${event.name}');

  @override
  void onWindowClose() => log.add('close');

  @override
  void onWindowGeometryChanged() => log.add('geometryChanged');

  @override
  void onWindowShouldTerminate() => log.add('shouldTerminate');

  @override
  void onWindowActivate() => log.add('activate');

  @override
  void onWindowScreensUnseen() => log.add('screensUnseen');

  @override
  void onWindowScreensSeen() => log.add('screensSeen');
}

class _SelfRemovingListener with WindowListener {
  int calls = 0;

  @override
  void onWindowMaximize() {
    calls++;
    desktopWindow.removeListener(this);
  }
}

void main() {
  late FakeDesktopWindow window;

  setUp(() => window = FakeDesktopWindow().install());

  test('every native signal is a window event or a lifecycle state', () {
    for (final signal in WindowSignal.values) {
      final lifecycle = lifecycleOfSignal(signal);
      if (lifecycle == null) {
        expect(WindowEvent.values.byName(signal.name).name, signal.name);
      } else {
        expect(
          signal.name,
          'lifecycle${lifecycle.name[0].toUpperCase()}'
          '${lifecycle.name.substring(1)}',
        );
      }
    }
    expect(
      lifecycleOfSignal(WindowSignal.lifecycleHidden),
      AppLifecycleState.hidden,
    );
  });

  test('events reach the generic and the dedicated callback in order', () {
    final listener = _RecordingListener();
    window.addListener(listener);

    window
      ..emit(WindowEvent.close)
      ..emit(WindowEvent.geometryChanged)
      ..emit(WindowEvent.shouldTerminate)
      ..emit(WindowEvent.activate)
      ..emit(WindowEvent.screensUnseen)
      ..emit(WindowEvent.screensSeen);

    expect(listener.log, [
      'event:close',
      'close',
      'event:geometryChanged',
      'geometryChanged',
      'event:shouldTerminate',
      'shouldTerminate',
      'event:activate',
      'activate',
      'event:screensUnseen',
      'screensUnseen',
      'event:screensSeen',
      'screensSeen',
    ]);
  });

  test('a listener removed while dispatching is skipped', () {
    final first = _SelfRemovingListener();
    final second = _RecordingListener();
    window
      ..addListener(first)
      ..addListener(second)
      ..emit(WindowEvent.maximize)
      ..emit(WindowEvent.maximize);

    expect(first.calls, 1);
    expect(second.log, ['event:maximize', 'event:maximize']);
    expect(window.listeners, [second]);
  });
}
