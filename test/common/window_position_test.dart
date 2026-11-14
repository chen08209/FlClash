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
  late List<DesktopDisplay> displays;

  setUp(() {
    cursor = Offset.zero;
    displays = const [secondary, primary];
    FakeDesktopWindow(
      (call) => switch (call.method) {
        'getDisplays' => displays,
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

  // Windows reports every display in physical pixels over the window's
  // current scale; the window takes the target display's own scale once it
  // lands there.
  group('mixed scales', () {
    test('centers on a 150% display right of a 100% primary', () async {
      displays = const [
        DesktopDisplay(
          bounds: Rect.fromLTWH(0, 0, 1920, 1080),
          workArea: Rect.fromLTWH(0, 0, 1920, 1040),
          isPrimary: true,
        ),
        DesktopDisplay(
          bounds: Rect.fromLTWH(1920, 0, 2560, 1440),
          workArea: Rect.fromLTWH(1920, 0, 2560, 1400),
          scaleFactor: 1.5,
        ),
      ];
      cursor = const Offset(3000, 500);

      final position = await calcWindowPosition(
        const Size(800, 600),
        Alignment.center,
        currentScale: 1,
      );

      expect(position, const Offset(2600, 250));
    });

    test('centers on a 100% display right of a 150% primary', () async {
      displays = const [
        DesktopDisplay(
          bounds: Rect.fromLTWH(0, 0, 1920, 1080),
          workArea: Rect.fromLTWH(0, 0, 1920, 1040),
          scaleFactor: 1.5,
          isPrimary: true,
        ),
        DesktopDisplay(
          bounds: Rect.fromLTWH(1920, 0, 1280, 720),
          workArea: Rect.fromLTWH(1920, 0, 1280, 700),
        ),
      ];
      cursor = const Offset(2500, 300);

      final position = await calcWindowPosition(
        const Size(800, 600),
        Alignment.center,
        currentScale: 1.5,
      );

      expect(position.dx * 1.5, closeTo(2880 + 560, 0.001));
      expect(position.dy * 1.5, closeTo(225, 0.001));
    });

    test('centers on a display left of and above the primary', () async {
      displays = const [
        DesktopDisplay(
          bounds: Rect.fromLTWH(0, 0, 1920, 1080),
          workArea: Rect.fromLTWH(0, 0, 1920, 1040),
          isPrimary: true,
        ),
        DesktopDisplay(
          bounds: Rect.fromLTWH(-2560, -200, 2560, 1440),
          workArea: Rect.fromLTWH(-2560, -200, 2560, 1400),
          scaleFactor: 1.5,
        ),
      ];
      cursor = const Offset(-1000, 300);

      final position = await calcWindowPosition(
        const Size(800, 600),
        Alignment.center,
        currentScale: 1,
      );

      expect(position, const Offset(-1880, 50));
    });

    test('centers on a 100% display above a 125% primary', () async {
      displays = const [
        DesktopDisplay(
          bounds: Rect.fromLTWH(0, 0, 2048, 1152),
          workArea: Rect.fromLTWH(0, 0, 2048, 1120),
          scaleFactor: 1.25,
          isPrimary: true,
        ),
        DesktopDisplay(
          bounds: Rect.fromLTWH(0, -864, 1536, 864),
          workArea: Rect.fromLTWH(0, -864, 1536, 864),
        ),
      ];
      cursor = const Offset(700, -400);

      final position = await calcWindowPosition(
        const Size(800, 600),
        Alignment.center,
        currentScale: 1.25,
      );

      expect(position.dx * 1.25, closeTo((1920 - 800) / 2, 0.001));
      expect(position.dy * 1.25, closeTo(-1080 + (1080 - 600) / 2, 0.001));
    });

    test('keeps the window size on the display it already has', () async {
      displays = const [
        DesktopDisplay(
          bounds: Rect.fromLTWH(0, 0, 1920, 1080),
          workArea: Rect.fromLTWH(0, 0, 1920, 1040),
          isPrimary: true,
        ),
        DesktopDisplay(
          bounds: Rect.fromLTWH(1920, 0, 2560, 1440),
          workArea: Rect.fromLTWH(1920, 0, 2560, 1400),
          scaleFactor: 1.5,
        ),
      ];
      cursor = const Offset(100, 100);

      final position = await calcWindowPosition(
        const Size(800, 600),
        Alignment.center,
        currentScale: 1,
      );

      expect(position, const Offset(560, 220));
    });
  });
}
