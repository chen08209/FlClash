import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/features/features.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/chip.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/ui/null_status.dart';
import 'package:fl_clash/ui/scroll.dart';
import 'package:fl_clash/views/connection/requests.dart';
import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/scrollbar.dart';
import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

const _tableSize = Size(1400, 1000);
const _listSize = Size(600, 1000);

TrackerInfo _tracker({
  required String id,
  String host = 'example.com',
  List<String> chains = const ['Proxy'],
  int download = 0,
}) {
  return TrackerInfo(
    id: id,
    download: download,
    start: DateTime.utc(2026),
    metadata: Metadata(
      network: 'tcp',
      host: host,
      destinationIP: '1.1.1.1',
      destinationPort: '443',
      process: 'curl',
    ),
    chains: chains,
    rule: 'DOMAIN',
    rulePayload: host,
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
    notifier.value = FixedList<TrackerInfo>(500);
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
  }) async {
    container.read(viewSizeProvider.notifier).update((_) => size);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: RequestsView()),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

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
    expect(find.text('251.8KB'), findsNothing);

    container.read(requestsProvider.notifier).updateTraffic({
      'a': (upload: 460, download: 257835),
    });
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    await tester.pump();

    expect(find.text('251.8KB'), findsOneWidget);

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

    final thumb = await revealScrollbarThumb(tester);
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
    // which the list running under the bar leaves at the bar's foot.
    expect(
      tester.getCenter(find.byKey(hintKey)).dy,
      closeTo(tester.getRect(find.byType(AppBar)).bottom + 24, 6),
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

    await tapHeader('Download');
    expect(hostsTopDown(), ['alpha.test', 'beta.test', 'gamma.test']);
    expect(sortArrow(AppGlyphs.arrowDown), findsOneWidget);

    await tapHeader('Download');
    expect(hostsTopDown(), ['gamma.test', 'beta.test', 'alpha.test']);
    expect(sortArrow(AppGlyphs.arrowUp), findsOneWidget);

    await tapHeader('Download');
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
    double leftOf(String text) => tester.getTopLeft(find.text(text)).dx;
    final protocol = leftOf('Protocol');
    final rule = leftOf('Rule');
    final exit = leftOf('Exit');
    final tcp = leftOf('TCP');

    await tester.drag(
      handles.at(2),
      const Offset(100, 0),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump();

    final moved = leftOf('Protocol') - protocol;
    expect(moved, greaterThan(50));
    expect(leftOf('TCP'), closeTo(tcp + moved, 0.01));
    expect(
      leftOf('Rule'),
      closeTo(rule + moved - (rule - protocol - 48), 0.01),
    );
    expect(leftOf('Exit'), exit);
    expect(
      container.read(appSettingProvider).tableColumnWidths['requests']?.keys,
      unorderedEquals(['target', 'protocol', 'rule']),
    );

    await tester.tap(handles.at(2), kind: PointerDeviceKind.mouse);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(handles.at(2), kind: PointerDeviceKind.mouse);
    await tester.pumpAndSettle();

    expect(leftOf('Protocol'), protocol);
    expect(container.read(appSettingProvider).tableColumnWidths, isEmpty);

    await teardownView(tester);
  });

  testWidgets('the table opens at the widths kept from before', (tester) async {
    container.listen(appSettingProvider, (_, _) {});
    seedRequests([_tracker(id: 'a', host: 'alpha.test')]);

    await pumpRequests(tester);
    final target = tester.getTopLeft(find.text('Target')).dx;
    await teardownView(tester);

    container
        .read(appSettingProvider.notifier)
        .update(
          (state) => state.copyWith(
            tableColumnWidths: {
              'requests': {'target': 400},
            },
          ),
        );
    await pumpRequests(tester);

    expect(
      tester.getTopLeft(find.text('Protocol')).dx,
      closeTo(target + 400, 0.01),
    );

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
      'Process',
      'Target',
      'Protocol',
      'Rule',
      'Exit',
      'Download',
      'Upload',
    ]) {
      expect(find.text(label), findsOneWidget);
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
    expect(find.text('TCP'), findsNWidgets(2));
    final rowHeights = tester
        .widgetList(find.byType(TrackerInfoTableRow))
        .map((row) => tester.getSize(find.byWidget(row)).height)
        .toSet();
    expect(rowHeights, hasLength(1));
    expect(
      tester.getTopLeft(find.textContaining('beta.test').first).dy,
      greaterThan(tester.getBottomLeft(find.text('Target')).dy),
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

  testWidgets('tapping a table row opens its details', (tester) async {
    seedRequests([_tracker(id: 'a', host: 'alpha.test')]);

    await pumpRequests(tester);

    await tester.tap(find.text('curl'));
    await tester.pumpAndSettle();

    expect(find.text('Request details'), findsOneWidget);
    expect(find.byType(TrackerInfoDetailView), findsOneWidget);

    await teardownView(tester);
  });

  testWidgets('the table scrollbar leaves no room for the bar above it', (
    tester,
  ) async {
    seedRequests([for (var i = 0; i < 200; i++) _tracker(id: '$i')]);

    await pumpRequests(tester);

    await revealScrollbarThumb(tester);
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
    expect(find.byType(FloatingActionButton), findsNothing);
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
}
