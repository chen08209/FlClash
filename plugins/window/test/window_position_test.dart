import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show Alignment;
import 'package:flutter_test/flutter_test.dart';
import 'package:window/window.dart';

void main() {
  const channel = MethodChannel('dev.leanflutter.plugins/screen_retriever');

  TestWidgetsFlutterBinding.ensureInitialized();

  Map<String, Object?> display({
    required String id,
    required Offset position,
    required Size size,
    Size? visibleSize,
    Offset? visiblePosition,
  }) {
    return {
      'id': id,
      'name': id,
      'size': {'width': size.width, 'height': size.height},
      'visibleSize': {
        'width': (visibleSize ?? size).width,
        'height': (visibleSize ?? size).height,
      },
      'visiblePosition': {
        'dx': (visiblePosition ?? position).dx,
        'dy': (visiblePosition ?? position).dy,
      },
      'scaleFactor': 1.0,
    };
  }

  late Offset cursor;
  final primary = display(
    id: 'primary',
    position: Offset.zero,
    size: const Size(1000, 800),
    visibleSize: const Size(1000, 760),
    visiblePosition: const Offset(0, 40),
  );
  final secondary = display(
    id: 'secondary',
    position: const Offset(1000, 0),
    size: const Size(600, 400),
  );

  setUp(() {
    cursor = Offset.zero;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          return switch (call.method) {
            'getPrimaryDisplay' => primary,
            'getAllDisplays' => {
              'displays': [primary, secondary],
            },
            'getCursorScreenPoint' => {'dx': cursor.dx, 'dy': cursor.dy},
            _ => null,
          };
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test(
    'centers inside the work area of the display under the cursor',
    () async {
      cursor = const Offset(100, 100);

      final position = await calcWindowPosition(
        const Size(400, 300),
        Alignment.center,
      );

      expect(position, const Offset(300, 270));
    },
  );

  test('corner alignments hug the work area edges', () async {
    cursor = const Offset(1200, 100);

    expect(
      await calcWindowPosition(const Size(200, 100), Alignment.topLeft),
      const Offset(1000, 0),
    );
    expect(
      await calcWindowPosition(const Size(200, 100), Alignment.bottomRight),
      const Offset(1400, 300),
    );
  });

  test(
    'falls back to the primary display when the cursor is nowhere',
    () async {
      cursor = const Offset(-500, -500);

      expect(
        await calcWindowPosition(const Size(1000, 760), Alignment.center),
        const Offset(0, 40),
      );
    },
  );
}
