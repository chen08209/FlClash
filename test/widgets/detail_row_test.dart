import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('a value row keeps a long value on the title\'s line, at its '
      'end', (tester) async {
    const value = 'udp://119.29.29.29:53 udp://223.5.5.5:53';
    await tester.pumpWidget(
      TestApp(
        child: Center(
          child: SizedBox(
            width: 240,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [DetailRow.text(title: 'Source', value: value)],
            ),
          ),
        ),
      ),
    );

    final row = tester.getRect(find.byType(ListRow));
    final label = tester.getRect(find.text('Source'));
    final text = tester.getRect(find.text(value));
    expect(row.height, listRowExtent(titleHeight: 22));
    expect(text.height, label.height);
    expect(text.center.dy, moreOrLessEquals(label.center.dy, epsilon: 1));
    expect(text.left, greaterThan(label.right));
  });

  testWidgets('a stacked row sets its value under the title in up to three '
      'lines', (tester) async {
    final value = List.filled(12, 'Accept-Encoding: gzip').join(', ');
    await tester.pumpWidget(
      TestApp(
        child: Center(
          child: SizedBox(
            width: 240,
            child: DetailRow.stacked(title: 'Header', value: value),
          ),
        ),
      ),
    );

    final label = tester.getRect(find.text('Header'));
    final text = tester.getRect(find.text(value));
    expect(text.top, greaterThanOrEqualTo(label.bottom));
    expect(text.left, label.left);
    expect(text.height, moreOrLessEquals(60, epsilon: 1));
    expect(tester.takeException(), isNull);
  });
}
