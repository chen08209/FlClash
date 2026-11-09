import 'package:fl_clash/views/navigation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('no navigation view carries a global key of its own', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      Builder(
        builder: (value) {
          context = value;
          return const SizedBox();
        },
      ),
    );

    final items = navigation.getItems(openLogs: true, hasProxies: true);

    for (final item in items) {
      expect(item.builder(context).key, isNot(isA<GlobalKey>()));
    }
  });
}
