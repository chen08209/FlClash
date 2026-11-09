import 'dart:ui' as ui;

import 'package:fl_clash/widgets/subscription_usage_cloud.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_ui/prism_ui.dart';

import '../helpers/test_app.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('cloud water shows remaining quota in ${brightness.name}', (
      tester,
    ) async {
      final theme = ThemeData(brightness: brightness);
      for (final usage in [-0.2, 0.0, 0.5, 1.0, 1.2]) {
        await tester.pumpWidget(
          HostApp(
            theme: theme,
            themeMode: ThemeMode.light,
            home: SubscriptionUsageCloud(usage: usage),
          ),
        );
        final paint = tester.widget<CustomPaint>(
          find.descendant(
            of: find.byType(SubscriptionUsageCloud),
            matching: find.byType(CustomPaint),
          ),
        );
        final bytes = (await tester.runAsync(() async {
          final recorder = ui.PictureRecorder();
          paint.painter!.paint(Canvas(recorder), const Size(40, 40));
          final picture = recorder.endRecording();
          final image = await picture.toImage(40, 40);
          try {
            return await image.toByteData(format: ui.ImageByteFormat.rawRgba);
          } finally {
            image.dispose();
            picture.dispose();
          }
        }))!;

        int alphaAt(int y) => bytes.getUint8((y * 40 + 20) * 4 + 3);
        expect(alphaAt(0), 0);
        expect(alphaAt(15), usage <= 0 ? 255 : closeTo(38, 1));
        expect(alphaAt(25), usage < 1 ? 255 : closeTo(38, 1));
        if (usage < 1) {
          final primary = theme.colorScheme.primary.toARGB32();
          for (var channel = 0; channel < 3; channel++) {
            expect(
              bytes.getUint8((25 * 40 + 20) * 4 + channel),
              (primary >> (16 - channel * 8)) & 0xff,
            );
          }
        }
      }
    });
  }
}
