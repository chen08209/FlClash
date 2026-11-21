import 'dart:async';

import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/features/features.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/views/connection/http_capture.dart';
import 'package:fl_clash/views/connection/requests.dart';
import 'package:fl_clash/views/navigation.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/scrollbar.dart';
import '../helpers/record_finders.dart';
import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

const _tableSize = Size(1400, 1000);
const _listSize = Size(600, 1000);

TrackerInfo _tracker({
  required String id,
  String host = 'example.com',
  String network = 'tcp',
  String process = 'curl',
  List<String> chains = const ['Proxy'],
  int download = 0,
}) {
  return TrackerInfo(
    id: id,
    download: download,
    start: DateTime.utc(2026),
    metadata: Metadata(
      network: network,
      host: host,
      destinationIP: '1.1.1.1',
      destinationPort: '443',
      process: process,
    ),
    chains: chains,
    rule: 'DOMAIN',
    rulePayload: host,
  );
}

TrackerInfo _failed({
  required String id,
  String host = 'example.com',
  List<String> chains = const ['Proxy'],
  int second = 0,
}) {
  final start = DateTime.utc(2026, 1, 1, 0, 0, second);
  return _tracker(id: id, host: host, chains: chains).copyWith(
    start: start,
    closedAt: start,
    failure: const ConnectionFailure(kind: ConnectionFailureKind.timeout),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [profilesProvider.overrideWith(TestProfiles.new)],
    );
    globalState.container = container;
    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(1400, 1000));
  });

  tearDown(() => container.dispose());

  void seedRequests(List<TrackerInfo> requests) {
    final notifier = container.read(requestsProvider.notifier);
    notifier.value = ConnectionLog(500);
    for (final request in requests) {
      notifier.addRequest(request);
    }
  }

  void addRequest(TrackerInfo request) {
    container.read(requestsProvider.notifier).addRequest(request);
  }

  Future<void> pumpRequests(
    WidgetTester tester, {
    Size size = _tableSize,
    Future<List<TrackerInfo>> Function()? connectionsReader,
  }) async {
    container.read(viewSizeProvider.notifier).update((_) => size);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: RequestsView(connectionsReader: connectionsReader),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  final stripScrollable = find
      .ancestor(
        of: find.byType(Chip),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Scrollable &&
              widget.axisDirection == AxisDirection.right,
        ),
      )
      .first;

  Finder targetOf(String host) => find.descendant(
    of: find.byType(TrackerTargetText),
    matching: find.textContaining(host),
  );

  Future<void> resize(WidgetTester tester, Size size) async {
    container.read(viewSizeProvider.notifier).update((_) => size);
    tester.view.physicalSize = size;
    await tester.pumpAndSettle();
  }

  bool enabled(WidgetTester tester, String tooltip) =>
      tester
          .widget<IconButton>(
            find.byWidgetPredicate(
              (widget) => widget is IconButton && widget.tooltip == tooltip,
            ),
          )
          .onPressed !=
      null;

  List<String> selectedRows(WidgetTester tester) => [
    for (final element in find.byType(TrackerInfoTableRow).evaluate())
      if (tester
          .widget<RecordTableRow>(
            find.descendant(
              of: find.byWidget(element.widget),
              matching: find.byType(RecordTableRow),
            ),
          )
          .selected)
        (element.widget as TrackerInfoTableRow).trackerInfo.id,
  ];

  Future<void> teardownView(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  }

  testWidgets('shows the empty state without any request', (tester) async {
    await pumpRequests(tester);

    expect(find.byType(NullStatus), findsOneWidget);
    expect(tester.takeException(), null);

    await teardownView(tester);
  });

  testWidgets('renders the requests already in the store on mount', (
    tester,
  ) async {
    seedRequests([
      _tracker(id: 'a', host: 'alpha.test'),
      _tracker(id: 'b', host: 'beta.test'),
    ]);

    await pumpRequests(tester);

    expect(find.byType(NullStatus), findsNothing);
    expect(find.textContaining('alpha.test'), findsWidgets);
    expect(find.textContaining('beta.test'), findsWidgets);

    await teardownView(tester);
  });

  testWidgets('a request arriving after mount reaches the list', (
    tester,
  ) async {
    seedRequests([_tracker(id: 'a', host: 'alpha.test')]);

    await pumpRequests(tester);
    expect(find.textContaining('gamma.test'), findsNothing);

    addRequest(_tracker(id: 'c', host: 'gamma.test'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('gamma.test'), findsWidgets);

    await teardownView(tester);
  });

  testWidgets('traffic after a request opened reaches its row', (tester) async {
    seedRequests([_tracker(id: 'a', host: 'alpha.test')]);

    await pumpRequests(tester);
    final total = (460 + 257835).traffic.show;
    expect(find.text(total), findsNothing);

    container.read(requestsProvider.notifier).updateTraffic({
      'a': (upload: 460, download: 257835),
    });
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    await tester.pump();

    expect(find.text(total), findsOneWidget);

    await teardownView(tester);
  });

  testWidgets('holding the scrollbar thumb floats the start time beside it', (
    tester,
  ) async {
    final requests = List.generate(
      200,
      (i) => TrackerInfo(
        id: '$i',
        start: DateTime.utc(2026, 1, 1, 0, 0, i),
        metadata: Metadata(
          network: 'tcp',
          host: 'host-$i.test',
          destinationIP: '1.1.1.1',
          destinationPort: '443',
          process: 'curl',
        ),
        chains: const ['Proxy'],
        rule: 'DOMAIN',
        rulePayload: 'host-$i.test',
      ),
    );
    seedRequests(requests);

    await pumpRequests(tester, size: _listSize);

    const hintKey = ValueKey('scrollbarHintPill');
    expect(find.byKey(hintKey), findsNothing);

    final thumb = await revealScrollbarThumb(
      tester,
      scrollable: find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable &&
            axisDirectionToAxis(widget.axisDirection) == Axis.vertical,
      ),
    );
    final gesture = await tester.startGesture(thumb);
    await gesture.moveBy(const Offset(0, -1));
    await tester.pump();

    expect(find.byKey(hintKey), findsOneWidget);
    final label = tester.widget<Text>(
      find.descendant(of: find.byKey(hintKey), matching: find.byType(Text)),
    );
    expect(label.data, requests.last.start.showFull);
    // The hint is pinned to the thumb: at the newest end the thumb center
    // rests 24 dp (half the 48 dp minimum thumb) below the track's top edge,
    // which the list leaves at the foot of the filter strip, 16 dp below the
    // summary under its chips.
    final summary = tester.getRect(find.byType(ConnectionSummary));
    expect(
      tester.getCenter(find.byKey(hintKey)).dy,
      closeTo(summary.bottom + 16 + 24, 6),
    );

    await gesture.up();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byKey(hintKey), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(find.byKey(hintKey), findsNothing);

    await teardownView(tester);
  });

  testWidgets('tapping a column header sorts the table by it, then the '
      'other way, then back to newest first', (tester) async {
    seedRequests([
      _tracker(id: 'a', host: 'gamma.test', download: 10),
      _tracker(id: 'b', host: 'alpha.test', download: 30),
      _tracker(id: 'c', host: 'beta.test', download: 20),
    ]);

    await pumpRequests(tester);

    List<String> hostsTopDown() {
      final rows = tester
          .widgetList<TrackerInfoTableRow>(find.byType(TrackerInfoTableRow))
          .toList();
      rows.sort(
        (a, b) => tester
            .getTopLeft(find.byWidget(a))
            .dy
            .compareTo(tester.getTopLeft(find.byWidget(b)).dy),
      );
      return [for (final row in rows) row.trackerInfo.metadata.host];
    }

    Finder sortArrow(Glyph glyph) => find.byWidgetPredicate(
      (widget) => widget is GlyphIcon && widget.glyph == glyph,
    );

    Future<void> tapHeader(String label) async {
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }

    expect(hostsTopDown(), ['beta.test', 'alpha.test', 'gamma.test']);

    await tapHeader('Total');
    expect(hostsTopDown(), ['alpha.test', 'beta.test', 'gamma.test']);
    expect(sortArrow(AppGlyphs.arrowDown), findsOneWidget);

    await tapHeader('Total');
    expect(hostsTopDown(), ['gamma.test', 'beta.test', 'alpha.test']);
    expect(sortArrow(AppGlyphs.arrowUp), findsOneWidget);

    await tapHeader('Total');
    expect(hostsTopDown(), ['beta.test', 'alpha.test', 'gamma.test']);
    expect(sortArrow(AppGlyphs.arrowDown), findsNothing);
    expect(sortArrow(AppGlyphs.arrowUp), findsNothing);

    await tapHeader('Target');
    expect(hostsTopDown(), ['alpha.test', 'beta.test', 'gamma.test']);

    await teardownView(tester);
  });

  testWidgets('dragging a column edge widens it into the columns after it, '
      'keeps the widths and a double click gives them back', (tester) async {
    container.listen(appSettingProvider, (_, _) {});
    seedRequests([_tracker(id: 'a', host: 'alpha.test')]);

    await pumpRequests(tester);

    final handles = find.byWidgetPredicate(
      (widget) =>
          widget is MouseRegion &&
          widget.cursor == SystemMouseCursors.resizeColumn,
    );
    double leftOf(String text) =>
        tester.getTopLeft(find.text(text).hitTestable().last).dx;
    final rule = leftOf('Rule');
    final exit = leftOf('Exit');

    await tester.drag(
      handles.at(2),
      const Offset(100, 0),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump();

    final moved = leftOf('Rule') - rule;
    expect(moved, greaterThan(50));
    expect(leftOf('Exit'), exit);
    expect(
      container.read(appSettingProvider).tableColumnWidths['connections']?.keys,
      unorderedEquals(['target', 'rule']),
    );

    await tester.tap(handles.at(2), kind: PointerDeviceKind.mouse);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(handles.at(2), kind: PointerDeviceKind.mouse);
    await tester.pumpAndSettle();

    expect(leftOf('Rule'), rule);
    expect(container.read(appSettingProvider).tableColumnWidths, isEmpty);

    await teardownView(tester);
  });

  testWidgets('the table opens at the widths kept from before', (tester) async {
    container.listen(appSettingProvider, (_, _) {});
    seedRequests([_tracker(id: 'a', host: 'alpha.test')]);

    await pumpRequests(tester);
    final target = tester.getTopLeft(headerText('Target')).dx;
    await teardownView(tester);

    container
        .read(appSettingProvider.notifier)
        .update(
          (state) => state.copyWith(
            tableColumnWidths: {
              'connections': {'target': 400},
            },
          ),
        );
    await pumpRequests(tester);

    expect(
      tester.getTopLeft(headerText('Rule')).dx,
      closeTo(target + 400, 0.01),
    );

    await teardownView(tester);
  });

  testWidgets('the table sets its cells a size smaller, as footnotes', (
    tester,
  ) async {
    seedRequests([_tracker(id: 'a', host: 'alpha.test')]);

    await pumpRequests(tester);
    final cell = find
        .descendant(
          of: find.byType(TrackerInfoTableRow),
          matching: find.text('curl'),
        )
        .first;
    expect(tester.widget<Text>(cell).style?.fontSize, isNull);
    expect(DefaultTextStyle.of(tester.element(cell)).style.fontSize, 13);

    await teardownView(tester);
  });

  testWidgets('a wide page builds only the rows in view', (tester) async {
    seedRequests([for (var i = 0; i < 500; i++) _tracker(id: '$i')]);

    await pumpRequests(tester);

    final built = find.byType(TrackerInfoTableRow).evaluate().length;
    expect(built, greaterThan(0));
    expect(built, lessThan(60));

    await teardownView(tester);
  });

  testWidgets('a narrow page keeps the stacked rows', (tester) async {
    seedRequests([_tracker(id: 'a', host: 'alpha.test')]);

    await pumpRequests(tester, size: _listSize);

    expect(find.byType(TrackerInfoItem), findsOneWidget);
    expect(find.byType(TrackerInfoTableRow), findsNothing);
    expect(find.text('Target'), findsNothing);

    await teardownView(tester);
  });

  testWidgets('a wide page lays the requests out under a column header', (
    tester,
  ) async {
    seedRequests([
      _tracker(id: 'a', host: 'alpha.test'),
      _tracker(id: 'b', host: 'beta.test', chains: const ['Tokyo', 'Proxy']),
    ]);

    await pumpRequests(tester);

    for (final label in [
      'Time',
      'App',
      'Target',
      'Rule',
      'Exit',
      'Speed',
      'Duration',
      'Total',
    ]) {
      expect(headerText(label), findsOneWidget);
    }
    expect(find.byType(TrackerInfoTableRow), findsNWidgets(2));
    expect(find.byType(Divider), findsNothing);
    expect(
      tester
          .widgetList<TrackerInfoTableRow>(find.byType(TrackerInfoTableRow))
          .map((row) => row.striped)
          .toSet(),
      {true, false},
    );
    expect(find.byType(TrackerInfoItem), findsNothing);
    expect(
      find.descendant(
        of: find.byType(TrackerInfoTableRow),
        matching: find.text('curl'),
      ),
      findsNWidgets(2),
    );
    final rowHeights = tester
        .widgetList(find.byType(TrackerInfoTableRow))
        .map((row) => tester.getSize(find.byWidget(row)).height)
        .toSet();
    expect(rowHeights, hasLength(1));
    expect(
      tester.getTopLeft(find.textContaining('beta.test').first).dy,
      greaterThan(tester.getBottomLeft(headerText('Target')).dy),
    );
    expect(tester.takeException(), null);

    await teardownView(tester);
  });

  testWidgets('tapping an exit in the table keeps only the requests using it', (
    tester,
  ) async {
    seedRequests([
      _tracker(id: 'a', host: 'alpha.test'),
      _tracker(id: 'b', host: 'beta.test', chains: const ['Tokyo', 'Proxy']),
    ]);

    await pumpRequests(tester);

    await tester.tap(find.widgetWithText(TonalChip, 'Tokyo'));
    await tester.pumpAndSettle();

    expect(find.textContaining('alpha.test'), findsNothing);
    expect(find.textContaining('beta.test'), findsWidgets);

    await teardownView(tester);
  });

  testWidgets('a wide page shows the row it selects in a card beside the '
      'table, until the card is closed', (tester) async {
    seedRequests([
      _tracker(id: 'a', host: 'alpha.test'),
      _tracker(id: 'b', host: 'beta.test'),
    ]);

    await pumpRequests(tester);
    expect(find.byType(TrackerInfoDetailCard), findsNothing);

    await tester.tap(targetOf('alpha.test'));
    await tester.pumpAndSettle();

    final card = find.byType(TrackerInfoDetailCard);
    String cardShows() => tester
        .widget<TrackerInfoHeader>(
          find.descendant(of: card, matching: find.byType(TrackerInfoHeader)),
        )
        .trackerInfo
        .id;
    expect(cardShows(), 'a');
    expect(find.text('Connection details'), findsNothing);
    expect(selectedRows(tester), ['a']);
    expect(find.byType(TrackerInfoTableRow), findsNWidgets(2));
    expect(
      tester.getRect(card).left,
      greaterThanOrEqualTo(
        tester.getRect(find.byType(TrackerInfoTableRow).first).right,
      ),
    );

    await tester.tap(targetOf('beta.test'));
    await tester.pumpAndSettle();
    expect(selectedRows(tester), ['b']);
    expect(cardShows(), 'b');

    await tester.tap(
      find.descendant(of: card, matching: find.byTooltip('Close')),
    );
    await tester.pumpAndSettle();
    expect(card, findsNothing);
    expect(selectedRows(tester), isEmpty);

    await teardownView(tester);
  });

  testWidgets('a narrower desktop page shows the row it selects in a side '
      'sheet that steps to the rows around it', (tester) async {
    seedRequests([
      _tracker(id: 'a', host: 'alpha.test'),
      _tracker(id: 'b', host: 'beta.test'),
    ]);

    await pumpRequests(tester, size: const Size(900, 1000));
    expect(find.byType(TrackerInfoTableRow), findsNWidgets(2));

    await tester.tap(targetOf('beta.test'));
    await tester.pumpAndSettle();

    final sheet = find.byType(TrackerInfoDetailSheet);
    expect(find.byType(TrackerInfoDetailCard), findsNothing);
    expect(sheet, findsOneWidget);
    expect(
      find.descendant(of: sheet, matching: find.text('Connection details')),
      findsNothing,
    );
    expect(
      tester
          .widget<TrackerInfoHeader>(
            find.descendant(
              of: sheet,
              matching: find.byType(TrackerInfoHeader),
            ),
          )
          .trackerInfo
          .id,
      'b',
    );
    expect(
      find.descendant(
        of: sheet,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is TrackerInfoDetailView && widget.trackerInfo.id == 'b',
        ),
      ),
      findsOneWidget,
    );

    expect(enabled(tester, 'Previous'), isFalse);
    expect(enabled(tester, 'Next'), isTrue);
    await tester.tap(find.byTooltip('Next'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TrackerInfoDetailView>(
            find.descendant(
              of: sheet,
              matching: find.byType(TrackerInfoDetailView),
            ),
          )
          .trackerInfo
          .id,
      'a',
    );
    expect(enabled(tester, 'Previous'), isTrue);
    expect(enabled(tester, 'Next'), isFalse);
    await tester.tap(find.byTooltip('Next'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TrackerInfoDetailView>(
            find.descendant(
              of: sheet,
              matching: find.byType(TrackerInfoDetailView),
            ),
          )
          .trackerInfo
          .id,
      'a',
    );
    await tester.tap(find.byTooltip('Previous'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TrackerInfoDetailView>(
            find.descendant(
              of: sheet,
              matching: find.byType(TrackerInfoDetailView),
            ),
          )
          .trackerInfo
          .id,
      'b',
    );

    await tester.tapAt(const Offset(20, 500));
    await tester.pumpAndSettle();
    expect(sheet, findsNothing);
    expect(selectedRows(tester), isEmpty);

    await teardownView(tester);
  });

  testWidgets('stepping past the rows in view scrolls the list to the '
      'selected one', (tester) async {
    seedRequests([
      for (var i = 0; i < 80; i++) _tracker(id: '$i', host: 'host$i.test'),
    ]);

    await pumpRequests(tester, size: const Size(900, 1000));
    await tester.tap(targetOf('host79.test'));
    await tester.pumpAndSettle();
    for (var i = 0; i < 40; i++) {
      await tester.tap(find.byTooltip('Next'));
      await tester.pumpAndSettle();
    }
    expect(selectedRows(tester), ['39']);
    final row = tester.getRect(
      find.byWidgetPredicate(
        (widget) =>
            widget is TrackerInfoTableRow && widget.trackerInfo.id == '39',
      ),
    );
    expect(row.top, greaterThanOrEqualTo(0));
    expect(row.bottom, lessThanOrEqualTo(1000));

    await teardownView(tester);
  });

  testWidgets('a selected connection that leaves the log takes its card or '
      'its sheet with it', (tester) async {
    seedRequests([
      _tracker(id: 'a', host: 'alpha.test'),
      _tracker(id: 'b', host: 'beta.test'),
    ]);
    final requests = container.read(requestsProvider.notifier);

    await pumpRequests(tester);
    await tester.tap(targetOf('alpha.test'));
    await tester.pumpAndSettle();
    expect(find.byType(TrackerInfoDetailCard), findsOneWidget);
    expect(find.textContaining('1 selected'), findsOneWidget);

    requests.close(['a']);
    await tester.pumpAndSettle();
    expect(find.byType(TrackerInfoDetailCard), findsOneWidget);
    requests.clearClosed();
    await tester.pumpAndSettle();
    expect(find.byType(TrackerInfoDetailCard), findsNothing);
    expect(find.textContaining('1 selected'), findsNothing);

    addRequest(_tracker(id: 'c', host: 'gamma.test'));
    await resize(tester, const Size(900, 1000));
    await tester.tap(targetOf('gamma.test'));
    await tester.pumpAndSettle();
    expect(find.byType(TrackerInfoDetailSheet), findsOneWidget);
    requests.close(['c']);
    requests.clearClosed();
    await tester.pumpAndSettle();
    expect(find.byType(TrackerInfoDetailSheet), findsNothing);
    expect(selectedRows(tester), isEmpty);

    await teardownView(tester);
  });

  testWidgets('narrowed past the card a page lets its selection go, and '
      'widened it shows the sheet\'s connection in the card', (tester) async {
    seedRequests([
      _tracker(id: 'a', host: 'alpha.test'),
      _tracker(id: 'b', host: 'beta.test'),
    ]);

    await pumpRequests(tester);
    await tester.tap(targetOf('alpha.test'));
    await tester.pumpAndSettle();
    expect(find.byType(TrackerInfoDetailCard), findsOneWidget);

    await resize(tester, const Size(1000, 1000));
    expect(find.byType(TrackerInfoDetailCard), findsNothing);
    expect(find.byType(TrackerInfoDetailSheet), findsNothing);
    expect(selectedRows(tester), isEmpty);

    await tester.tap(targetOf('beta.test'));
    await tester.pumpAndSettle();
    expect(find.byType(TrackerInfoDetailSheet), findsOneWidget);

    await resize(tester, const Size(1100, 1000));
    expect(find.byType(TrackerInfoDetailSheet), findsNothing);
    expect(find.byType(TrackerInfoDetailCard), findsOneWidget);
    expect(selectedRows(tester), ['b']);

    await teardownView(tester);
  });

  Finder barButton(String tooltip) => find.byWidgetPredicate(
    (widget) => widget is AppBarActionButton && widget.data.tooltip == tooltip,
  );

  Future<void> openMenu(WidgetTester tester, String host) async {
    await tester.tap(
      targetOf(host),
      buttons: kSecondaryMouseButton,
      kind: PointerDeviceKind.mouse,
    );
    await tester.pumpAndSettle();
  }

  Future<void> dismissMenu(WidgetTester tester) async {
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
  }

  testWidgets('a connection\'s menu offers what its state allows, and narrows '
      'the list to its app or hides its host', (tester) async {
    final open = _tracker(id: 'a', host: 'alpha.test');
    seedRequests([
      open,
      _tracker(id: 'b', host: 'beta.test', process: 'chrome'),
    ]);

    await pumpRequests(tester, connectionsReader: () async => [open]);
    await tester.pump(const Duration(seconds: 1));

    await openMenu(tester, 'beta.test');
    expect(find.text('Close connection'), findsNothing);
    for (final label in ['Copy host', 'Only this app', 'Hide this host']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('View HTTP'), findsNothing);
    expect(find.text('Copy destination'), findsNothing);
    await dismissMenu(tester);

    await openMenu(tester, 'alpha.test');
    expect(find.text('Close connection'), findsOneWidget);
    await tester.tap(find.text('Only this app'));
    await tester.pumpAndSettle();
    expect(targetOf('beta.test'), findsNothing);
    expect(targetOf('alpha.test'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(ConnectionFacetBar),
        matching: find.byType(SelectionCheck),
      ),
      findsOneWidget,
    );

    await openMenu(tester, 'alpha.test');
    await tester.tap(find.text('Hide this host'));
    await tester.pumpAndSettle();
    expect(targetOf('alpha.test'), findsNothing);
    await tester.scrollUntilVisible(
      find.widgetWithText(Chip, '-host:alpha.test'),
      100,
      scrollable: stripScrollable,
    );
    expect(find.widgetWithText(Chip, '-host:alpha.test'), findsOneWidget);

    await teardownView(tester);
  });

  testWidgets('a row shows its connection\'s latest traffic, and leaves its '
      'speed blank once it closes', (tester) async {
    final open = _tracker(id: 'a', host: 'alpha.test');
    seedRequests([open]);
    var live = [open];
    const total = 3 * 1024 * 1024;

    await pumpRequests(tester, connectionsReader: () async => live);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text(total.traffic.show), findsNothing);

    live = [open.copyWith(download: total)];
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text(total.traffic.show), findsOneWidget);
    final speed = find.byWidgetPredicate(
      (widget) => '${widget.runtimeType}' == '_SpeedCell',
    );
    String speedText() => tester
        .widget<RecordCellText>(
          find.descendant(of: speed, matching: find.byType(RecordCellText)),
        )
        .text;
    expect(speedText(), isNotEmpty);

    live = [];
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text(total.traffic.show), findsOneWidget);
    expect(speedText(), isEmpty);

    await teardownView(tester);
  });

  testWidgets('a row follows an open connection whose route changes', (
    tester,
  ) async {
    final open = _tracker(id: 'a', host: 'alpha.test', chains: ['Route A']);
    seedRequests([open]);
    var live = [open];

    await pumpRequests(tester, connectionsReader: () async => live);
    await tester.pump(const Duration(seconds: 1));
    Finder inRow(String text) => find.descendant(
      of: find.byType(RecordTableRow),
      matching: find.text(text),
    );
    expect(inRow('Route A'), findsOneWidget);

    live = [
      open.copyWith(chains: ['Route B'], download: 10),
    ];
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(inRow('Route A'), findsNothing);
    expect(inRow('Route B'), findsOneWidget);

    await teardownView(tester);
  });

  testWidgets('a refresh rebuilds the traffic cells on screen rather than '
      'their rows, however long the log', (tester) async {
    final start = DateTime.utc(2026);
    final closed = [
      for (var i = 0; i < 2000; i++)
        _tracker(id: 'c$i').copyWith(
          start: start.add(Duration(seconds: i)),
          closedAt: start.add(Duration(seconds: i + 1)),
        ),
    ];
    List<TrackerInfo> open(int round) => [
      for (var i = 0; i < 50; i++)
        _tracker(
          id: 'o$i',
          download: round * 100 + i,
        ).copyWith(start: start.add(Duration(seconds: 3000 + i))),
    ];
    container.read(requestsProvider.notifier).value = ConnectionLog(2000)
        .open([...closed, ...open(0)])
        .close([for (final c in closed) c.id], start);
    var round = 0;

    await pumpRequests(tester, connectionsReader: () async => open(++round));
    await tester.pump(const Duration(seconds: 2));
    var rows = 0;
    var cells = 0;
    final others = <String>{};
    debugOnRebuildDirtyWidget = (element, _) {
      final type = '${element.widget.runtimeType}';
      if (element.widget is RecordTableRow) {
        rows++;
      } else if (type == '_SpeedCell' || type == '_TotalCell') {
        cells++;
      } else {
        others.add(type);
      }
    };
    addTearDown(() => debugOnRebuildDirtyWidget = null);
    for (var frame = 0; frame < 90 && cells == 0; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    debugOnRebuildDirtyWidget = null;

    expect(rows, 0);
    expect(others, isNot(contains('KeepAlive')));
    expect(others, isNot(contains('_RecordTableHeader<TrackerInfo>')));
    expect(cells, greaterThan(0));
    expect(
      cells,
      lessThanOrEqualTo(
        2 * find.byType(RecordTableRow, skipOffstage: false).evaluate().length,
      ),
    );

    await teardownView(tester);
  });

  testWidgets('the table scrollbar leaves no room for the bar above it', (
    tester,
  ) async {
    seedRequests([for (var i = 0; i < 200; i++) _tracker(id: '$i')]);

    await pumpRequests(tester);

    await revealScrollbarThumb(
      tester,
      scrollable: find
          .descendant(
            of: find.byType(ScrollToEndBox),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(scrollbarPainter(tester).padding.resolve(TextDirection.ltr).top, 0);

    await teardownView(tester);
  });

  testWidgets('following pauses when the list is scrolled off its head and '
      'resumes when it is scrolled back', (tester) async {
    seedRequests([for (var i = 0; i < 60; i++) _tracker(id: '$i')]);

    await pumpRequests(tester);
    await tester.pumpAndSettle();

    final box = find.byType(ScrollToEndBox);
    bool following() => tester.widget<ScrollToEndBox>(box).enable;
    expect(following(), isTrue);

    // The list is reversed, so its head is the end of the scroll extent and
    // an upward drag moves away from it.
    await tester.drag(box, const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(following(), isFalse);

    await tester.drag(box, const Offset(0, 600));
    await tester.pumpAndSettle();
    expect(following(), isTrue);

    await teardownView(tester);
  });
  Finder inMenu(Finder finder) =>
      find.descendant(of: find.byType(PopupMenu), matching: finder);

  Future<void> openSubMenu(WidgetTester tester, String label) async {
    await tester.tap(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.byGlyph(AppGlyphs.more),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(inMenu(find.text(label)));
    await tester.pumpAndSettle();
  }

  List<String> mockClipboard(WidgetTester tester) {
    final copied = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied.add((call.arguments as Map)['text'] as String);
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    return copied;
  }

  testWidgets('a paused list still shows at once what the user clears from '
      'it', (tester) async {
    seedRequests([
      _tracker(id: 'a', host: 'alpha.test'),
      _tracker(id: 'b', host: 'beta.test'),
    ]);
    container.read(requestsProvider.notifier).close(['a']);
    final open = container.read(requestsProvider)['b']!;

    await pumpRequests(tester, connectionsReader: () async => [open]);
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(barButton('Pause refreshing'));
    await tester.pumpAndSettle();
    expect(targetOf('alpha.test'), findsOneWidget);

    await openSubMenu(tester, 'Clear closed connections');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(targetOf('alpha.test'), findsNothing);
    expect(targetOf('beta.test'), findsOneWidget);
    expect(barButton('Resume refreshing'), findsOneWidget);

    await teardownView(tester);
  });

  testWidgets('a connection closed right after pausing leaves the list at '
      'once, though a refresh was already queued', (tester) async {
    final core = _MockCore();
    final alpha = _tracker(id: 'a', host: 'alpha.test');
    final beta = _tracker(id: 'b', host: 'beta.test');
    var live = [alpha, beta];
    when(() => core.closeConnection(any())).thenAnswer((call) async {
      final id = call.positionalArguments.first as String;
      live = [
        for (final info in live)
          if (info.id != id) info,
      ];
    });
    container.dispose();
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(TestProfiles.new),
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
      ],
    );
    globalState.container = container;
    seedRequests([alpha, beta]);

    await pumpRequests(tester, connectionsReader: () async => live);
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Active 2'));
    await tester.pumpAndSettle();
    await tester.tap(targetOf('alpha.test'));
    await tester.pumpAndSettle();

    addRequest(_tracker(id: 'c', host: 'gamma.test'));
    await tester.tap(barButton('Pause refreshing'));
    await openMenu(tester, 'alpha.test');
    await tester.tap(find.text('Close connection'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    verify(() => core.closeConnection('a')).called(1);
    expect(barButton('Resume refreshing'), findsOneWidget);
    expect(targetOf('alpha.test'), findsNothing);

    await teardownView(tester);
  });

  testWidgets('a connection without a host copies its address from its menu', (
    tester,
  ) async {
    seedRequests([_tracker(id: 'a', host: '')]);
    final copied = mockClipboard(tester);

    await pumpRequests(tester);
    await openMenu(tester, '1.1.1.1');
    await tester.tap(find.text('Copy destination'));
    await tester.pumpAndSettle();
    expect(copied, ['1.1.1.1:443']);

    await teardownView(tester);
  });

  testWidgets('a phone\'s detail offers what the connection allows as it is '
      'now', (tester) async {
    final open = _tracker(id: 'a', host: 'alpha.test');
    seedRequests([open]);
    var live = [open];

    await pumpRequests(
      tester,
      size: _listSize,
      connectionsReader: () async => live,
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('alpha.test'));
    await tester.pumpAndSettle();
    final sheetMore = find.byGlyph(AppGlyphs.more).last;
    await tester.tap(sheetMore);
    await tester.pumpAndSettle();
    expect(find.text('Close connection'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    live = [];
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    await tester.tap(sheetMore);
    await tester.pumpAndSettle();
    expect(find.text('Copy host'), findsOneWidget);
    expect(find.text('Close connection'), findsNothing);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    container.read(requestsProvider.notifier).clearClosed();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    await tester.tap(sheetMore);
    await tester.pumpAndSettle();
    expect(find.text('Copy host'), findsOneWidget);
    expect(find.text('Close connection'), findsNothing);

    await teardownView(tester);
  });

  testWidgets('a phone\'s detail heads with its connection and a state that '
      'follows it', (tester) async {
    final open = _tracker(id: 'a', host: 'alpha.test');
    seedRequests([open]);
    var live = [open];

    await pumpRequests(
      tester,
      size: _listSize,
      connectionsReader: () async => live,
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('alpha.test'));
    await tester.pumpAndSettle();

    final header = find.byType(TrackerInfoHeader);
    expect(header, findsOneWidget);
    Finder inHeader(Finder finder) =>
        find.descendant(of: header, matching: finder);
    expect(inHeader(find.text('alpha.test')), findsOneWidget);
    expect(inHeader(find.textContaining('Active · ')), findsOneWidget);

    live = [];
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(inHeader(find.textContaining('Active · ')), findsNothing);
    expect(inHeader(find.textContaining('Closed · ')), findsOneWidget);

    await teardownView(tester);
  });

  testWidgets('a detail runs its path to the node it left by, shows speeds '
      'only while open, and copies an address on a press', (tester) async {
    final open = _tracker(id: 'a', host: 'alpha.test');
    seedRequests([open]);
    var live = [open];
    final copied = mockClipboard(tester);

    await pumpRequests(tester, connectionsReader: () async => live);
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(targetOf('alpha.test'));
    await tester.pumpAndSettle();

    final steps = tester
        .widgetList<TrackerPathStep>(find.byType(TrackerPathStep))
        .toList();
    expect(
      [for (final step in steps) (step.title, step.last)],
      [('curl', false), ('DOMAIN(alpha.test)', false), ('Proxy', true)],
    );
    List<int?> speeds() => [
      for (final column in tester.widgetList<TrackerTrafficColumn>(
        find.byType(TrackerTrafficColumn),
      ))
        column.speed,
    ];
    expect(speeds(), [0, 0]);

    await tester.tap(find.text('1.1.1.1:443').last);
    await tester.pump();
    expect(copied, ['1.1.1.1:443']);

    live = [];
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(speeds(), [null, null]);

    await teardownView(tester);
  });

  testWidgets('connections head the minute they opened in, newest first, '
      'under headers that do not fold', (tester) async {
    seedRequests([
      _tracker(
        id: 'a',
        host: 'alpha.test',
      ).copyWith(start: DateTime(2026, 1, 1, 10, 5)),
      _tracker(
        id: 'b',
        host: 'beta.test',
      ).copyWith(start: DateTime(2026, 1, 1, 10, 7)),
      _tracker(
        id: 'c',
        host: 'gamma.test',
      ).copyWith(start: DateTime(2026, 1, 1, 10, 7, 30)),
    ]);

    await pumpRequests(tester, size: _listSize);

    final headers = tester
        .widgetList<CollapsibleHeader>(find.byType(CollapsibleHeader))
        .toList();
    expect(
      [for (final header in headers) (header.label, header.count)],
      [('01-01 10:07', 2), ('01-01 10:05', 1)],
    );
    expect(headers.every((header) => header.onToggle == null), isTrue);
    double topOf(String host) => tester.getTopLeft(find.text(host)).dy;
    expect(topOf('gamma.test'), lessThan(topOf('beta.test')));
    expect(topOf('beta.test'), lessThan(topOf('alpha.test')));

    await teardownView(tester);
  });

  testWidgets('a failed connection that reports late joins the minute it '
      'opened in, under one header', (tester) async {
    TrackerInfo at(String id, int minute, int second) => _tracker(
      id: id,
      host: '$id.test',
    ).copyWith(start: DateTime(2026, 1, 1, 12, minute, second));
    seedRequests([at('b', 2, 0)]);
    addRequest(
      at('a', 1, 59).copyWith(
        failure: const ConnectionFailure(kind: ConnectionFailureKind.timeout),
      ),
    );
    addRequest(at('c', 2, 1));
    container.read(requestsProvider.notifier).close(['a']);

    await pumpRequests(tester, size: _listSize);

    expect(
      [
        for (final header in tester.widgetList<CollapsibleHeader>(
          find.byType(CollapsibleHeader),
        ))
          (header.label, header.count),
      ],
      [('01-01 12:02', 2), ('01-01 12:01', 1)],
    );
    double topOf(String host) => tester.getTopLeft(find.text(host)).dy;
    expect(topOf('c.test'), lessThan(topOf('b.test')));
    expect(topOf('b.test'), lessThan(topOf('a.test')));

    await teardownView(tester);
  });

  testWidgets('an open connection without traffic still counts its age', (
    tester,
  ) async {
    final open = _tracker(
      id: 'a',
      host: 'alpha.test',
    ).copyWith(start: DateTime.now().subtract(const Duration(seconds: 10)));
    seedRequests([open]);

    final unanswered = Completer<List<TrackerInfo>>();
    await pumpRequests(
      tester,
      size: _listSize,
      connectionsReader: () => unanswered.future,
    );
    final age = find.textContaining('curl · Proxy · ');
    final revision = container.read(requestsProvider).revision;
    final before = tester.widget<Text>(age).data;

    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 1100)),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(container.read(requestsProvider).revision, revision);
    expect(tester.widget<Text>(age).data, isNot(before));

    await teardownView(tester);
  });

  testWidgets('scrolled off the top, the list holds new connections behind '
      'a pill that brings them in', (tester) async {
    seedRequests([
      for (var i = 0; i < 60; i++) _tracker(id: '$i', host: 'host$i.test'),
    ]);

    await pumpRequests(tester, size: _listSize);
    await tester.pumpAndSettle();
    final list = find.byType(CustomScrollView);
    ScrollPosition position() => tester
        .state<ScrollableState>(
          find.descendant(of: list, matching: find.byType(Scrollable)),
        )
        .position;

    await tester.drag(list, const Offset(0, -300));
    await tester.pumpAndSettle();
    final offset = position().pixels;
    expect(offset, greaterThan(0));

    addRequest(_tracker(id: 'new', host: 'new.test'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    expect(find.text('1 new connection'), findsOneWidget);
    expect(find.text('new.test', skipOffstage: false), findsNothing);
    expect(position().pixels, offset);

    await tester.tap(find.text('1 new connection'));
    await tester.pumpAndSettle();

    expect(find.text('1 new connection'), findsNothing);
    expect(position().pixels, 0);
    expect(find.text('new.test'), findsOneWidget);

    await teardownView(tester);
  });

  testWidgets('the menu clears the closed connections and keeps the open '
      'ones', (tester) async {
    seedRequests([
      _tracker(id: 'a', host: 'alpha.test'),
      _tracker(id: 'b', host: 'beta.test'),
    ]);
    container.read(requestsProvider.notifier).close(['a']);
    final open = container.read(requestsProvider)['b']!;

    await pumpRequests(
      tester,
      size: _listSize,
      connectionsReader: () async => [open],
    );
    expect(find.text('alpha.test'), findsOneWidget);

    await openSubMenu(tester, 'Clear closed connections');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.text('alpha.test'), findsNothing);
    expect(find.text('beta.test'), findsOneWidget);

    await teardownView(tester);
  });

  testWidgets('a facet chip lists its values with their counts, stays open '
      'while they toggle, and its All clears them', (tester) async {
    seedRequests([
      _tracker(id: 'a', host: 'alpha.test'),
      _tracker(id: 'b', host: 'beta.test', process: 'chrome'),
      _tracker(id: 'c', host: 'gamma.test', process: 'chrome'),
    ]);

    await pumpRequests(tester, size: _listSize);
    await tester.scrollUntilVisible(
      find.widgetWithText(Chip, 'App'),
      100,
      scrollable: stripScrollable,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(Chip, 'App'));
    await tester.pumpAndSettle();
    expect(inMenu(find.text('curl')), findsOneWidget);
    expect(inMenu(find.text('2')), findsOneWidget);
    await tester.tap(inMenu(find.text('chrome')));
    await tester.pumpAndSettle();

    expect(find.byType(PopupMenu), findsOneWidget);
    expect(find.textContaining('alpha.test'), findsNothing);
    expect(find.textContaining('beta.test'), findsWidgets);

    await tester.tapAt(const Offset(300, 900));
    await tester.pumpAndSettle();
    expect(find.byType(PopupMenu), findsNothing);
    expect(
      tester.widget<Chip>(find.widgetWithText(Chip, 'App · 1')).selected,
      isTrue,
    );

    await tester.tap(find.widgetWithText(Chip, 'App · 1'));
    await tester.pumpAndSettle();
    await tester.tap(inMenu(find.text('All')));
    await tester.pumpAndSettle();

    expect(find.byType(PopupMenu), findsNothing);
    expect(find.widgetWithText(Chip, 'App'), findsOneWidget);
    expect(find.textContaining('alpha.test'), findsWidgets);

    await teardownView(tester);
  });

  testWidgets('the failed view shows repeated failed dials to one target as '
      'its newest, with how many', (tester) async {
    seedRequests([
      for (var i = 0; i < 3; i++)
        _failed(id: 't$i', host: 'udp.test', second: i),
      _failed(id: 'o', host: 'other.test', second: 3),
      _tracker(id: 'a', host: 'alpha.test'),
    ]);

    await pumpRequests(tester, size: _listSize);
    await tester.tap(find.widgetWithText(Chip, 'Failed 4'));
    await tester.pumpAndSettle();

    final rows = tester.widgetList<TrackerInfoItem>(
      find.byType(TrackerInfoItem),
    );
    expect(rows.map((row) => row.trackerInfo.id), ['o', 't2']);
    expect(find.widgetWithText(TonalChip, '×3'), findsOneWidget);
    expect(find.widgetWithText(TonalChip, 'Timeout'), findsNWidgets(2));

    await tester.tap(find.widgetWithText(Chip, 'All 5'));
    await tester.pumpAndSettle();
    expect(find.byType(TrackerInfoItem), findsNWidgets(5));
    expect(find.widgetWithText(TonalChip, '×3'), findsNothing);

    await teardownView(tester);
  });

  testWidgets('grouping by app heads each app folded, unfolds one on a tap '
      'and is kept for the page', (tester) async {
    seedRequests([
      _tracker(id: 'a', host: 'alpha.test'),
      _tracker(id: 'b', host: 'beta.test', process: 'chrome'),
      _tracker(id: 'c', host: 'gamma.test'),
    ]);
    container.listen(appSettingProvider, (_, _) {});

    await pumpRequests(tester, size: _listSize);
    await openSubMenu(tester, 'Group by');
    await tester.tap(inMenu(find.text('App')));
    await tester.pumpAndSettle();

    final headers = find.byType(CollapsibleHeader);
    final shown =
        [for (var i = 0; i < headers.evaluate().length; i++) headers.at(i)]
          ..sort(
            (a, b) =>
                tester.getTopLeft(a).dy.compareTo(tester.getTopLeft(b).dy),
          );
    expect(
      [
        for (final header in shown)
          (
            tester.widget<CollapsibleHeader>(header).label,
            tester.widget<CollapsibleHeader>(header).count,
          ),
      ],
      [('curl', 2), ('chrome', 1)],
    );
    expect(find.textContaining('alpha.test'), findsNothing);
    expect(find.textContaining('beta.test'), findsNothing);
    expect(
      container.read(appSettingProvider).recordGroupings['requests'],
      'app',
    );

    await tester.tap(
      find.byWidgetPredicate(
        (widget) => widget is CollapsibleHeader && widget.label == 'chrome',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('beta.test'), findsWidgets);
    expect(find.textContaining('alpha.test'), findsNothing);

    await teardownView(tester);
  });

  testWidgets('grouping opens on the newest group and ungrouping returns to '
      'the newest request', (tester) async {
    seedRequests([
      for (var i = 0; i < 60; i++)
        _tracker(id: '$i', host: 'host$i.test', process: 'app$i'),
    ]);
    container.listen(appSettingProvider, (_, _) {});

    await pumpRequests(tester, size: _listSize);
    await tester.pumpAndSettle();
    await openSubMenu(tester, 'Group by');
    await tester.tap(inMenu(find.text('App')));
    await tester.pumpAndSettle();

    final grouped = tester.state<ScrollableState>(
      find.descendant(
        of: find.byType(CustomScrollView),
        matching: find.byType(Scrollable),
      ),
    );
    expect(grouped.position.maxScrollExtent, greaterThan(0));
    expect(grouped.position.pixels, 0);
    final top = find.byType(CollapsibleHeader).first;
    expect(tester.widget<CollapsibleHeader>(top).label, 'app59');

    await openSubMenu(tester, 'Group by');
    await tester.tap(inMenu(find.text('None')));
    await tester.pumpAndSettle();

    final byMinute = tester.state<ScrollableState>(
      find.descendant(
        of: find.byType(CustomScrollView),
        matching: find.byType(Scrollable),
      ),
    );
    expect(byMinute.position.pixels, 0);
    expect(find.textContaining('host59.test'), findsWidgets);

    await teardownView(tester);
  });

  testWidgets('a wide page offers the facets in a bar beside the table, '
      'and narrower in the strip', (tester) async {
    seedRequests([
      _tracker(id: 'a', host: 'alpha.test'),
      _tracker(id: 'b', host: 'beta.test', process: 'chrome'),
      _tracker(id: 'c', host: 'gamma.test', process: 'chrome'),
    ]);

    await pumpRequests(tester);
    final bar = find.byType(ConnectionFacetBar);
    Finder inBar(Finder finder) => find.descendant(of: bar, matching: finder);
    expect(bar, findsOneWidget);
    expect(find.widgetWithText(Chip, 'App'), findsNothing);
    expect(find.widgetWithText(Chip, 'All 3'), findsOneWidget);
    expect(inBar(find.text('App')), findsOneWidget);
    expect(inBar(find.text('chrome')), findsOneWidget);
    expect(inBar(find.text('2')), findsOneWidget);

    expect(inBar(find.byType(SelectionCheck)), findsNothing);
    await tester.tap(inBar(find.text('chrome')));
    await tester.pumpAndSettle();
    expect(find.textContaining('alpha.test'), findsNothing);
    expect(find.textContaining('beta.test'), findsWidgets);
    expect(inBar(find.byType(SelectionCheck)), findsOneWidget);

    await tester.tap(inBar(find.text('All')));
    await tester.pumpAndSettle();
    expect(find.textContaining('alpha.test'), findsWidgets);
    expect(inBar(find.text('All')), findsNothing);

    await teardownView(tester);
    await pumpRequests(tester, size: const Size(1100, 1000));
    expect(bar, findsNothing);
    expect(find.widgetWithText(Chip, 'App'), findsOneWidget);

    await teardownView(tester);
  });

  testWidgets('a search reads field conditions, and a condition added from '
      'the strip narrows the list until its chip is deleted', (tester) async {
    seedRequests([
      _tracker(id: 'a', host: 'alpha.test'),
      _tracker(id: 'b', host: 'beta.test', process: 'chrome'),
      _tracker(id: 'c', host: 'gamma.test', process: 'chrome'),
    ]);

    await pumpRequests(tester, size: _listSize);
    await tester.tap(find.byTooltip('Search'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'app:chrome -host:gamma');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.textContaining('alpha.test'), findsNothing);
    expect(find.textContaining('beta.test'), findsWidgets);
    expect(find.textContaining('gamma.test'), findsNothing);
    await tester.enterText(find.byType(TextField), '');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.textContaining('alpha.test'), findsWidgets);

    await tester.scrollUntilVisible(
      find.widgetWithText(Chip, '+ Condition'),
      100,
      scrollable: stripScrollable,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(Chip, '+ Condition'));
    await tester.pumpAndSettle();
    expect(find.text('Add condition'), findsOneWidget);
    await tester.enterText(
      find.descendant(
        of: find.byType(FormRowTextField),
        matching: find.byType(EditableText),
      ),
      'alpha',
    );
    await tester.tap(find.text('Exclude matches'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Add'));
    await tester.pumpAndSettle();

    expect(find.text('Add condition'), findsNothing);
    expect(find.textContaining('alpha.test'), findsNothing);
    expect(find.textContaining('beta.test'), findsWidgets);
    final chip = find.widgetWithText(Chip, '-host:alpha');
    await tester.scrollUntilVisible(chip, 100, scrollable: stripScrollable);
    await tester.pumpAndSettle();
    await tester.tap(chip);
    await tester.pumpAndSettle();
    expect(chip, findsNothing);
    expect(find.textContaining('alpha.test'), findsWidgets);

    await teardownView(tester);
  });

  testWidgets('a condition from the form keeps the spaces in its value and '
      'shows it in quotes', (tester) async {
    seedRequests([
      _tracker(id: 'a', host: 'alpha.test', process: 'Google Chrome'),
      _tracker(id: 'b', host: 'beta.test', process: 'chrome'),
    ]);

    await pumpRequests(tester, size: _listSize);
    await tester.scrollUntilVisible(
      find.widgetWithText(Chip, '+ Condition'),
      100,
      scrollable: stripScrollable,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(Chip, '+ Condition'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Host'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('App').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: find.byType(FormRowTextField),
        matching: find.byType(EditableText),
      ),
      'Google Chrome',
    );
    await tester.tap(find.byTooltip('Add'));
    await tester.pumpAndSettle();

    expect(find.textContaining('alpha.test'), findsWidgets);
    expect(find.textContaining('beta.test'), findsNothing);
    await tester.scrollUntilVisible(
      find.widgetWithText(Chip, 'app:"Google Chrome"'),
      100,
      scrollable: stripScrollable,
    );
    expect(find.widgetWithText(Chip, 'app:"Google Chrome"'), findsOneWidget);

    await teardownView(tester);
  });

  testWidgets('a desktop page sums up what it shows along its foot, and a '
      'phone under its filter strip', (tester) async {
    final open = _tracker(id: 'a', host: 'alpha.test');
    seedRequests([
      open,
      _tracker(id: 'b', host: 'beta.test', process: 'chrome'),
      _tracker(id: 'c', host: 'gamma.test', process: 'chrome'),
    ]);

    await pumpRequests(tester, connectionsReader: () async => [open]);
    await tester.pump(const Duration(milliseconds: 400));
    final bar = find.byType(ConnectionStatusBar);
    Finder inBar(Finder finder) => find.descendant(of: bar, matching: finder);
    expect(find.byType(ConnectionSummary), findsNothing);
    expect(inBar(find.text('Showing 3 · Active 1')), findsOneWidget);
    expect(inBar(find.textContaining('This run ↓')), findsOneWidget);
    expect(
      inBar(find.byType(HttpCaptureEntry)),
      [if (rsFeature) findsOneWidget].firstOrNull ?? findsNothing,
    );

    await tester.tap(targetOf('beta.test'));
    await tester.pumpAndSettle();
    expect(
      inBar(find.text('Showing 3 · Active 1 · 1 selected')),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(Chip, 'Active 1'));
    await tester.pumpAndSettle();
    expect(
      inBar(find.text('Showing 1 · Active 1 · 1 selected')),
      findsOneWidget,
    );

    await teardownView(tester);
    await pumpRequests(
      tester,
      size: _listSize,
      connectionsReader: () async => [open],
    );
    await tester.pump(const Duration(milliseconds: 400));
    final summary = find.byType(ConnectionSummary);
    expect(bar, findsNothing);
    expect(
      find.descendant(
        of: summary,
        matching: find.textContaining('Active 1 · This run ↓'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(Chip, 'Active 1'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: summary,
        matching: find.text('1 after filtering · Active 1'),
      ),
      findsOneWidget,
    );

    await teardownView(tester);
  });

  testWidgets('the status chips count the connections and show one status '
      'at a time, and a tapped exit narrows the exit facet', (tester) async {
    final open = _tracker(id: 'a', host: 'alpha.test');
    seedRequests([
      open,
      _failed(id: 'b', host: 'beta.test', chains: const ['Tokyo']),
    ]);

    await pumpRequests(tester, connectionsReader: () async => [open]);
    await tester.pump(const Duration(milliseconds: 400));
    Chip chip(String label) =>
        tester.widget<Chip>(find.widgetWithText(Chip, label));
    expect(chip('All 2').selected, isTrue);
    expect(chip('Active 1').selected, isFalse);
    expect(
      [
        for (final chip in tester.widgetList<Chip>(find.byType(Chip)))
          if (chip.label.startsWith('Decrypted')) chip.label,
      ],
      [if (rsFeature) 'Decrypted 0'],
    );

    await tester.tap(find.widgetWithText(Chip, 'Failed 1'));
    await tester.pumpAndSettle();
    expect(chip('Failed 1').selected, isTrue);
    expect(chip('All 2').selected, isFalse);
    expect(find.textContaining('alpha.test'), findsNothing);
    expect(find.widgetWithText(TonalChip, 'Timeout'), findsOneWidget);

    await tester.tap(find.widgetWithText(Chip, 'Active 1'));
    await tester.pumpAndSettle();
    expect(find.textContaining('alpha.test'), findsWidgets);
    expect(find.textContaining('beta.test'), findsNothing);

    await tester.tap(find.widgetWithText(Chip, 'All 2'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TonalChip, 'Tokyo'));
    await tester.pumpAndSettle();
    expect(find.textContaining('alpha.test'), findsNothing);
    expect(
      find.descendant(
        of: find.byType(ConnectionFacetBar),
        matching: find.text('Tokyo'),
      ),
      findsOneWidget,
    );

    await openSubMenu(tester, 'Group by');
    expect(inMenu(find.text('Filter')), findsNothing);

    await teardownView(tester);
  });

  group('a refresh builds only what changed', () {
    final full = [
      for (var index = 0; index < 499; index++) _tracker(id: 'r$index'),
      _tracker(id: 'r499', host: 'latest.test'),
    ];

    Future<int> rowsBuiltBy(WidgetTester tester, void Function() change) async {
      var built = 0;
      debugOnRebuildDirtyWidget = (element, _) {
        final widget = element.widget;
        if (widget is TrackerInfoItem || widget is TrackerInfoTableRow) {
          built++;
        }
      };
      addTearDown(() => debugOnRebuildDirtyWidget = null);
      change();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();
      debugOnRebuildDirtyWidget = null;
      return built;
    }

    for (final (name, size) in const [
      ('list', _listSize),
      ('table', _tableSize),
    ]) {
      testWidgets('a full $name builds only the request added', (tester) async {
        seedRequests(full);
        await pumpRequests(tester, size: size);
        await tester.pump(const Duration(seconds: 1));

        final built = await rowsBuiltBy(
          tester,
          () => addRequest(_tracker(id: 'new')),
        );

        expect(built, 1);
        await teardownView(tester);
      });
    }

    testWidgets('traffic rebuilds only the list row it reaches, and its '
        'detail opens on the latest', (tester) async {
      seedRequests(full);
      await pumpRequests(tester, size: _listSize);
      await tester.pump(const Duration(seconds: 1));

      final built = await rowsBuiltBy(
        tester,
        () => container.read(requestsProvider.notifier).updateTraffic({
          'r499': (upload: 0, download: 2048),
        }),
      );
      expect(built, 1);

      await tester.tap(find.text('latest.test'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(TrackerInfoDetailView),
          matching: find.text(2048.traffic.show),
        ),
        findsOneWidget,
      );

      await teardownView(tester);
    });

    testWidgets('traffic rebuilds only the grouped row it reaches, and its '
        'detail opens on the latest', (tester) async {
      seedRequests(full);
      await pumpRequests(tester, size: _listSize);
      await openSubMenu(tester, 'Group by');
      await tester.tap(inMenu(find.text('App')));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CollapsibleHeader));
      await tester.pumpAndSettle();

      final built = await rowsBuiltBy(
        tester,
        () => container.read(requestsProvider.notifier).updateTraffic({
          'r499': (upload: 0, download: 2048),
        }),
      );
      expect(built, 1);

      await tester.tap(find.text('latest.test'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(TrackerInfoDetailView),
          matching: find.text(2048.traffic.show),
        ),
        findsOneWidget,
      );

      await teardownView(tester);
    });
  });

  if (rsFeature) {
    testWidgets('the bar says whether capture records and opens its panel', (
      tester,
    ) async {
      container
          .read(patchClashConfigProvider.notifier)
          .update(
            (state) => state.copyWith(
              mitm: state.mitm.copyWith(enable: true, capture: true),
            ),
          );
      await pumpRequests(tester);

      await tester.tap(find.text(currentAppLocalizations.httpCapturing));
      await tester.pumpAndSettle();

      expect(find.byType(HttpCaptureView), findsOneWidget);
      await teardownView(tester);
    });

    testWidgets('turning decryption on from capture leaves the tools list '
        'for the connections in the bottom bar', (tester) async {
      navigationPort = navigation;
      addTearDown(() => navigationPort = null);
      await pumpRequests(tester, size: _listSize);
      final navigator = tester.state<NavigatorState>(
        find.byType(Navigator).first,
      );
      unawaited(
        navigator.push(
          PageRouteBuilder<void>(
            pageBuilder: (_, _, _) => const RequestsView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(currentAppLocalizations.httpCaptureOff), findsNothing);
      await tester.tap(find.byType(HttpCaptureEntry).last);
      await tester.pumpAndSettle();
      container
          .read(patchClashConfigProvider.notifier)
          .update(
            (state) => state.copyWith(mitm: state.mitm.copyWith(enable: true)),
          );
      Navigator.of(tester.element(find.byType(HttpCaptureView))).pop();
      await tester.pumpAndSettle();

      expect(find.byType(RequestsView), findsOneWidget);
      expect(container.read(currentPageLabelProvider), PageLabel.requests);
      await teardownView(tester);
    });
  }
}

class _MockCore extends Mock implements CoreHandlerInterface {}
