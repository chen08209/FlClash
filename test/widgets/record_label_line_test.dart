import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/connection/mitm_texts.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/record_lines.dart';
import '../helpers/test_app.dart';

void main() {
  Future<void> pumpLine(
    WidgetTester tester, {
    required double width,
    TextDirection direction = TextDirection.ltr,
    String text = 'api.example.com',
    List<String> labels = const [
      'Hong Kong 02',
      '2:14',
      'connection reset by peer',
    ],
    bool underTitle = false,
  }) async {
    tester.view.physicalSize = const Size(1200, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      TestApp(
        child: Directionality(
          textDirection: direction,
          child: Align(
            alignment: AlignmentDirectional.topStart,
            child: SizedBox(
              width: width,
              child: RecordLabelLine(
                text: text,
                labels: [for (final label in labels) RecordLabel(label: label)],
                underTitle: underTitle,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Rect rectOf(WidgetTester tester, String text) =>
      tester.getRect(find.widgetWithText(TonalChip, text));

  double naturalWidthOf(WidgetTester tester, String label) =>
      TonalChip.widthOf(tester.element(find.byType(RecordLabelLine)), label);

  RenderBox lineBox(WidgetTester tester) =>
      tester.renderObject<RenderBox>(find.byType(RecordLabelLine));

  double? baselineOf(RenderBox box, {bool dry = false}) {
    RenderObject.debugCheckingIntrinsics = true;
    try {
      return dry
          ? box.getDryBaseline(box.constraints, TextBaseline.alphabetic)
          : box.getDistanceToBaseline(TextBaseline.alphabetic, onlyReal: true);
    } finally {
      RenderObject.debugCheckingIntrinsics = false;
    }
  }

  String spoken(WidgetTester tester) => tester.semantics
      .simulatedAccessibilityTraversal()
      .map((node) => node.label)
      .join(' ');

  bool cut(WidgetTester tester, String text) => tester
      .renderObject<RenderParagraph>(
        find.descendant(of: find.text(text), matching: find.byType(RichText)),
      )
      .didExceedMaxLines;

  testWidgets('the text gives way first, at full width every part shows '
      'whole, four apart', (tester) async {
    await pumpLine(tester, width: 1000);

    final text = tester.getRect(find.text('api.example.com'));
    final node = rectOf(tester, 'Hong Kong 02');
    final age = rectOf(tester, '2:14');
    final reason = rectOf(tester, 'connection reset by peer');
    expect(text.left, 0);
    expect(node.left, moreOrLessEquals(text.right + 4));
    expect(age.left, moreOrLessEquals(node.right + 4));
    expect(reason.left, moreOrLessEquals(age.right + 4));
    expect(cut(tester, 'connection reset by peer'), isFalse);

    final labels =
        naturalWidthOf(tester, 'Hong Kong 02') +
        naturalWidthOf(tester, '2:14') +
        naturalWidthOf(tester, 'connection reset by peer') +
        8;
    await pumpLine(tester, width: labels + 124);
    expect(cut(tester, 'api.example.com'), isTrue);
    expect(
      tester.getRect(find.text('api.example.com')).width,
      moreOrLessEquals(120),
    );
    expect(cut(tester, 'connection reset by peer'), isFalse);

    await pumpLine(tester, width: labels + 8);
    expect(find.text('api.example.com').hitTestable(), findsNothing);
    expect(rectOf(tester, 'Hong Kong 02').left, 0);
    expect(recordLinesIn(tester), [
      '[Hong Kong 02] [2:14] [connection reset by peer]',
    ]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a text narrower than twice its height shows whole where it '
      'fits', (tester) async {
    await pumpLine(tester, width: 1000, text: 'A', labels: ['2:14']);
    final text = tester.getRect(find.text('A'));
    expect(text.width, lessThan(2 * text.height));

    await pumpLine(
      tester,
      width: text.width + 4 + naturalWidthOf(tester, '2:14'),
      text: 'A',
      labels: ['2:14'],
    );
    expect(cut(tester, 'A'), isFalse);
    expect(recordLinesIn(tester), ['A [2:14]']);

    await pumpLine(
      tester,
      width: text.width + 3 + naturalWidthOf(tester, '2:14'),
      text: 'A',
      labels: ['2:14'],
    );
    expect(recordLinesIn(tester), ['[2:14]']);
  });

  testWidgets('a part with no room leaves the reader and the pointer as well '
      'as the eye', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpLine(tester, width: 1000);
    expect(spoken(tester), contains('api.example.com'));

    await pumpLine(tester, width: 300);
    expect(spoken(tester), isNot(contains('api.example.com')));
    expect(spoken(tester), contains('Hong Kong 02'));
    expect(find.text('api.example.com').hitTestable(), findsNothing);
    semantics.dispose();
  });

  testWidgets('the dry baseline is the one the line lays out, and none when '
      'nothing shows', (tester) async {
    for (final width in [1000.0, 300.0]) {
      await pumpLine(tester, width: width);
      final box = lineBox(tester);
      final actual = baselineOf(box);
      expect(actual, isNotNull);
      expect(baselineOf(box, dry: true), moreOrLessEquals(actual!));
    }

    await pumpLine(tester, width: 10, labels: ['connection reset by peer']);
    final box = lineBox(tester);
    expect(recordLinesIn(tester), ['']);
    expect(baselineOf(box), isNull);
    expect(baselineOf(box, dry: true), isNull);
  });

  testWidgets('with no room left for the text only the last label cuts, '
      'the ones before it keep their width, and one left room for no more '
      'than an ellipsis goes', (tester) async {
    const width = 300.0;
    await pumpLine(tester, width: width);

    expect(find.text('api.example.com').hitTestable(), findsNothing);
    final node = rectOf(tester, 'Hong Kong 02');
    final age = rectOf(tester, '2:14');
    final reason = rectOf(tester, 'connection reset by peer');
    expect(node.left, 0);
    expect(
      node.width,
      moreOrLessEquals(naturalWidthOf(tester, 'Hong Kong 02')),
    );
    expect(age.width, moreOrLessEquals(naturalWidthOf(tester, '2:14')));
    expect(reason.left, moreOrLessEquals(age.right + 4));
    expect(reason.right, moreOrLessEquals(width));
    expect(cut(tester, 'Hong Kong 02'), isFalse);
    expect(cut(tester, '2:14'), isFalse);
    expect(cut(tester, 'connection reset by peer'), isTrue);

    await pumpLine(tester, width: age.right + 8);
    expect(
      find.widgetWithText(TonalChip, 'connection reset by peer').hitTestable(),
      findsNothing,
    );
    expect(rectOf(tester, '2:14').right, moreOrLessEquals(age.right));
    expect(tester.takeException(), isNull);
  });

  testWidgets('under a title the line drops by the gap only while it holds '
      'labels', (tester) async {
    await pumpLine(tester, width: 600);
    final chipTop = rectOf(tester, '2:14').top;
    final textTop = tester.getRect(find.text('api.example.com')).top;

    await pumpLine(tester, width: 600, underTitle: true);
    expect(rectOf(tester, '2:14').top, chipTop + recordLabelLineGap);
    expect(
      tester.getRect(find.text('api.example.com')).top,
      textTop + recordLabelLineGap,
    );

    await pumpLine(tester, width: 600, underTitle: true, labels: const []);
    expect(tester.getRect(find.text('api.example.com')).top, 0);
  });

  testWidgets('right to left the line runs from the right edge', (
    tester,
  ) async {
    await pumpLine(tester, width: 1000, direction: TextDirection.rtl);

    final text = tester.getRect(find.text('api.example.com'));
    expect(text.right, tester.getRect(find.byType(RecordLabelLine)).right);
    expect(
      rectOf(tester, 'Hong Kong 02').right,
      moreOrLessEquals(text.left - 4),
    );
  });

  test('a status code takes success under 300, error from 400', () {
    expect(httpStatusTone(204), RecordTone.success);
    expect(httpStatusTone(304), RecordTone.neutral);
    expect(httpStatusTone(404), RecordTone.error);
    expect(httpStatusTone(502), RecordTone.error);
  });
}
