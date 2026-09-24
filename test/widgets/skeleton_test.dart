import 'package:fl_clash/widgets/skeleton.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';

void main() {
  const style = TextStyle(fontSize: 14, height: 20 / 14);

  Widget line({bool disableAnimations = false}) => TestApp(
    child: MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: const Material(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('203.0.113.7', style: style),
              SkeletonText(width: 104, style: style),
            ],
          ),
        ),
      ),
    ),
  );

  testWidgets('takes the height of the line it stands in for', (tester) async {
    await tester.pumpWidget(line());

    expect(
      tester.getSize(find.byType(SkeletonText)),
      Size(104, tester.getSize(find.text('203.0.113.7')).height),
    );
  });

  testWidgets('pulses without rebuilding or repainting', (tester) async {
    await tester.pumpWidget(line());
    await tester.pump(const Duration(milliseconds: 100));
    final opacity = tester
        .widget<FadeTransition>(
          find.descendant(
            of: find.byType(SkeletonText),
            matching: find.byType(FadeTransition),
          ),
        )
        .opacity;
    final before = opacity.value;

    var paints = 0;
    var rebuilds = 0;
    debugProfilePaintsEnabled = true;
    debugOnProfilePaint = (_) => paints++;
    debugOnRebuildDirtyWidget = (_, _) => rebuilds++;
    try {
      for (var frame = 0; frame < 30; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
    } finally {
      debugProfilePaintsEnabled = false;
      debugOnProfilePaint = null;
      debugOnRebuildDirtyWidget = null;
    }

    expect(opacity.value, isNot(before));
    expect(paints, 0);
    expect(rebuilds, 0);
  });

  testWidgets('holds still when animations are turned off', (tester) async {
    await tester.pumpWidget(line(disableAnimations: true));
    await tester.pumpAndSettle();

    expect(tester.hasRunningAnimations, isFalse);
  });
}
