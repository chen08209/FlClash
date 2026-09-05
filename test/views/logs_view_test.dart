import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/views.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void main() {
  const logCount = 200;

  late ProviderContainer container;

  List<Log> seedLogs() => List.generate(
    logCount,
    (i) => Log(payload: 'log $i', dateTime: '2024-01-01 12:00:$i'),
  );

  Future<void> pumpLogsView(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    container = ProviderContainer();
    addTearDown(container.dispose);
    globalState.container = container;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: LogsView()),
      ),
    );
    final notifier = container.read(logsProvider.notifier);
    for (final log in seedLogs()) {
      notifier.add(log);
    }
    await tester.pump(const Duration(milliseconds: 301));
    await tester.pumpAndSettle();
  }

  const hintKey = ValueKey('scrollbarHintPill');

  Finder hintFinder() => find.byKey(hintKey);

  testWidgets('dragging the list floats the time hint next to the scrollbar', (
    tester,
  ) async {
    await pumpLogsView(tester);
    expect(hintFinder(), findsNothing);

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(Scrollable).first),
    );
    await gesture.moveBy(const Offset(0, 300));
    await tester.pump();

    expect(hintFinder(), findsOneWidget);
    final label = tester.widget<Text>(
      find.descendant(of: find.byKey(hintKey), matching: find.byType(Text)),
    );
    expect(seedLogs().map((log) => log.dateTime), contains(label.data));

    final scrollableRect = tester.getRect(find.byType(Scrollable).first);
    // The hint is pinned to the scrollbar thumb. Material's minimum thumb
    // length is 48, so at the newest end the thumb center rests 24px below
    // the track's top edge.
    expect(
      tester.getCenter(find.byKey(hintKey)).dy,
      closeTo(scrollableRect.top + 24, 6),
    );

    for (var i = 0; i < 25; i++) {
      await gesture.moveBy(const Offset(0, -2000));
      await tester.pump();
    }
    // Near the oldest end the pill bottom-aligns above the FAB zone
    // (56px FAB + 16px margin) with an 8px gap instead of following
    // the thumb into it.
    expect(
      tester.getRect(find.byKey(hintKey)).bottom,
      closeTo(scrollableRect.bottom - 72 - 8, 2),
    );

    await gesture.up();
    // The pill outlives the gesture briefly so transient scroll ends do not
    // blink it. No pumpAndSettle here: the fling's ballistic keeps frames
    // scheduled for seconds of fake time, which would elapse straight past
    // the hide window.
    await tester.pump(const Duration(milliseconds: 100));
    expect(hintFinder(), findsOneWidget);
    for (var i = 0; i < 20 && hintFinder().evaluate().isNotEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(hintFinder(), findsNothing);
    await tester.pumpAndSettle();
  });

  testWidgets('auto scroll-to-end on new logs keeps the hint hidden', (
    tester,
  ) async {
    await pumpLogsView(tester);
    expect(hintFinder(), findsNothing);

    container
        .read(logsProvider.notifier)
        .add(const Log(payload: 'log new', dateTime: '2024-01-01 12:00:new'));
    await tester.pump(const Duration(milliseconds: 301));
    await tester.pumpAndSettle();

    expect(hintFinder(), findsNothing);
  });

  group('LogListController', () {
    final logs = seedLogs();

    test('keeps trimmed logs while auto scroll is off', () {
      final controller = LogListController();
      addTearDown(controller.dispose);
      controller.setLogs(logs.sublist(0, 100));
      controller.setAutoScrollToEnd(false);

      controller.setLogs(logs.sublist(10, 110));

      expect(controller.value.logs, logs.sublist(0, 110));
    });

    test('resume replaces the retained logs and follows the end', () {
      final controller = LogListController();
      addTearDown(controller.dispose);
      controller.setLogs(logs.sublist(0, 100));
      controller.setAutoScrollToEnd(false);
      controller.setLogs(logs.sublist(10, 110));

      final latest = logs.sublist(20, 120);
      controller.resumeAutoScrollToEnd(latest);

      expect(controller.value.autoScrollToEnd, isTrue);
      expect(controller.value.logs, latest);
      controller.setLogs(logs.sublist(30, 130));
      expect(controller.value.logs, logs.sublist(30, 130));
    });
  });
}
