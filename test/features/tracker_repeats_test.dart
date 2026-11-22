import 'package:fl_clash/features/connection/tracker_texts.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('a row repeating once more rebuilds alone', (tester) async {
    final built = <String>[];
    final rows = Column(
      children: [
        for (final id in ['a', 'b', 'c'])
          Builder(
            builder: (context) {
              built.add(id);
              return Text(
                '$id ${TrackerRepeats.of(context, id)}',
                textDirection: TextDirection.ltr,
              );
            },
          ),
      ],
    );
    Widget repeats(Map<String, int> counts) =>
        TrackerRepeats(counts: counts, child: rows);
    await tester.pumpWidget(repeats(const {'a': 2, 'b': 3}));
    built.clear();

    await tester.pumpWidget(repeats(const {'a': 2, 'b': 4}));

    expect(built, ['b']);
    expect(find.text('b 4'), findsOneWidget);
  });
}
