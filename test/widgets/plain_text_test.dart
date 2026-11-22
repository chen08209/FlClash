import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('lays out, measures, paints and reads as the Column of Texts '
      'it stands for', (tester) async {
    const first = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      fontFeatures: [FontFeature.tabularFigures()],
    );
    const second = TextStyle(fontSize: 11);
    for (final lines in [
      [('1.2MB/s', first), ('35.1MB', second)],
      [('0B', first), ('235.5KB', second)],
      [('7KB', first)],
    ]) {
      for (final maxWidth in [double.infinity, 200.0]) {
        await tester.pumpWidget(
          HostApp(
            home: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      key: const Key('column'),
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      spacing: 2,
                      children: [
                        for (final (text, style) in lines)
                          Text(text, style: style),
                      ],
                    ),
                    PlainTextLines(key: const Key('lines'), spacing: 2, [
                      for (final (text, style) in lines)
                        (text: text, style: style),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        );
        final column = tester.renderObject<RenderBox>(
          find.byKey(const Key('column')),
        );
        final plain = tester.renderObject<RenderBox>(
          find.byKey(const Key('lines')),
        );
        final reason = '$lines within $maxWidth';
        expect(plain.size, column.size, reason: reason);
        expect(
          plain.getMaxIntrinsicWidth(double.infinity),
          column.getMaxIntrinsicWidth(double.infinity),
          reason: reason,
        );
        final constraints = BoxConstraints(maxWidth: maxWidth);
        expect(
          plain.getDryBaseline(constraints, TextBaseline.alphabetic),
          column.getDryBaseline(constraints, TextBaseline.alphabetic),
          reason: reason,
        );
        final columnOrigin = tester.getTopLeft(find.byKey(const Key('column')));
        expect(
          [
            for (final (text, _) in lines)
              tester.getTopLeft(find.text(text)) - columnOrigin,
          ],
          (plain as RenderPlainTextLines).debugLineOffsets,
          reason: reason,
        );
        expect(
          tester.getSemantics(find.byKey(const Key('lines'))).label,
          lines.map((line) => line.$1).join('\n'),
          reason: reason,
        );
      }
    }
  });

  testWidgets('paints at its own width after a narrower intrinsic size was '
      'asked for', (tester) async {
    await tester.pumpWidget(
      const HostApp(
        home: Center(
          child: PlainTextLines(key: Key('lines'), [
            (text: '1.2MB/s', style: null),
            (text: '35.1MB', style: null),
          ]),
        ),
      ),
    );
    final plain = tester.renderObject<RenderPlainTextLines>(
      find.byKey(const Key('lines')),
    );
    final offsets = plain.debugLineOffsets;

    plain
      ..getMinIntrinsicHeight(10)
      ..markNeedsPaint();
    await tester.pump();

    expect(plain.debugLineOffsets, offsets);
  });

  testWidgets('keeps each line to one row where it is narrower than its '
      'text', (tester) async {
    Widget lines(double width) => HostApp(
      home: Center(
        child: SizedBox(
          width: width,
          child: const PlainTextLines(key: Key('lines'), spacing: 2, [
            (text: '↑ 953.7MB/s ↓ 953.7MB/s', style: null),
            (text: '1.0TB', style: null),
          ]),
        ),
      ),
    );
    await tester.pumpWidget(lines(1000));
    final wide = tester.getSize(find.byKey(const Key('lines'))).height;

    await tester.pumpWidget(lines(60));

    final plain = tester.renderObject<RenderPlainTextLines>(
      find.byKey(const Key('lines')),
    );
    expect(plain.size.height, wide);
    expect(plain.debugLineOffsets.last.dy + 1, lessThan(plain.size.height));
  });
}
