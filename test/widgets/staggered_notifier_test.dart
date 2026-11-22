import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('tells every listener once, a few a frame', (tester) async {
    final notifier = StaggeredNotifier(perFrame: 4);
    addTearDown(notifier.dispose);
    final told = <int>[];
    final listeners = [
      for (var index = 0; index < 10; index++) () => told.add(index),
    ];
    for (final listener in listeners) {
      notifier.addListener(listener);
    }

    notifier
      ..notify()
      ..notify();
    expect(told, isEmpty);

    final perFrame = <int>[];
    for (var frame = 0; frame < 4; frame++) {
      final before = told.length;
      await tester.pump();
      perFrame.add(told.length - before);
    }
    expect(perFrame, [4, 4, 2, 0]);
    expect(told, [for (var index = 0; index < 10; index++) index]);

    told.clear();
    notifier.notify();
    notifier.removeListener(listeners[9]);
    for (var frame = 0; frame < 3; frame++) {
      await tester.pump();
    }
    expect(told, [for (var index = 0; index < 9; index++) index]);
  });

  testWidgets('a listener still waiting when the value changes again is '
      'told once', (tester) async {
    final notifier = StaggeredNotifier(perFrame: 4);
    addTearDown(notifier.dispose);
    final told = <int>[];
    for (var index = 0; index < 10; index++) {
      notifier.addListener(() => told.add(index));
    }

    notifier.notify();
    await tester.pump();
    notifier.notify();
    for (var frame = 0; frame < 5; frame++) {
      await tester.pump();
    }

    expect(told, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3]);
  });

  testWidgets('a notifier disposed with listeners waiting tells none of '
      'them', (tester) async {
    final notifier = StaggeredNotifier(perFrame: 4);
    final told = <int>[];
    for (var index = 0; index < 10; index++) {
      notifier.addListener(() => told.add(index));
    }

    notifier.notify();
    await tester.pump();
    notifier.dispose();
    for (var frame = 0; frame < 3; frame++) {
      await tester.pump();
    }

    expect(told, [0, 1, 2, 3]);
  });

  testWidgets('a listener removed or a notifier disposed by one told before '
      'it in the same frame is not told', (tester) async {
    final notifier = StaggeredNotifier(perFrame: 4);
    final told = <int>[];
    void third() => told.add(2);
    notifier
      ..addListener(() {
        told.add(0);
        notifier.removeListener(third);
      })
      ..addListener(() {
        told.add(1);
        notifier.dispose();
      })
      ..addListener(third)
      ..addListener(() => told.add(3));

    notifier.notify();
    await tester.pump();

    expect(told, [0, 1]);
  });

  testWidgets('a listener that throws is reported, and the rest are still '
      'told', (tester) async {
    final notifier = StaggeredNotifier(perFrame: 4);
    addTearDown(notifier.dispose);
    final told = <int>[];
    for (var index = 0; index < 10; index++) {
      notifier.addListener(() {
        if (index == 1) {
          throw StateError('listener $index');
        }
        told.add(index);
      });
    }

    notifier.notify();
    await tester.pump();
    expect(tester.takeException(), isStateError);
    for (var frame = 0; frame < 3; frame++) {
      await tester.pump();
    }

    expect(told, [0, 2, 3, 4, 5, 6, 7, 8, 9]);
  });
}
