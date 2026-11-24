import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/views.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/route_cover.dart';
import '../helpers/scrollbar.dart';
import '../helpers/test_app.dart';
import '../helpers/host_scaffold.dart';

void main() {
  const logCount = 200;

  late ProviderContainer container;

  List<Log> seedLogs() => List.generate(
    logCount,
    (i) => Log(payload: 'log $i', dateTime: '2024-01-01 12:00:$i'),
  );

  Future<void> pumpLogsView(
    WidgetTester tester, {
    Size size = const Size(1400, 1000),
    Size? viewSize,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    container = ProviderContainer();
    addTearDown(container.dispose);
    globalState.container = container;
    if (viewSize != null) {
      container.read(viewSizeProvider.notifier).value = viewSize;
    }

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

  testWidgets('holding the scrollbar thumb floats the time hint beside it', (
    tester,
  ) async {
    await pumpLogsView(tester);
    expect(hintFinder(), findsNothing);

    final thumb = await revealScrollbarThumb(tester);
    final gesture = await tester.startGesture(thumb);
    await gesture.moveBy(const Offset(0, -1));
    await tester.pump();

    expect(hintFinder(), findsOneWidget);
    final label = tester.widget<Text>(
      find.descendant(of: find.byKey(hintKey), matching: find.byType(Text)),
    );
    expect(seedLogs().map((log) => log.dateTime), contains(label.data));

    final scrollableRect = tester.getRect(find.byType(Scrollable).first);
    // A 48 dp minimum thumb at the newest end centers 24 below the bar's foot.
    final trackTop = tester.getRect(find.byType(AppBar)).bottom;
    expect(tester.getCenter(find.byKey(hintKey)).dy, closeTo(trackTop + 24, 6));

    await gesture.moveBy(const Offset(0, 2000));
    await tester.pump();
    // Nothing floats over the foot, so the pill follows the thumb all the
    // way down and rests centred on it, the thumb being the track's share of
    // the content, both less the part under the bar.
    final position = tester
        .widget<Scrollable>(find.byType(Scrollable).first)
        .controller!
        .position;
    final underBar = trackTop - scrollableRect.top;
    final thumbExtent = max(
      48.0,
      (scrollableRect.bottom - trackTop) *
          (position.viewportDimension - underBar) /
          (position.maxScrollExtent + position.viewportDimension - underBar),
    );
    expect(
      tester.getCenter(find.byKey(hintKey)).dy,
      closeTo(scrollableRect.bottom - thumbExtent / 2, 2),
    );

    await gesture.up();
    // The pill outlives the gesture briefly so letting go and grabbing again
    // does not blink it.
    await tester.pump(const Duration(milliseconds: 100));
    expect(hintFinder(), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(hintFinder(), findsNothing);
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

  testWidgets('a one-line log is only as tall as its content', (tester) async {
    await tester.pumpWidget(
      const TestApp(
        child: HostScaffold(
          body: Column(
            children: [
              LogItem(
                log: Log(payload: 'short', dateTime: '2024-01-01 12:00:00'),
              ),
            ],
          ),
        ),
      ),
    );

    final item = tester.getRect(find.byType(LogItem));
    final header = tester.getRect(find.byType(RecordHeader));
    final body = tester.getRect(find.byType(SelectableText));
    expect(header.top - item.top, 10);
    expect(item.bottom - body.bottom, 12);
  });

  testWidgets('the logs and their filters stand at the list margin', (
    tester,
  ) async {
    await pumpLogsView(tester, viewSize: const Size(1400, 1000));
    await tester.tap(find.text(LogLevel.info.name).first);
    await tester.pumpAndSettle();

    final margin = tester.element(find.byType(LogsView)).listInsets.margin;
    expect(margin, isNot(16));
    final view = tester.getRect(find.byType(LogsView));
    final card = tester.getRect(
      find
          .descendant(
            of: find.byType(RecordListItem).first,
            matching: find.byType(PressSurface),
          )
          .first,
    );
    expect(card.left - view.left, margin);
    expect(view.right - card.right, margin);
    expect(tester.getRect(find.byType(Chip).first).left - view.left, margin);
  });

  for (final (name, size) in [
    ('a phone', const Size(390, 844)),
    ('a wide window', const Size(1400, 1000)),
  ]) {
    testWidgets('$name filters from a button grouped with search', (
      tester,
    ) async {
      await pumpLogsView(tester, size: size, viewSize: size);

      expect(
        find.ancestor(
          of: find.byTooltip('Filter'),
          matching: find.byType(TonalButtonGroup),
        ),
        findsOneWidget,
      );
      expect(find.byType(Chip), findsNothing);

      await tester.tap(find.byTooltip('More'));
      await tester.pumpAndSettle();
      expect(find.text('Export logs'), findsOneWidget);
      expect(find.text('Filter'), findsNothing);
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Filter'));
      await tester.pumpAndSettle();
      expect(find.text('Filter'), findsOneWidget);
      expect(find.text('Log level'), findsNothing);
      await tester.tap(find.text(LogLevel.info.name).last);
      await tester.pumpAndSettle();
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();

      expect(find.widgetWithText(Chip, LogLevel.info.name), findsOneWidget);
    });
  }

  testWidgets('the menu sets the Core log level', (tester) async {
    await pumpLogsView(tester);

    await tester.tap(find.byTooltip('More'));
    await tester.pumpAndSettle();
    expect(find.text(LogLevel.error.name), findsOneWidget);
    await tester.tap(find.text('Log level'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(LogLevel.debug.name).last);
    await tester.pumpAndSettle();

    expect(container.read(patchClashConfigProvider).logLevel, LogLevel.debug);
  });

  testWidgets('tapping the level reports it for filtering', (tester) async {
    RecordFilter? clicked;
    await tester.pumpWidget(
      TestApp(
        child: HostScaffold(
          body: RecordFilterScope(
            onFilter: (filter) => clicked = filter,
            child: const LogItem(
              log: Log(
                logLevel: LogLevel.warning,
                payload:
                    '[TCP] dial Proxy 10.0.0.2:1 --> a.example:443 error: EOF',
                dateTime: '2024-01-01 12:00:00',
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('warning'));

    expect(clicked, const RecordFilter(RecordFacetKind.level, 'warning'));
  });

  group('copying a log', () {
    String? copied;

    setUp(() {
      copied = null;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'Clipboard.setData') {
              copied = (call.arguments as Map)['text'] as String?;
            }
            return null;
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    testWidgets('a phone opens the details to select and copy a log', (
      tester,
    ) async {
      const phone = Size(390, 844);
      await pumpLogsView(tester, size: phone, viewSize: phone);

      expect(find.byType(LogItem), findsWidgets);
      expect(
        find.descendant(
          of: find.byType(LogItem),
          matching: find.byType(SelectableText),
        ),
        findsNothing,
      );

      await tester.tap(find.text('log 199'));
      await tester.pumpAndSettle();

      final message = find.descendant(
        of: find.byType(Navigator),
        matching: find.widgetWithText(SelectableText, 'log 199'),
      );
      expect(message, findsOneWidget);
      expect(find.text('2024-01-01 12:00:199'), findsWidgets);

      await tester.tap(find.byTooltip('Copy'));
      await tester.pump();
      expect(copied, '2024-01-01 12:00:199 [info] log 199');
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });

    testWidgets('a wide window keeps the log selectable in place', (
      tester,
    ) async {
      const wide = Size(1400, 1000);
      await pumpLogsView(tester, viewSize: wide);

      expect(
        find.descendant(
          of: find.byType(LogItem),
          matching: find.byType(SelectableText),
        ),
        findsWidgets,
      );

      await tester.tap(find.text('log 199'));
      await tester.pumpAndSettle();

      expect(find.byTooltip('Copy'), findsNothing);
      expect(copied, isNull);
    });
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

  testWidgets('a full list builds only the log added', (tester) async {
    await pumpLogsView(tester);
    final notifier = container.read(logsProvider.notifier);
    for (var i = logCount; i < maxLogsLength; i++) {
      notifier.add(Log(payload: 'log $i', dateTime: '2024-01-01 12:00:00'));
    }
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    var built = 0;
    debugOnRebuildDirtyWidget = (element, _) {
      if (element.widget is LogItem) {
        built++;
      }
    };
    addTearDown(() => debugOnRebuildDirtyWidget = null);
    notifier.add(const Log(payload: 'new', dateTime: '2024-01-01 12:00:00'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    debugOnRebuildDirtyWidget = null;

    expect(built, 1);
  });

  testWidgets('a page pushed over the logs and popped rebuilds none of them', (
    tester,
  ) async {
    await pumpLogsView(tester);

    expect(
      await rebuildsWhileCovered<LogsView>(tester, find.byType(LogsView)),
      0,
    );
  });
}
