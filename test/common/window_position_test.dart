import 'package:fl_clash/common/window.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rust_api/window.dart';

import '../helpers/fake_desktop_window.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const primary = DesktopDisplay(
    bounds: Rect.fromLTWH(0, 0, 1000, 800),
    workArea: Rect.fromLTWH(0, 40, 1000, 760),
    isPrimary: true,
  );
  const secondary = DesktopDisplay(
    bounds: Rect.fromLTWH(1000, 0, 600, 400),
    workArea: Rect.fromLTWH(1000, 0, 600, 400),
  );

  late Offset cursor;

  setUp(() {
    cursor = Offset.zero;
    FakeDesktopWindow(
      (call) => switch (call.method) {
        'getDisplays' => const [secondary, primary],
        'getCursorPosition' => cursor,
        _ => null,
      },
    ).install();
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
