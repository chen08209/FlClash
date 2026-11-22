import 'package:fl_clash/features/connection/tracker_clock.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('each second reaches every row once, a few rows a frame, and '
      'stops while the page is hidden', (tester) async {
    final built = List.filled(10, 0);
    Widget clock({required bool shown}) => Directionality(
      textDirection: TextDirection.ltr,
      child: TickerMode(
        enabled: shown,
        child: TrackerClock(
          child: Column(
            children: [
              for (var index = 0; index < built.length; index++)
                Builder(
                  builder: (context) => ListenableBuilder(
                    listenable: TrackerClock.of(context)!,
                    builder: (_, _) {
                      built[index]++;
                      return const SizedBox();
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpWidget(clock(shown: true));
    built.fillRange(0, built.length, 0);

    await tester.pump(const Duration(seconds: 1));
    expect(built.where((count) => count > 0).length, lessThanOrEqualTo(4));
    for (var frame = 0; frame < 3; frame++) {
      await tester.pump();
    }
    expect(built, List.filled(10, 1));

    await tester.pumpWidget(clock(shown: false));
    built.fillRange(0, built.length, 0);
    for (var second = 0; second < 3; second++) {
      await tester.pump(const Duration(seconds: 1));
    }
    expect(built, List.filled(10, 0));
  });
}
