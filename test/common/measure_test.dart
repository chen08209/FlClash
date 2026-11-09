import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_ui/measure.dart';
import 'package:prism_ui/typography.dart';
import '../helpers/test_app.dart';

Future<Measure> _measureIn(WidgetTester tester, {double scale = 1}) async {
  late Measure measure;
  await tester.pumpWidget(
    HostApp(
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

  testWidgets('repeated measurement releases each painter', (tester) async {
    final measure = await _measureIn(tester);
    // A leaked TextPainter holds a native paragraph; the framework's leak
    // tracker turns that into an exception here rather than into drift that
    // only shows up while scrolling a long proxy list.
    for (var i = 0; i < 50; i++) {
      measure.computeTextSize(Text('row $i'));
    }
    expect(tester.takeException(), null);
  });

  testWidgets('cached text metrics are computed once and reused', (
    tester,
  ) async {
    final measure = await _measureIn(tester);
    final subheadline = measure.textHeight(AppTextStyle.subheadline);
    expect(subheadline, greaterThan(0));
    expect(measure.textHeight(AppTextStyle.subheadline), subheadline);
    expect(
      measure.textHeight(AppTextStyle.body),
      greaterThan(measure.textHeight(AppTextStyle.footnote)),
    );
  });
}
