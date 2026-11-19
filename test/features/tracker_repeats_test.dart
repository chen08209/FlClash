import 'package:fl_clash/features/connection/tracker_texts.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('a row repeating once more rebuilds alone', (tester) async {
    final built = <int>[];
    final rows = Column(
      children: [
        for (final id in [1, 2, 3])
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
    Widget repeats(Map<int, int> counts) =>
        TrackerRepeats(counts: counts, child: rows);
    await tester.pumpWidget(repeats(const {1: 2, 2: 3}));
    built.clear();

    await tester.pumpWidget(repeats(const {1: 2, 2: 4}));

    expect(built, [2]);
    expect(find.text('2 4'), findsOneWidget);
  });
}
