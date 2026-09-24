import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:window/window.dart';

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
}

class _SelfRemovingListener with WindowListener {
  int calls = 0;

  @override
  void onWindowFocus() {
    calls++;
    desktopWindow.removeListener(this);
  }
}

void main() {
  const channel = MethodChannel('window');
  const codec = StandardMethodCodec();

  TestWidgetsFlutterBinding.ensureInitialized();

  late List<MethodCall> calls;
  Object? Function(MethodCall call)? responder;

  Future<void> emit(Object? name) {
    return TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
          channel.name,
          codec.encodeMethodCall(MethodCall('onEvent', {'name': name})),
          (_) {},
        );
  }

  setUp(() {
    calls = <MethodCall>[];
    responder = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return responder?.call(call);
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    for (final listener in desktopWindow.listeners) {
      desktopWindow.removeListener(listener);
    }
  });

  test('every wire name maps back to its event', () {
    for (final event in WindowEvent.values) {
      expect(WindowEvent.fromWireName(event.wireName), event);
    }
    expect(WindowEvent.fromWireName('nope'), isNull);
    expect(WindowEvent.fromWireName(null), isNull);
  });

  test(
    'events reach the generic and the dedicated callback in order',
    () async {
      final listener = _RecordingListener();
      desktopWindow.addListener(listener);

      await emit('close');
      await emit('geometry-changed');
      await emit('should-terminate');
      await emit('activate');

      expect(listener.log, [
        'event:close',
        'close',
        'event:geometryChanged',
        'geometryChanged',
        'event:shouldTerminate',
        'shouldTerminate',
        'event:activate',
        'activate',
      ]);
    },
  );

  test('unknown and malformed events are ignored', () async {
    final listener = _RecordingListener();
    desktopWindow.addListener(listener);

    await emit('resized');
    await emit(null);
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
          channel.name,
          codec.encodeMethodCall(const MethodCall('onEvent', 'close')),
          (_) {},
        );

    expect(listener.log, isEmpty);
  });

  test('a listener removed while dispatching is skipped', () async {
    final first = _SelfRemovingListener();
    final second = _RecordingListener();
    desktopWindow.addListener(first);
    desktopWindow.addListener(second);

    await emit('focus');
    await emit('focus');

    expect(first.calls, 1);
    expect(second.log, ['event:focus', 'event:focus']);
    expect(desktopWindow.listeners, [second]);
  });

  test('effect tints cross the channel as ARGB integers', () async {
    await desktopWindow.setEffect(
      WindowEffect.acrylic,
      tint: const Color(0xFF445566),
      brightness: Brightness.dark,
    );
    await desktopWindow.setEffect(WindowEffect.none);

    expect(calls.map((call) => call.method), ['setEffect', 'setEffect']);
    expect(calls[0].arguments, {
      'effect': 'acrylic',
      'tint': 0xFF445566,
      'brightness': 'dark',
    });
    expect(calls[1].arguments, {
      'effect': 'none',
      'tint': null,
      'brightness': null,
    });
  });

  test('bounds carry only the fields that were given', () async {
    await desktopWindow.setPosition(const Offset(10, 20));
    await desktopWindow.setSize(const Size(300, 400));
    await desktopWindow.setMinimumSize(const Size(380, 400));

    expect(calls[0].method, 'setBounds');
    expect(calls[0].arguments, {'x': 10.0, 'y': 20.0});
    expect(calls[1].arguments, {'width': 300.0, 'height': 400.0});
    expect(calls[2].method, 'setMinimumSize');
    expect(calls[2].arguments, {'width': 380.0, 'height': 400.0});
  });

  test('getBounds decodes the platform rectangle', () async {
    responder = (call) => call.method == 'getBounds'
        ? {'x': 1, 'y': 2.5, 'width': 300, 'height': 400}
        : null;

    expect(
      await desktopWindow.getBounds(),
      const Rect.fromLTWH(1, 2.5, 300, 400),
    );
    expect(calls.single.arguments, isNull);
  });

  test('enum arguments use their names', () async {
    await desktopWindow.setTitleBarStyle(TitleBarStyle.hidden);
    await desktopWindow.setRoundedCorners(false);
    await desktopWindow.maximize();

    expect(calls[0].arguments, {
      'style': 'hidden',
      'windowButtonVisibility': true,
    });
    expect(calls[1].arguments, {'value': false});
    expect(calls[2].method, 'maximize');
    expect(calls[2].arguments, isNull);
  });

  test('a query the platform answers with null is a PlatformException', () {
    expect(
      desktopWindow.isVisible(),
      throwsA(
        isA<PlatformException>().having((e) => e.code, 'code', 'bad_result'),
      ),
    );
  });

  test('capability queries pass the platform answer through', () async {
    responder = (call) => call.method == 'isPositionSupported';

    expect(await desktopWindow.isPositionSupported(), isTrue);
    expect(await desktopWindow.isEffectSupported(WindowEffect.mica), isFalse);
    expect(calls.last.arguments, {'effect': 'mica'});
  });
}
