import 'dart:async';
import 'dart:convert';

import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/features/features.dart';
import 'package:fl_clash/manager/hotkey_manager.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/views/connection/requests.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/core_mocks.dart';
import '../helpers/detail_tabs.dart';
import '../helpers/glyph_finders.dart';
import '../helpers/hidden_segments.dart';
import '../helpers/scrollbar.dart';
import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

const _tableSize = Size(1400, 1000);
const _listSize = Size(600, 1000);
const _sheetSize = Size(800, 1000);

TrackerInfo _tracker({
  required int id,
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
  required int id,
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

  void seedRequests(List<TrackerInfo> requests, {int closedCapacity = 500}) {
    final notifier = container.read(requestsProvider.notifier);
    notifier.value = ConnectionLog(closedCapacity);
    for (final request in requests) {
      notifier.addRequests([request]);
    }
  }

  void addRequest(TrackerInfo request) {
    container.read(requestsProvider.notifier).addRequests([request]);
  }

  Future<void> pumpRequests(
    WidgetTester tester, {
    Size size = _tableSize,
    Future<List<TrackerInfo>> Function()? connectionsReader,
    bool hotKeys = false,
  }) async {
    container.read(viewSizeProvider.notifier).update((_) => size);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final app = TestApp(
      child: RequestsView(connectionsReader: connectionsReader),
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: hotKeys
            ? HotKeyManager(
                registerHotKeys: ({required specs}) => const [],
                hotKeyEventSource: () => const Stream.empty(),
                child: app,
              )
            : app,
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  Finder inFilterRow(Finder finder) => find.descendant(
    of: find.byType(ConditionFilterRow<TrackerInfo, ConnectionStatus>),
    matching: finder,
  );

  Finder statusSegment(String label) => find.descendant(
    of: find.byType(SegmentedControl<ConnectionStatus>),
    matching: find.text(label),
  );

  ConnectionStatus shownStatus(WidgetTester tester) => tester
      .widget<SegmentedControl<ConnectionStatus>>(
        find.byType(SegmentedControl<ConnectionStatus>),
      )
      .value;

  final addCondition = inFilterRow(find.byGlyph(AppGlyphs.add));

  Finder inBlock(Finder finder) => find.descendant(
    of: find.byType(ConditionBlock<TrackerInfo>),
    matching: finder,
  );

  Finder inDialog(Finder finder) =>
      find.descendant(of: find.byType(AlertDialog), matching: finder);

  final dialogField = find.descendant(
    of: find.byType(AlertDialog),
    matching: find.byType(EditableText),
  );

  Finder removeOf(String chip) => find.descendant(
    of: find
        .ancestor(of: inBlock(find.text(chip)), matching: find.byType(Row))
        .first,
    matching: find.byGlyph(AppGlyphs.close),
  );

  Finder targetOf(String host) => find.descendant(
    of: find.byType(TrackerInfoItem),
    matching: find.textContaining(host),
  );

  List<W> topDown<W extends Widget>(WidgetTester tester) =>
      [...tester.widgetList<W>(find.byType(W))]..sort(
        (a, b) => tester
            .getTopLeft(find.byWidget(a))
            .dy
            .compareTo(tester.getTopLeft(find.byWidget(b)).dy),
      );

  List<int> selectedRows(WidgetTester tester) => [
    for (final element in find.byType(TrackerInfoItem).evaluate())
      if (tester
              .widget<DecorationListItem>(
                find.descendant(
                  of: find.byWidget(element.widget),
                  matching: find.byType(DecorationListItem),
                ),
              )
              .isSelected ??
          false)
        (element.widget as TrackerInfoItem).trackerInfo.id,
  ];

  Finder rowOf(int id) => find.byWidgetPredicate(
    (widget) => widget is TrackerInfoItem && widget.trackerInfo.id == id,
  );

  Finder inRow(int id, Finder finder) =>
      find.descendant(of: rowOf(id), matching: finder);

  Future<void> teardownView(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  }

  testWidgets('a sheet dragged to another height at the same width lays the '
      'page out again without building it again', (tester) async {
    seedRequests([_tracker(id: 1, host: 'alpha.test')]);
    container.read(viewSizeProvider.notifier).update((_) => _listSize);
    tester.view.physicalSize = _listSize;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final height = ValueNotifier(900.0);
    addTearDown(height.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: ValueListenableBuilder(
            valueListenable: height,
            builder: (_, value, page) => Align(
              alignment: Alignment.topCenter,
              child: SizedBox(height: value, child: page),
            ),
            child: const RequestsView(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    var built = 0;
    debugOnRebuildDirtyWidget = (element, _) {
      if (element.widget is Scaffold) {
        built++;
      }
    };
    addTearDown(() => debugOnRebuildDirtyWidget = null);

    for (final value in [800.0, 700.0, 600.0]) {
      height.value = value;
      await tester.pump();
    }
    debugOnRebuildDirtyWidget = null;

    expect(built, 0);
    expect(targetOf('alpha.test'), findsOneWidget);
    await teardownView(tester);
  });

  testWidgets('shows the empty state without any request', (tester) async {
    await pumpRequests(tester);

    expect(find.text('No Connections yet'), findsOneWidget);
    expect(find.text('Select a connection'), findsOneWidget);
    expect(tester.takeException(), null);

    await teardownView(tester);
  });

  testWidgets('renders the requests already in the store on mount', (
    tester,
  ) async {
    seedRequests([
      _tracker(id: 1, host: 'alpha.test'),
      _tracker(id: 2, host: 'beta.test'),
    ]);

    await pumpRequests(tester);

    expect(find.text('No Connections yet'), findsNothing);
    expect(targetOf('alpha.test'), findsWidgets);
    expect(targetOf('beta.test'), findsWidgets);

    await teardownView(tester);
  });

  testWidgets('a request arriving after mount reaches the list', (
    tester,
  ) async {
    seedRequests([_tracker(id: 1, host: 'alpha.test')]);

    await pumpRequests(tester);
    expect(targetOf('gamma.test'), findsNothing);

    addRequest(_tracker(id: 3, host: 'gamma.test'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    await tester.pump();

    expect(targetOf('gamma.test'), findsWidgets);

    await teardownView(tester);
  });

  testWidgets('traffic after a request opened reaches its row', (tester) async {
    seedRequests([_tracker(id: 1, host: 'alpha.test')]);

    await pumpRequests(tester);
    final total = (460 + 257835).traffic.show;
    expect(inRow(1, _figure(total)), findsNothing);

    container.read(requestsProvider.notifier).updateTraffic({
      1: (upload: 460, download: 257835),
    });
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    await tester.pump();

    expect(inRow(1, _figure(total)), findsOneWidget);

    await teardownView(tester);
  });

  testWidgets('holding the scrollbar thumb floats the start time beside it', (
    tester,
  ) async {
    final requests = List.generate(
      200,
      (i) => TrackerInfo(
        id: i,
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
    // rests 24 dp (half the 48 dp minimum thumb) below the track's top edge.
    final track = tester.getRect(find.byType(ScrollToEndBox));
    expect(
      tester.getCenter(find.byKey(hintKey)).dy,
      closeTo(track.top + 24, 6),
    );

    await gesture.up();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byKey(hintKey), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(find.byKey(hintKey), findsNothing);

    await teardownView(tester);
  });

  testWidgets('a desktop page builds only the rows in view', (tester) async {
    seedRequests([for (var i = 0; i < 500; i++) _tracker(id: i)]);

    await pumpRequests(tester);

    final built = find.byType(TrackerInfoItem).evaluate().length;
    expect(built, greaterThan(0));
    expect(built, lessThan(60));

    await teardownView(tester);
  });

  testWidgets('every width lists its requests as rows under the minute they '
      'opened in, without a column header', (tester) async {
    seedRequests([_tracker(id: 1, host: 'alpha.test')]);

    for (final size in [_listSize, _sheetSize, _tableSize]) {
      await pumpRequests(tester, size: size);

      expect(find.byType(TrackerInfoItem), findsOneWidget, reason: '$size');
      expect(find.byType(RecordMinuteHeader), findsOneWidget, reason: '$size');
      expect(find.text('Target'), findsNothing, reason: '$size');
      expect(find.text('Requests'), findsWidgets, reason: '$size');
      await teardownView(tester);
    }
  });

  testWidgets('a wide page shows the row it selects in a pane beside the '
      'list, and an empty state once the row again clears it', (tester) async {
    seedRequests([
      _tracker(id: 1, host: 'alpha.test'),
      _tracker(id: 2, host: 'beta.test'),
    ]);

    await pumpRequests(tester);
    final header = find.byType(TrackerInfoHeader);
    final empty = find.text('Select a connection');
    expect(header, findsNothing);
    expect(empty, findsOneWidget);
    expect(
      find.text(
        'Its timeline, HTTP requests and connection details appear '
        'here',
      ),
      findsOneWidget,
    );
    final list = tester.getRect(find.byType(ScrollToEndBox));
    final segment = tester.getRect(
      find.byType(ConnectedButtonBar<RequestsSegment>),
    );
    expect(
      tester.getRect(find.byTooltip('Search')).left,
      greaterThan(list.right),
    );
    expect(
      tester
          .getTopLeft(
            find
                .ancestor(of: empty, matching: find.byType(ClipRSuperellipse))
                .first,
          )
          .dy,
      segment.top,
    );

    await tester.tap(targetOf('alpha.test'));
    await tester.pumpAndSettle();
    expect(find.byType(TrackerInfoDetailSheet), findsNothing);
    expect(find.byType(TrackerSelectedDetail), findsOneWidget);
    expect(tester.widget<TrackerInfoHeader>(header).trackerInfo.id, 1);
    expect(tester.getTopLeft(header).dx, greaterThanOrEqualTo(list.right));
    expect(
      tester
          .getTopLeft(
            find
                .ancestor(
                  of: find.byType(TrackerSelectedDetail),
                  matching: find.byType(ClipRSuperellipse),
                )
                .first,
          )
          .dy,
      segment.top,
    );
    expect(selectedRows(tester), [1]);
    expect(tester.getRect(find.byType(ScrollToEndBox)), list);

    expect(empty, findsNothing);

    await tester.tap(targetOf('beta.test'));
    await tester.pumpAndSettle();
    expect(selectedRows(tester), [2]);
    await tester.tap(targetOf('beta.test'));
    await tester.pumpAndSettle();
    expect(selectedRows(tester), isEmpty);
    expect(empty, findsOneWidget);

    await teardownView(tester);
  });

  testWidgets('a desktop page too narrow for the pane shows the row it selects '
      'in a side sheet, until Esc closes it as it does any sheet', (
    tester,
  ) async {
    seedRequests([
      _tracker(id: 1, host: 'alpha.test'),
      _tracker(id: 2, host: 'beta.test'),
    ]);

    await pumpRequests(tester, size: _sheetSize, hotKeys: true);
    await tester.tap(targetOf('alpha.test'));
    await tester.pumpAndSettle();

    final sheet = find.byType(TrackerInfoDetailSheet);
    expect(sheet, findsOneWidget);
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
      1,
    );
    expect(selectedRows(tester), [1]);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(sheet, findsNothing);
    expect(selectedRows(tester), isEmpty);

    await teardownView(tester);
  });

  testWidgets('a selection moves between the pane and the side sheet as the '
      'page crosses the width the pane fits', (tester) async {
    seedRequests([_tracker(id: 1, host: 'alpha.test')]);

    await pumpRequests(tester);
    await tester.tap(targetOf('alpha.test'));
    await tester.pumpAndSettle();
    expect(find.byType(TrackerInfoDetailSheet), findsNothing);
    expect(find.byType(TrackerInfoHeader), findsOneWidget);

    tester.view.physicalSize = _sheetSize;
    await tester.pumpAndSettle();
    expect(find.byType(TrackerInfoDetailSheet), findsOneWidget);
    expect(find.byType(TrackerInfoHeader), findsOneWidget);

    tester.view.physicalSize = _tableSize;
    await tester.pumpAndSettle();
    expect(find.byType(TrackerInfoDetailSheet), findsNothing);
    expect(find.byType(TrackerInfoHeader), findsOneWidget);
    expect(selectedRows(tester), [1]);

    await teardownView(tester);
  });

  testWidgets('a narrower desktop page shows the row it selects in a side '
      'sheet, which a tap outside closes', (tester) async {
    seedRequests([
      _tracker(id: 1, host: 'alpha.test'),
      _tracker(id: 2, host: 'beta.test'),
    ]);

    await pumpRequests(tester, size: _sheetSize);
    expect(find.byType(TrackerInfoItem), findsNWidgets(2));

    await tester.tap(targetOf('beta.test'));
    await tester.pumpAndSettle();

    final sheet = find.byType(TrackerInfoDetailSheet);
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
      2,
    );
    expect(
      find.descendant(
        of: sheet,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is TrackerInfoDetailView && widget.trackerInfo.id == 2,
        ),
      ),
      findsOneWidget,
    );

    expect(
      find.descendant(of: sheet, matching: find.byTooltip('More')),
      findsOneWidget,
    );

    await tester.tapAt(const Offset(20, 500));
    await tester.pumpAndSettle();
    expect(sheet, findsNothing);
    expect(selectedRows(tester), isEmpty);

    await teardownView(tester);
  });

  for (final (layout, size) in [
    ('side sheet', _sheetSize),
    ('detail pane', _tableSize),
  ]) {
    testWidgets('a selected connection that leaves the log and then the '
        'list takes its $layout with it', (tester) async {
      final open = [
        _tracker(id: 1, host: 'alpha.test'),
        _tracker(id: 2, host: 'beta.test'),
      ];
      seedRequests(open, closedCapacity: 1);
      final requests = container.read(requestsProvider.notifier);

      await pumpRequests(
        tester,
        size: size,
        connectionsReader: () async => open,
      );
      await tester.tap(targetOf('alpha.test'));
      await tester.pumpAndSettle();
      final detail = find.byType(TrackerInfoHeader);
      expect(detail, findsOneWidget);
      expect(selectedRows(tester), [1]);

      requests.close([1]);
      await tester.pumpAndSettle();
      expect(detail, findsOneWidget);
      requests.close([2]);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(detail, findsNothing);
      expect(find.byType(TrackerInfoDetailSheet), findsNothing);
      expect(selectedRows(tester), isEmpty);

      await teardownView(tester);
    });
  }

  testWidgets('a row the list has just dropped still answers a tap that '
      'lands before it is gone from the screen', (tester) async {
    final open = _tracker(id: 15, host: 'open.test');
    seedRequests([
      _failed(id: 101, host: 'one.test', second: 1),
      _failed(id: 102, host: 'two.test', second: 2),
      open,
    ], closedCapacity: 2);
    await pumpRequests(tester, connectionsReader: () async => [open]);
    await tester.tap(statusSegment('Failed 2'));
    await tester.pumpAndSettle();

    addRequest(_failed(id: 103, host: 'three.test', second: 3));
    await tester.binding.delayed(const Duration(milliseconds: 400));
    await tester.tap(targetOf('one.test'));
    expect(tester.takeException(), isNull);
    await tester.pumpAndSettle();
    expect(targetOf('one.test'), findsNothing);
    expect(targetOf('three.test'), findsOneWidget);

    await teardownView(tester);
  });

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
    final open = _tracker(id: 1, host: 'alpha.test');
    seedRequests([open, _tracker(id: 2, host: 'beta.test', process: 'chrome')]);

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
    expect(inBlock(find.text('Equals curl')), findsOneWidget);

    await openMenu(tester, 'alpha.test');
    await tester.tap(find.text('Hide this host'));
    await tester.pumpAndSettle();
    expect(targetOf('alpha.test'), findsNothing);
    expect(inBlock(find.text('Excludes alpha.test')), findsOneWidget);

    await teardownView(tester);
  });

  testWidgets('a row shows its connection\'s latest traffic, and leaves its '
      'speed blank once it closes', (tester) async {
    final open = _tracker(id: 1, host: 'alpha.test');
    seedRequests([open]);
    var live = [open];
    const total = 3 * 1024 * 1024;

    await pumpRequests(tester, connectionsReader: () async => live);
    await tester.pump(const Duration(seconds: 1));
    expect(inRow(1, _figure(total.traffic.show)), findsNothing);

    live = [open.copyWith(download: total)];
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(inRow(1, _figure(total.traffic.show)), findsOneWidget);
    final speed = inRow(1, _figureContaining('/s'));
    expect(speed, findsOneWidget);

    live = [];
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(inRow(1, _figure(total.traffic.show)), findsOneWidget);
    expect(speed, findsNothing);

    await teardownView(tester);
  });

  testWidgets('a row follows an open connection whose route changes', (
    tester,
  ) async {
    final open = _tracker(id: 1, host: 'alpha.test', chains: ['Route A']);
    seedRequests([open]);
    var live = [open];

    await pumpRequests(tester, connectionsReader: () async => live);
    await tester.pump(const Duration(seconds: 1));
    Finder inRoute(String text) => inRow(1, find.textContaining(text));
    expect(inRoute('Route A'), findsOneWidget);

    live = [
      open.copyWith(chains: ['Route B'], download: 10),
    ];
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(inRoute('Route A'), findsNothing);
    expect(inRoute('Route B'), findsOneWidget);

    await teardownView(tester);
  });

  testWidgets('a refresh rebuilds the rows on screen rather than the log\'s '
      'rows, however long the log', (tester) async {
    final start = DateTime.utc(2026);
    final closed = [
      for (var i = 0; i < 2000; i++)
        _tracker(id: 10000 + i).copyWith(
          start: start.add(Duration(seconds: i)),
          closedAt: start.add(Duration(seconds: i + 1)),
        ),
    ];
    List<TrackerInfo> open(int round) => [
      for (var i = 0; i < 50; i++)
        _tracker(
          id: 20000 + i,
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
    debugOnRebuildDirtyWidget = (element, _) {
      if (element.widget is TrackerInfoItem) {
        rows++;
      }
    };
    addTearDown(() => debugOnRebuildDirtyWidget = null);
    for (var frame = 0; frame < 90 && rows == 0; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    debugOnRebuildDirtyWidget = null;

    expect(rows, greaterThan(0));
    expect(rows, lessThan(60));
    expect(
      rows,
      lessThanOrEqualTo(
        find.byType(TrackerInfoItem, skipOffstage: false).evaluate().length,
      ),
    );

    await teardownView(tester);
  });

  Finder dotOf(int id) => inRow(
    id,
    find.descendant(
      of: find.byType(TrackerAppWell),
      matching: find.byType(PositionedDirectional),
    ),
  );

  testWidgets('one refresh shows a row closing and another row\'s traffic '
      'moving', (tester) async {
    final a = _tracker(id: 1, host: 'alpha.test', download: 1024);
    final b = _tracker(id: 2, host: 'beta.test');
    seedRequests([a, b]);
    var live = [a, b];
    const total = 3 * 1024 * 1024;

    await pumpRequests(tester, connectionsReader: () async => live);
    await tester.pump(const Duration(seconds: 1));
    expect(dotOf(1), findsOneWidget);
    expect(inRow(1, _figureContaining('/s')), findsOneWidget);

    live = [b.copyWith(download: total, upload: 4096)];
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(dotOf(1), findsNothing);
    expect(inRow(1, _figureContaining('/s')), findsNothing);
    expect(inRow(1, _figure(1024.traffic.show)), findsOneWidget);
    expect(dotOf(2), findsOneWidget);
    expect(inRow(2, _figure((total + 4096).traffic.show)), findsOneWidget);

    await teardownView(tester);
  });

  testWidgets('a row shows a host that arrives late, then a failure, each in a '
      'refresh that moves its traffic', (tester) async {
    final open = _tracker(id: 1, host: '');
    seedRequests([open]);
    var live = [open];

    await pumpRequests(tester, connectionsReader: () async => live);
    await tester.pump(const Duration(seconds: 1));
    expect(targetOf('1.1.1.1'), findsOneWidget);
    expect(inRow(1, find.textContaining('Timeout')), findsNothing);

    final late = open.copyWith(
      metadata: open.metadata.copyWith(host: 'late.test'),
      download: 1024,
    );
    live = [late];
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(targetOf('late.test'), findsOneWidget);
    expect(inRow(1, _figure(1024.traffic.show)), findsOneWidget);

    live = [
      late.copyWith(
        failure: const ConnectionFailure(kind: ConnectionFailureKind.timeout),
        download: 2048,
      ),
    ];
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(inRow(1, find.textContaining('Timeout')), findsOneWidget);
    expect(inRow(1, _figure(2048.traffic.show)), findsOneWidget);

    await teardownView(tester);
  });

  testWidgets('rows built again after scrolling away show their own '
      'connection\'s latest traffic', (tester) async {
    final start = DateTime.utc(2026);
    var round = 0;
    List<TrackerInfo> open() => [
      for (var i = 0; i < 200; i++)
        _tracker(
          id: 20000 + i,
          download: round * 1000 + i,
        ).copyWith(start: start.add(Duration(seconds: i))),
    ];
    seedRequests(open());
    var live = open();

    await pumpRequests(tester, connectionsReader: () async => live);
    await tester.pump(const Duration(seconds: 1));
    final list = find.byType(ScrollToEndBox);
    final shown = {
      for (final row in tester.widgetList<TrackerInfoItem>(
        find.byType(TrackerInfoItem),
      ))
        row.trackerInfo.id,
    };

    await tester.drag(list, const Offset(0, -3000));
    await tester.pump();
    expect(
      find
          .byType(TrackerInfoItem)
          .evaluate()
          .map((element) => (element.widget as TrackerInfoItem).trackerInfo.id),
      everyElement(isNot(isIn(shown))),
    );
    round = 7;
    live = open();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.drag(list, const Offset(0, 6000));
    await tester.pumpAndSettle();

    final latest = {
      for (final trackerInfo in live) trackerInfo.id: trackerInfo,
    };
    final rows = tester
        .widgetList<TrackerInfoItem>(find.byType(TrackerInfoItem))
        .toList();
    expect(rows, isNotEmpty);
    for (final row in rows) {
      final id = row.trackerInfo.id;
      expect(
        inRow(id, _figure(latest[id]!.download.traffic.show)),
        findsOneWidget,
        reason: '$id',
      );
    }

    await teardownView(tester);
  });

  testWidgets('an open row the refresh keeps still ticks its duration each '
      'second', (tester) async {
    final a = _tracker(id: 1, host: 'alpha.test');
    seedRequests([a]);

    await pumpRequests(tester, connectionsReader: () async => [a]);
    await tester.pump(const Duration(seconds: 1));
    var rows = 0;
    var ticks = 0;
    debugOnRebuildDirtyWidget = (element, _) {
      if (element.widget is TrackerInfoItem) {
        rows++;
      } else if (element.widget is ListenableBuilder &&
          element.findAncestorWidgetOfExactType<TrackerLifetime>() != null) {
        ticks++;
      }
    };
    addTearDown(() => debugOnRebuildDirtyWidget = null);
    for (var second = 1; second <= 3; second++) {
      await tester.pump(const Duration(seconds: 1));
    }
    await tester.pump(const Duration(milliseconds: 100));
    debugOnRebuildDirtyWidget = null;

    expect(rows, 0);
    expect(ticks, greaterThanOrEqualTo(3));

    await teardownView(tester);
  });

  testWidgets('following pauses when the list is scrolled off its head and '
      'resumes when it is scrolled back', (tester) async {
    seedRequests([for (var i = 0; i < 60; i++) _tracker(id: i)]);

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

  final more = find.descendant(
    of: find.byType(AppBar),
    matching: find.byGlyph(AppGlyphs.more),
  );

  Future<void> openSubMenu(WidgetTester tester, String label) async {
    await tester.tap(more);
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

  for (final (layout, size) in [
    ('side sheet', _sheetSize),
    ('detail pane', _tableSize),
  ]) {
    testWidgets('a connection the log lets go while the list, off its head, '
        'keeps its row stays in its $layout', (tester) async {
      final open = [
        for (var index = 0; index < 60; index++)
          _tracker(id: index, host: 'h$index.test'),
      ];
      seedRequests(open, closedCapacity: 5);
      final requests = container.read(requestsProvider.notifier);

      await pumpRequests(
        tester,
        size: size,
        connectionsReader: () async => open,
      );
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ScrollToEndBox), const Offset(0, -300));
      await tester.pumpAndSettle();
      final id = tester
          .widgetList<TrackerInfoItem>(
            find.byType(TrackerInfoItem).hitTestable(),
          )
          .first
          .trackerInfo
          .id;
      await tester.tap(targetOf('h$id.test').hitTestable().first);
      await tester.pumpAndSettle();

      requests.close([id]);
      requests.close([for (var index = 55; index < 60; index++) index]);
      expect(container.read(requestsProvider)[id], isNull);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(selectedRows(tester), [id]);
      final header = find.byType(TrackerInfoHeader);
      expect(header, findsOneWidget);
      expect(
        tester.widget<TrackerInfoHeader>(header).trackerInfo.isActive,
        isFalse,
      );

      await teardownView(tester);
    });
  }

  testWidgets('a connection closed from its menu leaves the list at '
      'once, though a refresh was already queued', (tester) async {
    final core = coreMocks();
    final alpha = _tracker(id: 1, host: 'alpha.test');
    final beta = _tracker(id: 2, host: 'beta.test');
    var live = [alpha, beta];
    when(() => core.api.closeConnections(ids: any(named: 'ids'))).thenAnswer((
      call,
    ) async {
      final ids = call.namedArguments[#ids] as List<int>;
      live = [
        for (final info in live)
          if (!ids.contains(info.id)) info,
      ];
    });
    container.dispose();
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(TestProfiles.new),
        coreHandlerProvider.overrideWithValue(core.controller),
      ],
    );
    globalState.container = container;
    seedRequests([alpha, beta]);

    await pumpRequests(tester, connectionsReader: () async => live);
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(statusSegment('Active 2'));
    await tester.pumpAndSettle();
    await openMenu(tester, 'alpha.test');

    addRequest(_tracker(id: 3, host: 'gamma.test'));
    await tester.tap(find.text('Close connection'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    verify(() => core.api.closeConnections(ids: [1])).called(1);
    expect(targetOf('alpha.test'), findsNothing);

    await teardownView(tester);
  });

  testWidgets('a connection without a host copies its address from its menu', (
    tester,
  ) async {
    seedRequests([_tracker(id: 1, host: '')]);
    final copied = mockClipboard(tester);

    await pumpRequests(tester);
    await openMenu(tester, '1.1.1.1');
    await tester.tap(find.text('Copy destination'));
    await tester.pumpAndSettle();
    expect(copied, ['1.1.1.1:443']);

    await teardownView(tester);
  });

  testWidgets('a phone\'s detail head closes the connection, and the menu in '
      'the sheet\'s bar copies it but sets no filter', (tester) async {
    final core = coreMocks();
    when(
      () => core.api.closeConnections(ids: any(named: 'ids')),
    ).thenAnswer((_) async {});
    container.dispose();
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(TestProfiles.new),
        coreHandlerProvider.overrideWithValue(core.controller),
      ],
    );
    globalState.container = container;
    final open = _tracker(id: 1, host: 'alpha.test', process: 'chrome');
    seedRequests([open, _tracker(id: 2, host: 'beta.test', process: 'slack')]);

    await pumpRequests(
      tester,
      size: _listSize,
      connectionsReader: () async => [open],
    );
    await tester.tap(find.text('alpha.test'));
    await tester.pumpAndSettle();

    final detail = find.byType(TrackerInfoDetailView);
    expect(detail, findsOneWidget);
    final header = find.byType(TrackerInfoHeader);
    Finder inHeader(Finder finder) =>
        find.descendant(of: header, matching: finder);
    expect(find.text('Connection details'), findsOneWidget);
    final handle = find.byType(SheetDragHandle);
    final scale = tester.getRect(handle).height / SheetDragHandle.height;
    expect(
      (tester.getTopLeft(header).dy - tester.getTopLeft(handle).dy) / scale,
      closeTo(sheetAppBarHeight + appBarContentGap, 0.01),
    );
    expect(inHeader(find.byTooltip('More')), findsNothing);
    await tester.tap(inHeader(find.byTooltip('Close connection')));
    await tester.pump();
    verify(() => core.api.closeConnections(ids: [1])).called(1);

    await tester.tap(
      find.descendant(
        of: find.ancestor(of: header, matching: find.byType(Scaffold)).first,
        matching: find.byTooltip('More'),
      ),
    );
    await tester.pumpAndSettle();
    for (final label in ['Copy host', 'Copy destination', 'Copy summary']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('Only this app'), findsNothing);
    expect(find.text('Hide this host'), findsNothing);

    await teardownView(tester);
  });

  testWidgets('a phone\'s detail opens half way with its head and tabs in '
      'view, and its content swiped up opens it all the way', (tester) async {
    seedRequests([_tracker(id: 1, host: 'alpha.test')]);
    double sheetTop() => tester.getTopLeft(find.byType(SheetDragHandle)).dy;

    await pumpRequests(tester, size: _listSize);
    await tester.tap(find.text('alpha.test'));
    await tester.pumpAndSettle();

    expect(
      sheetTop(),
      closeTo(_listSize.height * (1 - snapSheetDetents.first), 1),
    );
    expect(
      tester.getBottomLeft(find.byType(SegmentedControl<int>)).dy,
      lessThan(_listSize.height),
    );

    await tester.flingFrom(
      Offset(_listSize.width / 2, _listSize.height - 80),
      const Offset(0, -150),
      900,
    );
    await tester.pumpAndSettle();
    expect(
      sheetTop(),
      closeTo(_listSize.height * (1 - snapSheetDetents.last), 1),
    );

    await teardownView(tester);
  });

  testWidgets('a phone\'s detail heads with its connection and a state that '
      'follows it', (tester) async {
    final open = _tracker(id: 1, host: 'alpha.test');
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
    expect(
      inHeader(find.textContaining('curl · Proxy · Active ')),
      findsOneWidget,
    );

    live = [];
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(inHeader(find.textContaining('Active')), findsNothing);
    expect(inHeader(find.text('curl · Proxy · Closed')), findsOneWidget);

    await teardownView(tester);
  });

  testWidgets('a detail runs its path to the node it left by, shows speeds '
      'only while open, and copies an address on a press but not a time', (
    tester,
  ) async {
    final open = _tracker(id: 1, host: 'alpha.test');
    seedRequests([open]);
    var live = [open];
    final copied = mockClipboard(tester);

    await pumpRequests(tester, connectionsReader: () async => live);
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(targetOf('alpha.test'));
    await tester.pumpAndSettle();
    await openDetailTab(tester, 'Info');

    final steps = tester
        .widgetList<TrackerRailRow>(find.byType(TrackerRailRow))
        .toList();
    expect(
      [for (final step in steps) (step.title, step.mark)],
      [
        ('curl', RailMark.step),
        ('DOMAIN,alpha.test', RailMark.step),
        ('Proxy', RailMark.end),
      ],
    );
    Finder speeds() => find.descendant(
      of: find.byType(TrackerTrafficSummary),
      matching: find.textContaining('/s'),
    );
    expect(speeds(), findsNWidgets(2));

    await tester.tap(find.text('1.1.1.1:443').last);
    await tester.pump();
    expect(copied, ['1.1.1.1:443']);
    final created = find.ancestor(
      of: find.text('Creation time'),
      matching: find.byType(DetailRow),
    );
    await tester.ensureVisible(created);
    await tester.tap(created);
    await tester.pump();
    expect(copied, ['1.1.1.1:443']);

    live = [];
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(speeds(), findsNothing);

    await teardownView(tester);
  });

  testWidgets('a detail names what routed a connection no rule matched in '
      'its path', (tester) async {
    seedRequests([
      _tracker(
        id: 1,
        host: 'alpha.test',
        chains: ['DIRECT'],
      ).copyWith(rule: '', rulePayload: ''),
      _tracker(
        id: 2,
        host: 'beta.test',
        chains: ['Tokyo', 'GLOBAL'],
      ).copyWith(rule: '', rulePayload: ''),
    ]);

    await pumpRequests(tester);
    String ruleStep() => tester
        .widgetList<TrackerRailRow>(find.byType(TrackerRailRow))
        .firstWhere((step) => step.subtitle == 'Rule')
        .title;
    await tester.tap(targetOf('alpha.test'));
    await tester.pumpAndSettle();
    await openDetailTab(tester, 'Info');
    expect(ruleStep(), 'No rule');

    await tester.tap(targetOf('beta.test'));
    await tester.pumpAndSettle();
    await openDetailTab(tester, 'Info');
    expect(ruleStep(), 'Global mode');

    await teardownView(tester);
  });

  testWidgets('connections head the minute they opened in, newest first, '
      'under headers', (tester) async {
    seedRequests([
      _tracker(
        id: 1,
        host: 'alpha.test',
      ).copyWith(start: DateTime(2026, 1, 1, 10, 5)),
      _tracker(
        id: 2,
        host: 'beta.test',
      ).copyWith(start: DateTime(2026, 1, 1, 10, 7)),
      _tracker(
        id: 3,
        host: 'gamma.test',
      ).copyWith(start: DateTime(2026, 1, 1, 10, 7, 30)),
    ]);

    await pumpRequests(tester, size: _listSize);

    final headers = topDown<RecordMinuteHeader>(tester);
    expect(
      [for (final header in headers) (header.label, header.count)],
      [('01-01 10:07', 2), ('01-01 10:05', 1)],
    );
    double topOf(String host) => tester.getTopLeft(find.text(host)).dy;
    expect(topOf('gamma.test'), lessThan(topOf('beta.test')));
    expect(topOf('beta.test'), lessThan(topOf('alpha.test')));

    await teardownView(tester);
  });

  testWidgets('a failed connection that reports late joins the minute it '
      'opened in, under one header', (tester) async {
    TrackerInfo at(int id, String name, int minute, int second) => _tracker(
      id: id,
      host: '$name.test',
    ).copyWith(start: DateTime(2026, 1, 1, 12, minute, second));
    seedRequests([at(2, 'b', 2, 0)]);
    addRequest(
      at(1, 'a', 1, 59).copyWith(
        failure: const ConnectionFailure(kind: ConnectionFailureKind.timeout),
      ),
    );
    addRequest(at(3, 'c', 2, 1));
    container.read(requestsProvider.notifier).close([1]);

    await pumpRequests(tester, size: _listSize);

    expect(
      [
        for (final header in topDown<RecordMinuteHeader>(tester))
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
      id: 1,
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

  for (final (layout, size) in [('pane', _tableSize), ('sheet', _listSize)]) {
    testWidgets('a $layout\'s head counts an open connection\'s age without '
        'new traffic', (tester) async {
      final open = _tracker(
        id: 1,
        host: 'alpha.test',
      ).copyWith(start: DateTime.now().subtract(const Duration(seconds: 10)));
      seedRequests([open]);

      final unanswered = Completer<List<TrackerInfo>>();
      await pumpRequests(
        tester,
        size: size,
        connectionsReader: () => unanswered.future,
      );
      await tester.tap(targetOf('alpha.test'));
      await tester.pumpAndSettle();
      final head = find.descendant(
        of: find.byType(TrackerInfoHeader),
        matching: find.descendant(
          of: find.byType(TrackerLifetime),
          matching: find.byType(RichText),
        ),
      );
      String age() => tester.widget<RichText>(head).text.toPlainText();
      final before = age();

      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 1100)),
      );
      await tester.pump(const Duration(seconds: 1));

      expect(age(), isNot(before));

      await teardownView(tester);
    });
  }

  testWidgets('at the top, new connections go straight in above the rows '
      'while one is selected, and on a phone while a pointer is over the '
      'list', (tester) async {
    seedRequests([_tracker(id: 1, host: 'alpha.test')]);
    await pumpRequests(tester);
    Future<void> refresh() async {
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      await tester.pump();
    }

    double topOf(String host) => tester.getTopLeft(targetOf(host)).dy;

    await tester.tap(targetOf('alpha.test'));
    await tester.pumpAndSettle();
    addRequest(_tracker(id: 2, host: 'beta.test'));
    await refresh();
    expect(topOf('beta.test'), lessThan(topOf('alpha.test')));
    expect(selectedRows(tester), [1]);

    await tester.tap(targetOf('alpha.test'));
    await tester.pumpAndSettle();
    expect(selectedRows(tester), isEmpty);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: tester.getCenter(targetOf('alpha.test')));
    addRequest(_tracker(id: 3, host: 'gamma.test'));
    await refresh();
    expect(topOf('gamma.test'), lessThan(topOf('beta.test')));

    await teardownView(tester);
  });

  testWidgets(
    'on desktop a list at the top keeps new connections out while the '
    'pointer rests on it, and takes them in as it leaves',
    variant: TargetPlatformVariant.only(TargetPlatform.macOS),
    (tester) async {
      seedRequests([_tracker(id: 1, host: 'alpha.test')]);
      await pumpRequests(tester);
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(
        location: tester.getCenter(targetOf('alpha.test')),
      );
      await tester.pump();

      addRequest(_tracker(id: 2, host: 'beta.test'));
      container.read(requestsProvider.notifier).close([1]);
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      expect(targetOf('beta.test'), findsNothing);
      expect(
        tester.widget<TrackerInfoItem>(rowOf(1)).trackerInfo.isActive,
        isFalse,
      );

      await mouse.moveTo(tester.getCenter(find.text('Connections').first));
      await tester.pump();
      expect(targetOf('beta.test'), findsOneWidget);

      await teardownView(tester);
    },
  );

  testWidgets('the connection counters are held only while the connections '
      'show', (tester) async {
    seedRequests([_tracker(id: 1, host: 'alpha.test')]);
    final demand = container.read(connectionBookProvider).demand;

    await pumpRequests(tester, size: _listSize);
    expect(demand.wanted, isTrue);

    await tester.tap(find.text('DNS').first);
    await tester.pump();
    expect(demand.wanted, isFalse);

    await tester.tap(find.text('Connections').first);
    await tester.pump();
    expect(demand.wanted, isTrue);

    await teardownView(tester);
    expect(demand.wanted, isFalse);
  });

  testWidgets('a list hidden behind another segment builds nothing as '
      'connections open, move and close, and shown again takes the rows '
      'that changed a few a frame', (tester) async {
    var live = [
      for (var i = 0; i < 6; i++) _tracker(id: 100 + i, host: 'a$i.test'),
    ];
    seedRequests(live);
    await pumpRequests(
      tester,
      size: _listSize,
      connectionsReader: () async => live,
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('DNS').first);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    final hiddenBuilds = countHiddenSegmentBuilds();
    live = [
      for (final trackerInfo in live.skip(3))
        trackerInfo.copyWith(download: trackerInfo.download + 2048),
      _tracker(id: 2, host: 'b.test'),
    ];
    addRequest(live.last);
    for (var second = 0; second < 3; second++) {
      await tester.pump(const Duration(seconds: 1));
    }
    expect(hiddenBuilds(), 0);

    final builtByFrame = <List<int>>[];
    debugOnRebuildDirtyWidget = (element, _) {
      if (element.widget case TrackerInfoItem(:final trackerInfo)) {
        builtByFrame.last.add(trackerInfo.id);
      }
    };
    addTearDown(() => debugOnRebuildDirtyWidget = null);
    await tester.tap(find.text('Connections').first);
    for (var frame = 0; frame < 8; frame++) {
      builtByFrame.add([]);
      await tester.pump();
    }
    debugOnRebuildDirtyWidget = null;

    const closed = {100, 101, 102};
    expect(builtByFrame.first, contains(2));
    expect(builtByFrame.first.where(closed.contains), isEmpty);
    expect(
      builtByFrame.expand((ids) => ids).where(closed.contains),
      unorderedEquals(closed),
    );
    for (final id in closed) {
      expect(
        tester.widget<TrackerInfoItem>(rowOf(id)).trackerInfo.isActive,
        isFalse,
      );
    }

    await teardownView(tester);
  });

  for (final (layout, size) in [
    ('phone list', _listSize),
    ('desktop list', _tableSize),
  ]) {
    testWidgets('scrolled off the top, a $layout keeps the rows in view where '
        'they are as connections open, and shows those at its top', (
      tester,
    ) async {
      seedRequests([
        for (var i = 0; i < 60; i++) _tracker(id: i, host: 'host$i.test'),
      ]);

      await pumpRequests(tester, size: size);
      await tester.pumpAndSettle();
      final rows = find.byType(TrackerInfoItem);
      final list = find
          .ancestor(of: rows.first, matching: find.byType(Scrollable))
          .first;
      List<(int, double)> inView() {
        final bounds = tester.getRect(list);
        return [
          for (final element in rows.evaluate())
            if (tester.getRect(find.byWidget(element.widget)) case final rect
                when rect.bottom > bounds.top && rect.top < bounds.bottom)
              ((element.widget as TrackerInfoItem).trackerInfo.id, rect.top),
        ]..sort((a, b) => a.$2.compareTo(b.$2));
      }

      await tester.drag(list, const Offset(0, -300));
      await tester.pumpAndSettle();
      final before = inView();
      expect(before.map((row) => row.$1), isNot(contains(59)));

      for (var i = 0; i < 3; i++) {
        addRequest(_tracker(id: 900 + i, host: 'new$i.test'));
      }
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(inView(), before);
      expect(find.byType(FilledButton), findsNothing);

      await tester.drag(list, const Offset(0, 3000));
      await tester.pumpAndSettle();

      expect(inView().first.$1, 902);

      await teardownView(tester);
    });
  }

  testWidgets('a refresh that moves the status counts leaves the condition '
      'block as it was', (tester) async {
    final open = [
      _tracker(id: 1, host: 'alpha.test'),
      _tracker(id: 2, host: 'beta.test'),
    ];
    seedRequests(open);
    await pumpRequests(
      tester,
      size: _listSize,
      connectionsReader: () async => [...open],
    );
    await tester.tap(addCondition);
    await tester.pumpAndSettle();
    await tester.enterText(dialogField, 'alpha');
    await tester.pump();
    await tester.tap(find.widgetWithText(TextButton, 'Add'));
    await tester.pumpAndSettle();
    expect(find.byType(ConditionBlock<TrackerInfo>), findsOneWidget);

    var blocks = 0;
    var segments = 0;
    debugOnRebuildDirtyWidget = (element, _) {
      if (element.widget is ConditionBlock<TrackerInfo>) {
        blocks++;
      } else if (element.widget is SegmentedControl<ConnectionStatus>) {
        segments++;
      }
    };
    addTearDown(() => debugOnRebuildDirtyWidget = null);
    open.add(_tracker(id: 3, host: 'gamma.test'));
    addRequest(open.last);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    debugOnRebuildDirtyWidget = null;

    expect(segments, greaterThan(0));
    expect(blocks, 0);

    await teardownView(tester);
  });

  testWidgets('the block keeps a row to each field, whose conditions and '
      'picked values widen it while the rows narrow, and edits each in place', (
    tester,
  ) async {
    seedRequests([
      _tracker(id: 1, host: 'alpha.test'),
      _tracker(id: 2, host: 'beta.test', process: 'chrome'),
      _tracker(id: 3, host: 'gamma.test', process: 'slack'),
    ]);

    await pumpRequests(tester, size: _listSize);
    expect(find.byType(ConditionBlock<TrackerInfo>), findsNothing);
    await openMenu(tester, 'beta.test');
    await tester.tap(find.text('Only this app'));
    await tester.pumpAndSettle();
    expect(targetOf('alpha.test'), findsNothing);

    await tester.tap(addCondition);
    await tester.pumpAndSettle();
    await tester.tap(inDialog(find.text('App')));
    await tester.pumpAndSettle();
    expect(find.text('Connections shown: 1'), findsOneWidget);
    await tester.enterText(dialogField, 'curl');
    await tester.pump();
    expect(find.text('Connections shown: 2'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Add'));
    await tester.pumpAndSettle();
    expect(targetOf('alpha.test'), findsWidgets);
    expect(targetOf('beta.test'), findsWidgets);
    expect(targetOf('gamma.test'), findsNothing);
    expect(inBlock(find.text('Equals chrome')), findsOneWidget);
    expect(inBlock(find.text('Contains curl')), findsOneWidget);
    expect(inBlock(find.text('or')), findsOneWidget);

    await tester.tap(addCondition);
    await tester.pumpAndSettle();
    await tester.enterText(dialogField, 'beta');
    await tester.pump();
    await tester.tap(find.widgetWithText(TextButton, 'Add'));
    await tester.pumpAndSettle();
    expect(targetOf('alpha.test'), findsNothing);
    expect(targetOf('beta.test'), findsWidgets);
    expect(inBlock(find.text('Host')), findsOneWidget);

    await tester.tap(inBlock(find.text('Contains beta')));
    await tester.pumpAndSettle();
    expect(find.text('Edit condition'), findsOneWidget);
    expect(tester.widget<EditableText>(dialogField).controller.text, 'beta');
    await tester.enterText(dialogField, 'alpha');
    await tester.pump();
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pumpAndSettle();
    expect(inBlock(find.text('Contains beta')), findsNothing);
    expect(inBlock(find.text('Contains alpha')), findsOneWidget);
    expect(targetOf('alpha.test'), findsWidgets);
    expect(targetOf('beta.test'), findsNothing);

    await tester.tap(removeOf('Contains alpha'));
    await tester.pumpAndSettle();
    expect(inBlock(find.text('Host')), findsNothing);
    expect(targetOf('beta.test'), findsWidgets);

    await tester.tap(inBlock(find.text('Clear all')));
    await tester.pumpAndSettle();
    expect(find.byType(ConditionBlock<TrackerInfo>), findsNothing);
    expect(targetOf('gamma.test'), findsWidgets);

    await teardownView(tester);
  });

  testWidgets('the failed view shows repeated failed dials to one target as '
      'its newest, with how many', (tester) async {
    seedRequests([
      for (var i = 0; i < 3; i++)
        _failed(id: 20 + i, host: 'udp.test', second: i),
      _failed(id: 15, host: 'other.test', second: 3),
      _tracker(id: 1, host: 'alpha.test'),
    ]);

    await pumpRequests(tester, size: _listSize);
    await tester.tap(statusSegment('Failed 4'));
    await tester.pumpAndSettle();

    final rows = topDown<TrackerInfoItem>(tester);
    expect(rows.map((row) => row.trackerInfo.id), [15, 22]);
    expect(find.widgetWithText(TonalChip, '×3'), findsOneWidget);
    expect(find.text('curl · Timeout'), findsNWidgets(2));

    await tester.tap(statusSegment('All 5'));
    await tester.pumpAndSettle();
    expect(find.byType(TrackerInfoItem), findsNWidgets(5));
    expect(find.widgetWithText(TonalChip, '×3'), findsNothing);

    await teardownView(tester);
  });

  testWidgets('settings that kept a grouping still load, and leave every '
      'width listed by minute', (tester) async {
    seedRequests([
      _tracker(id: 1, host: 'alpha.test'),
      _tracker(id: 2, host: 'beta.test', process: 'chrome'),
    ]);
    final kept = AppSettingProps.fromJson(
      jsonDecode('{"hideIp": true, "recordGroupings": {"requests": "app"}}')
          as Map<String, Object?>,
    );
    expect(kept.hideIp, isTrue);
    container.listen(appSettingProvider, (_, _) {});
    container.read(appSettingProvider.notifier).update((_) => kept);

    await pumpRequests(tester, size: _listSize);
    await tester.pumpAndSettle();
    final headers = tester.widgetList<RecordMinuteHeader>(
      find.byType(RecordMinuteHeader),
    );
    expect(headers, hasLength(1));
    expect(headers.single.label, contains(':'));
    expect(targetOf('alpha.test'), findsWidgets);
    expect(targetOf('beta.test'), findsWidgets);

    await teardownView(tester);
    await pumpRequests(tester);
    await tester.pumpAndSettle();
    expect(find.byType(RecordMinuteHeader), findsOneWidget);
    expect(find.byType(TrackerInfoItem), findsNWidgets(2));

    await teardownView(tester);
  });

  for (final (layout, size, inset) in [
    ('a desktop list', _sheetSize, 20.0),
    ('a phone list', const Size(390, 844), 16.0),
  ]) {
    testWidgets('in $layout the add button, the app bar\'s buttons and the '
        'rows end on one line', (tester) async {
      seedRequests([_tracker(id: 1, host: 'alpha.test')]);

      await pumpRequests(tester, size: size);
      double rightGap(Finder finder) =>
          size.width - tester.getRect(finder.first).right;
      final barEnd = find.ancestor(of: more, matching: find.byType(IconButton));
      final add = find.ancestor(
        of: addCondition,
        matching: find.byType(IconButton),
      );
      final row = find.descendant(
        of: find.byType(TrackerInfoItem),
        matching: find.byType(Card),
      );

      expect(rightGap(barEnd), inset);
      expect(rightGap(add), inset);
      expect(rightGap(row), inset);

      await teardownView(tester);
    });
  }

  testWidgets('the menu closes the active connections only once that is '
      'confirmed, and offers no grouping', (tester) async {
    final core = coreMocks();
    when(() => core.api.closeConnections()).thenAnswer((_) async {});
    container.dispose();
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(TestProfiles.new),
        coreHandlerProvider.overrideWithValue(core.controller),
      ],
    );
    globalState.container = container;
    final alpha = _tracker(id: 1, host: 'alpha.test');
    final beta = _tracker(id: 2, host: 'beta.test');
    seedRequests([alpha, beta]);

    await pumpRequests(tester, connectionsReader: () async => [alpha, beta]);
    await tester.tap(more);
    await tester.pumpAndSettle();
    expect(
      [
        for (final item in tester.widgetList<PopupMenu>(find.byType(PopupMenu)))
          for (final entry in item.items) (entry.label, entry.danger),
      ],
      [('Close all active connections', true)],
    );

    await tester.tap(inMenu(find.text('Close all active connections')));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('2 active connections will close.'),
      findsOneWidget,
    );
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    verifyNever(() => core.api.closeConnections());

    await openSubMenu(tester, 'Close all active connections');
    await tester.tap(find.widgetWithText(TextButton, 'Close'));
    await tester.pumpAndSettle();
    verify(() => core.api.closeConnections()).called(1);

    await teardownView(tester);
  });

  testWidgets('the menu greys out closing with no connection open, and the '
      'DNS queries clear the cache from theirs', (tester) async {
    seedRequests([_tracker(id: 1, host: 'alpha.test')]);
    container.read(requestsProvider.notifier).close([1]);

    await pumpRequests(tester);
    await tester.tap(more);
    await tester.pumpAndSettle();
    final close = tester
        .widgetList<PopupMenu>(find.byType(PopupMenu))
        .expand((menu) => menu.items)
        .single;
    expect(close.label, 'Close all active connections');
    expect(close.onPressed, isNull);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    await tester.tap(find.text('DNS'));
    await tester.pumpAndSettle();
    await tester.tap(more);
    await tester.pumpAndSettle();
    expect(
      [
        for (final item in tester.widgetList<PopupMenu>(find.byType(PopupMenu)))
          for (final entry in item.items) entry.label,
      ],
      ['Clear DNS cache'],
    );

    await teardownView(tester);
  });

  testWidgets('a search reads field conditions, and a condition added from '
      'the strip narrows the list until its chip is deleted', (tester) async {
    seedRequests([
      _tracker(id: 1, host: 'alpha.test'),
      _tracker(id: 2, host: 'beta.test', process: 'chrome'),
      _tracker(id: 3, host: 'gamma.test', process: 'chrome'),
    ]);

    await pumpRequests(tester, size: _listSize);
    await tester.tap(find.byTooltip('Search'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'app:chrome -host:gamma');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(targetOf('alpha.test'), findsNothing);
    expect(targetOf('beta.test'), findsWidgets);
    expect(targetOf('gamma.test'), findsNothing);
    await tester.enterText(find.byType(TextField), '');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(targetOf('alpha.test'), findsWidgets);

    await tester.tap(addCondition);
    await tester.pumpAndSettle();
    expect(find.text('Add condition'), findsOneWidget);
    await tester.enterText(dialogField, 'alpha');
    await tester.tap(inDialog(find.text('Excludes')));
    await tester.pumpAndSettle();
    expect(find.text('Connections shown: 2'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Add'));
    await tester.pumpAndSettle();

    expect(find.text('Add condition'), findsNothing);
    expect(targetOf('alpha.test'), findsNothing);
    expect(targetOf('beta.test'), findsWidgets);
    expect(inBlock(find.text('Excludes alpha')), findsOneWidget);
    await tester.tap(removeOf('Excludes alpha'));
    await tester.pumpAndSettle();
    expect(find.byType(ConditionBlock<TrackerInfo>), findsNothing);
    expect(targetOf('alpha.test'), findsWidgets);

    await teardownView(tester);
  });

  testWidgets('the add button asks in a dialog, whose values from the list '
      'fill the field and whose count follows the draft', (tester) async {
    seedRequests([
      _tracker(id: 1, host: 'alpha.test', process: 'Google Chrome'),
      _tracker(id: 2, host: 'beta.test', process: 'chrome'),
      _tracker(id: 3, host: 'gamma.test', process: 'chrome'),
    ]);

    await pumpRequests(tester, size: _listSize);
    await tester.tap(addCondition);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    final addButton = find.widgetWithText(TextButton, 'Add');
    expect(tester.widget<TextButton>(addButton).onPressed, isNull);
    expect(find.text('Connections shown: 3'), findsOneWidget);
    expect(inDialog(find.text('Host in the list')), findsOneWidget);

    await tester.tap(inDialog(find.text('App')));
    await tester.pumpAndSettle();
    expect(inDialog(find.text('App in the list')), findsOneWidget);
    expect(inDialog(find.text('Google Chrome')), findsOneWidget);
    await tester.tap(inDialog(find.text('chrome')));
    await tester.pump();
    expect(tester.widget<EditableText>(dialogField).controller.text, 'chrome');
    expect(find.text('Connections shown: 3'), findsOneWidget);
    await tester.tap(inDialog(find.text('Equals')));
    await tester.pumpAndSettle();
    expect(find.text('Connections shown: 2'), findsOneWidget);
    await tester.tap(inDialog(find.text('Not equal')));
    await tester.pumpAndSettle();
    expect(find.text('Connections shown: 1'), findsOneWidget);
    await tester.tap(inDialog(find.text('Equals')));
    await tester.pumpAndSettle();
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(targetOf('alpha.test'), findsNothing);
    expect(targetOf('beta.test'), findsWidgets);
    expect(inBlock(find.text('Equals chrome')), findsOneWidget);

    await teardownView(tester);
  });

  testWidgets('typed on without a pause, the count catches up with the last '
      'value, and a new field counts afresh', (tester) async {
    seedRequests([
      _tracker(id: 1, host: 'alpha.test', process: 'Google Chrome'),
      _tracker(id: 2, host: 'beta.test', process: 'chrome'),
      _tracker(id: 3, host: 'gamma.test', process: 'chrome'),
      _tracker(id: 4, host: 'chrome.test'),
    ]);

    await pumpRequests(tester, size: _listSize);
    await tester.tap(addCondition);
    await tester.pumpAndSettle();
    for (final typed in ['c', 'ch', 'chr', 'chro', 'chrom', 'chrome']) {
      tester.testTextInput.updateEditingValue(
        TextEditingValue(
          text: typed,
          selection: TextSelection.collapsed(offset: typed.length),
        ),
      );
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.pumpAndSettle();
    expect(find.text('Connections shown: 1'), findsOneWidget);
    expect(inDialog(find.text('chrome.test')), findsOneWidget);

    await tester.tap(inDialog(find.text('App')));
    await tester.pumpAndSettle();
    expect(find.text('Connections shown: 3'), findsOneWidget);
    expect(inDialog(find.text('Google Chrome')), findsOneWidget);

    await teardownView(tester);
  });

  testWidgets('a condition from the dialog keeps the spaces in its value', (
    tester,
  ) async {
    seedRequests([
      _tracker(id: 1, host: 'alpha.test', process: 'Google Chrome'),
      _tracker(id: 2, host: 'beta.test', process: 'chrome'),
    ]);

    await pumpRequests(tester, size: _listSize);
    await tester.tap(addCondition);
    await tester.pumpAndSettle();
    await tester.tap(inDialog(find.text('App')));
    await tester.pumpAndSettle();
    await tester.enterText(dialogField, 'Google Chrome');
    await tester.pump();
    await tester.tap(find.widgetWithText(TextButton, 'Add'));
    await tester.pumpAndSettle();

    expect(targetOf('alpha.test'), findsWidgets);
    expect(targetOf('beta.test'), findsNothing);
    expect(inBlock(find.text('Contains Google Chrome')), findsOneWidget);

    await teardownView(tester);
  });

  testWidgets('the status segments count the connections and show one '
      'status at a time', (tester) async {
    final open = _tracker(id: 1, host: 'alpha.test');
    seedRequests([
      open,
      _failed(id: 2, host: 'beta.test', chains: const ['Tokyo']),
    ]);

    await pumpRequests(tester, connectionsReader: () async => [open]);
    await tester.pump(const Duration(milliseconds: 400));
    expect(statusSegment('All 2'), findsOneWidget);
    expect(statusSegment('Active 1'), findsOneWidget);
    expect(statusSegment('Failed 1'), findsOneWidget);
    expect(shownStatus(tester), ConnectionStatus.all);

    await tester.tap(statusSegment('Failed 1'));
    await tester.pumpAndSettle();
    expect(shownStatus(tester), ConnectionStatus.failed);
    expect(targetOf('alpha.test'), findsNothing);
    expect(find.text('curl · Timeout'), findsOneWidget);

    await tester.tap(statusSegment('Active 1'));
    await tester.pumpAndSettle();
    expect(shownStatus(tester), ConnectionStatus.active);
    expect(targetOf('alpha.test'), findsWidgets);
    expect(targetOf('beta.test'), findsNothing);

    await tester.tap(more);
    await tester.pumpAndSettle();
    expect(inMenu(find.text('Filter')), findsNothing);
    expect(inMenu(find.text('Group by')), findsNothing);

    await teardownView(tester);
  });

  group('a refresh builds only what changed', () {
    final full = [
      for (var index = 0; index < 499; index++) _tracker(id: index),
      _tracker(id: 499, host: 'latest.test'),
    ];

    var trafficBuilt = 0;
    Future<int> rowsBuiltBy(
      WidgetTester tester,
      void Function() change, {
      int frames = 1,
    }) async {
      var built = 0;
      trafficBuilt = 0;
      debugOnRebuildDirtyWidget = (element, _) {
        final widget = element.widget;
        if (widget is TrackerInfoItem) {
          built++;
        } else if (widget is TrackerTraffic) {
          trafficBuilt++;
        }
      };
      addTearDown(() => debugOnRebuildDirtyWidget = null);
      change();
      await tester.pump(const Duration(milliseconds: 400));
      for (var frame = 0; frame < frames; frame++) {
        await tester.pump();
      }
      debugOnRebuildDirtyWidget = null;
      return built;
    }

    for (final (name, size) in const [
      ('phone list', _listSize),
      ('desktop list', _tableSize),
    ]) {
      testWidgets('a full $name builds only the request added', (tester) async {
        seedRequests(full);
        await pumpRequests(tester, size: size);
        await tester.pump(const Duration(seconds: 1));
        // The list widens past the viewport once the empty pane stops moving.
        await tester.pump();

        final built = await rowsBuiltBy(
          tester,
          () => addRequest(_tracker(id: 900)),
        );

        expect(built, 1);
        await teardownView(tester);
      });
    }

    testWidgets('traffic rebuilds only the figures of the row it reaches, '
        'and its detail opens on the latest', (tester) async {
      seedRequests(full);
      await pumpRequests(tester, size: _listSize);
      await tester.pump(const Duration(seconds: 1));

      final built = await rowsBuiltBy(
        tester,
        () => container.read(requestsProvider.notifier).updateTraffic({
          499: (upload: 0, download: 2048),
        }),
        frames: 8,
      );
      expect(built, 0);
      expect(trafficBuilt, 1);

      await tester.tap(find.text('latest.test'));
      await tester.pumpAndSettle();
      await openDetailTab(tester, 'Info');
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
}

Finder _figure(String text) => find.byWidgetPredicate(
  (widget) =>
      widget is PlainTextLines && widget.lines.any((line) => line.text == text),
);

Finder _figureContaining(String text) => find.byWidgetPredicate(
  (widget) =>
      widget is PlainTextLines &&
      widget.lines.any((line) => line.text.contains(text)),
);
