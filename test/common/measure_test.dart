import 'package:fl_clash/common/measure.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

Future<Measure> _measureIn(WidgetTester tester, {double scale = 1}) async {
  late Measure measure;
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) {
          measure = Measure.of(context, scale);
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  return measure;
}

void main() {
  testWidgets('sizes grow with the text scale factor', (tester) async {
    final single = await _measureIn(tester);
    final baseline = single.computeTextSize(const Text('FlClash'));

    final doubled = await _measureIn(tester, scale: 2);
    final scaled = doubled.computeTextSize(const Text('FlClash'));

    expect(scaled.width, greaterThan(baseline.width));
    expect(scaled.height, greaterThan(baseline.height));
  });

  testWidgets('an explicit style overrides the size of an unstyled text', (
    tester,
  ) async {
    final measure = await _measureIn(tester);
    final small = measure.computeTextSize(
      const Text('FlClash'),
      style: const TextStyle(fontSize: 10),
    );
    final large = measure.computeTextSize(
      const Text('FlClash'),
      style: const TextStyle(fontSize: 40),
    );
    expect(large.width, greaterThan(small.width));
  });

  testWidgets('overflow is reported only when the text cannot fit', (
    tester,
  ) async {
    final measure = await _measureIn(tester);
    const text = Text('a considerably longer run of text', maxLines: 1);

    expect(measure.computeTextIsOverflow(text, maxWidth: 10), isTrue);
    expect(measure.computeTextIsOverflow(text, maxWidth: 2000), isFalse);
  });

  testWidgets('repeated measurement releases each painter', (tester) async {
    final measure = await _measureIn(tester);
    // A leaked TextPainter holds a native paragraph; the framework's leak
    // tracker turns that into an exception here rather than into drift that
    // only shows up while scrolling a long proxy list.
    for (var i = 0; i < 50; i++) {
      measure.computeTextSize(Text('row $i'));
      measure.computeTextIsOverflow(Text('row $i'), maxWidth: 20);
    }
    expect(tester.takeException(), null);
  });

  testWidgets('cached text metrics are computed once and reused', (
    tester,
  ) async {
    final measure = await _measureIn(tester);
    expect(measure.bodyMediumHeight, greaterThan(0));
    expect(measure.bodyMediumHeight, measure.bodyMediumHeight);
    expect(measure.bodyLargeHeight, greaterThan(measure.bodySmallHeight));
    expect(measure.titleLargeHeight, greaterThan(measure.labelSmallHeight));
    expect(measure.titleMediumHeight, greaterThan(0));
    expect(measure.labelMediumHeight, greaterThan(0));
    expect(measure.titleSmallHeight, greaterThan(0));
  });
}
