import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('DetailRow centers its label beside a wrapped value', (
    tester,
  ) async {
    const value = 'udp://119.29.29.29:53 udp://223.5.5.5:53';
    await tester.pumpWidget(
      TestApp(
        child: Center(
          child: SizedBox(
            width: 240,
            child: DetailRow.text(title: 'Source', value: value),
          ),
        ),
      ),
    );

    final label = tester.getRect(find.text('Source'));
    final text = tester.getRect(find.text(value));
    expect(text.height, greaterThan(label.height));
    expect(text.center.dy, moreOrLessEquals(label.center.dy, epsilon: 1));
    expect(text.right, greaterThan(label.right));
  });

  testWidgets('DetailRow without a value lets a long title wrap', (
    tester,
  ) async {
    const answer = '2400:cb00:2048:1::6814:1c3b 2400:cb00:2048:1::6814:1d3b';
    Future<double> heightAt(double width) async {
      await tester.pumpWidget(
        TestApp(
          child: Center(
            child: SizedBox(
              width: width,
              child: const DetailRow(title: answer, copyText: answer),
            ),
          ),
        ),
      );
      return tester.getRect(find.text(answer)).height;
    }

    final singleLine = await heightAt(800);
    expect(await heightAt(240), greaterThan(singleLine));
    expect(tester.takeException(), isNull);
  });
}
