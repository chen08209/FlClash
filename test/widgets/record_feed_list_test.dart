import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/host_scaffold.dart';
import '../helpers/test_app.dart';

void main() {
  var keyed = 0;

  Widget buildList(List<int> items) {
    return HostApp(
      home: HostScaffold(
        body: RecordFeedList<int>(
          items: items,
          keyOf: (item) {
            keyed++;
            return ValueKey(item);
          },
          estimatedItemExtent: 40,
          itemBuilder: (item, striped, _) => SizedBox(
            height: 40,
            child: Text('$item ${striped ? 'odd' : 'even'}'),
          ),
        ),
      ),
    );
  }

  const cap = 5000;
  final full = [for (var i = 0; i < cap; i++) i];

  testWidgets('a refresh at the cap keys only the rows on screen', (
    tester,
  ) async {
    await tester.pumpWidget(buildList(full));
    keyed = 0;

    await tester.pumpWidget(buildList([for (var i = 1; i <= cap; i++) i]));

    expect(keyed, lessThan(100));
    expect(find.text('1 odd'), findsOneWidget);
    expect(find.text('2 even'), findsOneWidget);
  });

  testWidgets('a list changed other than at its head still finds its rows', (
    tester,
  ) async {
    await tester.pumpWidget(buildList(full));

    await tester.pumpWidget(buildList([for (var i = 0; i < cap; i += 2) i]));

    expect(find.text('0 even'), findsOneWidget);
    expect(find.text('2 odd'), findsOneWidget);
    expect(find.text('1 odd'), findsNothing);
  });
}
