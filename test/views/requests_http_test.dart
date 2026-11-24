import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/features.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/mitm.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/views/connection/requests.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/record_lines.dart';
import '../helpers/status_menu.dart';
import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

class _MockCoreHandlerInterface extends Mock implements CoreHandlerInterface {}

const _paneSize = Size(1400, 1000);
const _phoneSize = Size(400, 860);

final _start = DateTime.utc(2026, 11, 22, 6, 0);

MitmExchangeSummary _summary(
  int id, {
  String method = 'GET',
  String path = '/',
  int status = 200,
  String statusClass = '2xx',
  bool pending = false,
  bool rewritten = false,
  List<String> actionKinds = const [],
  String process = 'curl',
}) => MitmExchangeSummary(
  id: id,
  start: _start.add(Duration(seconds: id)),
  method: method,
  url: 'https://api.test$path',
  host: 'api.test',
  path: path,
  status: status,
  statusClass: statusClass,
  pending: pending,
  rewritten: rewritten,
  actionKinds: actionKinds,
  responseSize: 2048,
  duration: 35,
  connectionId: 'c1',
  app: MitmApp(process: process),
);

final _exchanges = [
  _summary(1, path: '/ok'),
  _summary(2, path: '/missing', status: 404, statusClass: '4xx'),
  _summary(
    3,
    method: 'POST',
    path: '/rewritten',
    rewritten: true,
    actionKinds: const ['header-rewrite', 'script'],
    process: 'Slack',
  ),
  _summary(4, path: '/broken', status: 0, statusClass: 'failed'),
];

Future<MitmQueryPage> _query({
  int? before,
  int? since,
  required int limit,
}) async => MitmQueryPage(
  capturing: true,
  version: 1,
  exchanges: _exchanges.reversed.toList(),
);

TrackerInfo _connection() => TrackerInfo(
  id: 'c1',
  start: _start,
  metadata: const Metadata(
    network: 'tcp',
    host: 'api.test',
    destinationIP: '1.1.1.1',
    destinationPort: '443',
    process: 'curl',
    mitm: true,
  ),
  chains: const ['Proxy'],
  rule: 'DOMAIN',
  rulePayload: 'api.test',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  void setUpContainer({List<Override> overrides = const []}) {
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(TestProfiles.new),
        coreHandlerProvider.overrideWithValue(
          CoreController.scoped(_MockCoreHandlerInterface()),
        ),
        ...overrides,
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.listen(patchClashConfigProvider, (_, _) {});
  }

  void capture({bool on = true}) => container
      .read(patchClashConfigProvider.notifier)
      .update(
        (state) => state.copyWith(
          mitm: state.mitm.copyWith(enable: true, capture: on),
        ),
      );

  Future<void> pumpHttp(
    WidgetTester tester, {
    Size size = _paneSize,
    MitmQuery query = _query,
    bool open = true,
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
          child: RequestsView(
            connectionsReader: () async => const [],
            httpQuery: query,
          ),
        ),
      ),
    );
    await tester.pump();
    if (rsFeature && open) {
      await tester.tap(find.text('HTTP'));
    }
    await tester.pumpAndSettle();
  }

  Future<void> openMenu(WidgetTester tester) async {
    await tester.tap(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.byGlyph(AppGlyphs.more),
      ),
    );
    await tester.pumpAndSettle();
  }

  void decrypt({required bool on}) => container
      .read(patchClashConfigProvider.notifier)
      .update((state) => state.copyWith(mitm: state.mitm.copyWith(enable: on)));

  Finder noConnections() => find.text(
    currentAppLocalizations.nullTip(currentAppLocalizations.connections),
  );

  Future<void> teardownView(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  }

  testWidgets('the HTTP segment stands between connections and DNS only '
      'while capture records', (tester) async {
    setUpContainer();
    await pumpHttp(tester, open: false);

    expect(find.text('HTTP'), findsNothing);

    capture(on: false);
    await tester.pumpAndSettle();
    expect(find.text('HTTP'), findsNothing);

    capture();
    await tester.pumpAndSettle();
    expect(
      find.text('HTTP'),
      [if (rsFeature) findsOneWidget].firstOrNull ?? findsNothing,
    );

    await teardownView(tester);
  });

  if (rsFeature) {
    testWidgets('a Core that goes takes its requests with it, even where the '
        'next counts up to where the list had read', (tester) async {
      setUpContainer(
        overrides: [
          coreStatusProvider.overrideWithBuild((_, _) => CoreStatus.connected),
        ],
      );
      capture();
      var page = MitmQueryPage(
        capturing: true,
        version: 4,
        exchanges: _exchanges.reversed.toList(),
      );
      final asked = <int?>[];
      container.read(viewSizeProvider.notifier).update((_) => _paneSize);
      tester.view.physicalSize = _paneSize;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TestApp(
            child: RequestsView(
              segment: RequestsSegment.http,
              connectionsReader: () async => const [],
              httpQuery: ({before, since, required limit}) async {
                asked.add(since);
                return page;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('/rewritten'), findsOneWidget);

      container.read(coreStatusProvider.notifier).value = CoreStatus.connecting;
      await tester.pump();
      page = MitmQueryPage(
        capturing: true,
        version: 6,
        exchanges: [_summary(1, path: '/other')],
      );
      container.read(coreStatusProvider.notifier).value = CoreStatus.connected;
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(asked.last, isNull);
      expect(find.text('/other'), findsOneWidget);
      expect(find.text('/rewritten'), findsNothing);

      await teardownView(tester);
    });

    testWidgets(
      'a list that goes with capture while the pointer is on it holds no '
      'request back once capture is on again',
      (tester) async {
        setUpContainer();
        capture();
        var page = MitmQueryPage(
          capturing: true,
          version: 1,
          exchanges: _exchanges.reversed.toList(),
        );
        container.read(viewSizeProvider.notifier).update((_) => _paneSize);
        tester.view.physicalSize = _paneSize;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: TestApp(
              child: RequestsView(
                segment: RequestsSegment.http,
                connectionsReader: () async => const [],
                httpQuery: ({before, since, required limit}) async => page,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
        addTearDown(mouse.removePointer);
        await mouse.addPointer(location: tester.getCenter(find.text('/ok')));
        await tester.pump();

        capture(on: false);
        await tester.pumpAndSettle();
        await mouse.moveTo(Offset.zero);
        await tester.pump();
        page = MitmQueryPage(
          capturing: true,
          version: 2,
          exchanges: [
            _summary(5, path: '/new'),
            ..._exchanges.reversed,
          ],
        );
        capture();
        await tester.pumpAndSettle();
        await tester.tap(find.text('HTTP'));
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        expect(find.text('/new'), findsOneWidget);

        await teardownView(tester);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.macOS),
    );

    testWidgets('on a narrow desktop a request opens in a side sheet whose '
        'tabs fit it', (tester) async {
      setUpContainer(
        overrides: [
          mitmExchangeProvider(1).overrideWith(
            (ref) async => MitmExchange(
              id: 1,
              start: _start,
              method: 'GET',
              url: 'https://api.test/ok',
              status: 200,
            ),
          ),
        ],
      );
      capture();
      const size = Size(800, 1000);
      container.read(viewSizeProvider.notifier).update((_) => size);
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TestApp(
            child: RequestsView(
              segment: RequestsSegment.http,
              connectionsReader: () async => const [],
              httpQuery: _query,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('/ok'));
      await tester.pumpAndSettle();

      final tabs = find.descendant(
        of: find.byType(DetailSheet),
        matching: find.byType(SegmentedControl<int>),
      );
      expect(tabs, findsOneWidget);
      expect(
        tester
            .getRect(
              find.ancestor(of: tabs, matching: find.byType(Scrollable)).first,
            )
            .right,
        lessThanOrEqualTo(tester.getRect(find.byType(DetailSheet)).right),
      );

      await teardownView(tester);
    });

    testWidgets('a request selected beside the list moves into a sheet as the '
        'page narrows and back as it widens', (tester) async {
      setUpContainer(
        overrides: [
          mitmExchangeProvider(1).overrideWith(
            (ref) async => MitmExchange(
              id: 1,
              start: _start,
              method: 'GET',
              url: 'https://api.test/ok',
              status: 200,
            ),
          ),
        ],
      );
      capture();
      Future<void> resize(Size size) async {
        container.read(viewSizeProvider.notifier).update((_) => size);
        tester.view.physicalSize = size;
        await tester.pumpAndSettle();
      }

      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      container.read(viewSizeProvider.notifier).update((_) => _paneSize);
      tester.view.physicalSize = _paneSize;
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TestApp(
            child: RequestsView(
              segment: RequestsSegment.http,
              connectionsReader: () async => const [],
              httpQuery: _query,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('/ok'));
      await tester.pumpAndSettle();
      expect(find.byType(MitmExchangeView), findsOneWidget);
      expect(find.byType(DetailSheet), findsNothing);

      await resize(const Size(800, 1000));
      expect(
        find.descendant(
          of: find.byType(DetailSheet),
          matching: find.text('https://api.test/ok'),
        ),
        findsWidgets,
      );

      await resize(_paneSize);
      expect(find.byType(DetailSheet), findsNothing);
      expect(find.byType(MitmExchangeView), findsOneWidget);

      await teardownView(tester);
    });

    testWidgets('turning capture off takes the request beside the list with '
        'it', (tester) async {
      setUpContainer(
        overrides: [
          mitmExchangeProvider(1).overrideWith(
            (ref) async => MitmExchange(
              id: 1,
              start: _start,
              method: 'GET',
              url: 'https://api.test/ok',
              status: 200,
            ),
          ),
        ],
      );
      capture();
      container.read(viewSizeProvider.notifier).update((_) => _paneSize);
      tester.view.physicalSize = _paneSize;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TestApp(
            child: RequestsView(
              segment: RequestsSegment.http,
              connectionsReader: () async => const [],
              httpQuery: _query,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('/ok'));
      await tester.pumpAndSettle();
      expect(find.byType(MitmExchangeView), findsOneWidget);

      capture(on: false);
      await tester.pumpAndSettle();

      expect(find.byType(MitmExchangeView), findsNothing);
      expect(noConnections(), findsOneWidget);

      await teardownView(tester);
    });

    testWidgets('every connection\'s requests are listed by path and host, '
        'with their status, size and time', (tester) async {
      setUpContainer();
      capture();
      await pumpHttp(tester);

      final row = find.widgetWithText(HttpRequestRow, '/missing');
      expect(row, findsOneWidget);
      expect(recordLinesIn(tester, row), ['api.test [35 ms]']);
      expect(
        find.descendant(of: row, matching: find.text('curl')),
        findsNothing,
      );
      final status = tester.widget<Text>(
        find.descendant(of: row, matching: find.text('404')),
      );
      expect(status.style?.color, tester.element(row).colorScheme.error);
      expect(
        find.descendant(of: row, matching: find.text(2048.traffic.show)),
        findsOneWidget,
      );
      expect(
        recordLinesIn(
          tester,
          find.widgetWithText(HttpRequestRow, '/rewritten'),
        ).single,
        endsWith('[${currentAppLocalizations.headerRewrite} +1]'),
      );
      expect(
        find.descendant(
          of: find.widgetWithText(HttpRequestRow, '/broken'),
          matching: find.text('Failed'),
        ),
        findsOneWidget,
      );

      await teardownView(tester);
    });

    testWidgets('Failed keeps the answers of 4xx and 5xx and the unanswered, '
        'Rewritten what a rule acted on', (tester) async {
      setUpContainer();
      capture();
      await pumpHttp(tester);

      expect(shownStatusText(tester), 'All 4');
      await pickStatus(tester, 'Failed 2');
      expect(find.byType(HttpRequestRow), findsNWidgets(2));
      expect(find.text('/ok'), findsNothing);

      await pickStatus(tester, 'Rewritten 1');
      expect(find.byType(HttpRequestRow), findsOneWidget);
      expect(find.text('/rewritten'), findsOneWidget);

      await teardownView(tester);
    });

    testWidgets('a status with no requests says so rather than that nothing '
        'matched', (tester) async {
      setUpContainer();
      capture();
      await pumpHttp(
        tester,
        query: ({before, since, required limit}) async => MitmQueryPage(
          capturing: true,
          version: 1,
          exchanges: [_exchanges.first],
        ),
      );

      await pickStatus(tester, 'Rewritten 0');
      expect(find.text('No rewritten HTTP requests'), findsOneWidget);
      expect(find.text('No matching results'), findsNothing);

      await teardownView(tester);
    });

    testWidgets('a condition is set on the request fields', (tester) async {
      setUpContainer();
      capture();
      await pumpHttp(tester);

      await tester.tap(
        find.descendant(
          of: find.byType(
            ConditionFilterRow<MitmExchangeSummary, HttpRequestStatus>,
          ),
          matching: find.byGlyph(AppGlyphs.add),
        ),
      );
      await tester.pumpAndSettle();
      final dialog = find.byType(AlertDialog);
      for (final field in ['Host', 'Path', 'Method', 'Status code', 'Type']) {
        expect(
          find.descendant(of: dialog, matching: find.text(field)),
          findsOneWidget,
        );
      }
      await tester.tap(
        find.descendant(of: dialog, matching: find.text('Method')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(of: dialog, matching: find.text('POST')),
      );
      await tester.pump();
      expect(find.text('Requests shown: 1'), findsOneWidget);

      await teardownView(tester);
    });

    testWidgets('beside the list a request opens in the pane with its '
        'connection, which opens among the connections', (tester) async {
      setUpContainer(
        overrides: [
          mitmExchangeProvider(1).overrideWith(
            (ref) async => MitmExchange(
              id: 1,
              start: _start,
              method: 'GET',
              url: 'https://api.test/ok',
              status: 200,
              connection: 'c1',
            ),
          ),
        ],
      );
      capture();
      container.read(requestsProvider.notifier).addRequest(_connection());
      await pumpHttp(tester);

      expect(find.text('Select a request'), findsOneWidget);
      await tester.tap(find.text('/ok'));
      await tester.pumpAndSettle();

      final view = find.byType(MitmExchangeView);
      expect(view, findsOneWidget);
      expect(find.byType(DetailSheet), findsNothing);
      expect(
        find.descendant(of: view, matching: find.text('Connection')),
        findsOneWidget,
      );
      await tester.tap(find.byType(RelatedConnectionRow));
      await tester.pumpAndSettle();

      expect(view, findsNothing);
      expect(find.byType(TrackerInfoDetailView), findsOneWidget);

      await teardownView(tester);
    });

    testWidgets('a request the Core no longer keeps takes its pane with it', (
      tester,
    ) async {
      setUpContainer();
      capture();
      var page = MitmQueryPage(
        capturing: true,
        version: 1,
        exchanges: _exchanges.reversed.toList(),
      );
      await pumpHttp(
        tester,
        query: ({before, since, required limit}) async => page,
      );
      await tester.tap(find.text('/ok'));
      await tester.pumpAndSettle();
      expect(find.byType(MitmExchangeView), findsOneWidget);

      page = const MitmQueryPage(capturing: true, version: 0);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.byType(MitmExchangeView), findsNothing);
      expect(find.text('Select a request'), findsOneWidget);

      await teardownView(tester);
    });

    testWidgets('a restarted Core takes the pane with it, even where its ids '
        'come round to the one open', (tester) async {
      setUpContainer();
      capture();
      var page = MitmQueryPage(
        capturing: true,
        version: 1,
        exchanges: _exchanges.reversed.toList(),
      );
      await pumpHttp(
        tester,
        query: ({before, since, required limit}) async => page,
      );
      await tester.tap(find.text('/ok'));
      await tester.pumpAndSettle();
      expect(find.byType(MitmExchangeView), findsOneWidget);

      page = MitmQueryPage(
        capturing: true,
        version: 0,
        exchanges: [_summary(1, path: '/other')],
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.text('/other'), findsOneWidget);
      expect(find.byType(MitmExchangeView), findsNothing);
      expect(find.text('Select a request'), findsOneWidget);

      await teardownView(tester);
    });

    testWidgets('on a phone a request opens in a sheet', (tester) async {
      setUpContainer(
        overrides: [
          mitmExchangeProvider(1).overrideWith(
            (ref) async => MitmExchange(
              id: 1,
              start: _start,
              method: 'GET',
              url: 'https://api.test/ok',
              status: 200,
            ),
          ),
        ],
      );
      capture();
      await pumpHttp(tester, size: _phoneSize);

      await tester.tap(find.text('/ok'));
      await tester.pumpAndSettle();

      expect(find.byType(DetailSheet), findsOneWidget);
      expect(find.byType(MitmExchangeView), findsOneWidget);

      await teardownView(tester);
    });

    testWidgets('the menu turns capture on, which brings the HTTP segment, '
        'and off, which leaves it for connections', (tester) async {
      setUpContainer();
      capture(on: false);
      await pumpHttp(tester, open: false);

      expect(find.text('HTTP'), findsNothing);

      await openMenu(tester);
      await tester.tap(find.text(currentAppLocalizations.turnOn));
      await tester.pumpAndSettle();

      expect(container.read(patchClashConfigProvider).mitm.capture, isTrue);
      await tester.tap(find.text('HTTP'));
      await tester.pumpAndSettle();
      expect(find.byType(HttpRequestList), findsOneWidget);
      expect(
        find.byType(ConditionFilterRow<MitmExchangeSummary, HttpRequestStatus>),
        findsOneWidget,
      );

      await openMenu(tester);
      await tester.tap(find.text(currentAppLocalizations.turnOff));
      await tester.pumpAndSettle();

      expect(container.read(patchClashConfigProvider).mitm.capture, isFalse);
      expect(find.text('HTTP'), findsNothing);
      expect(find.byType(HttpRequestList), findsNothing);
      expect(noConnections(), findsOneWidget);

      await teardownView(tester);
    });

    testWidgets('the menu keeps how many records capture holds', (
      tester,
    ) async {
      setUpContainer();
      capture();
      await pumpHttp(tester, open: false);

      await openMenu(tester);
      expect(find.text(currentAppLocalizations.httpCapture), findsOneWidget);
      await tester.tap(find.text(currentAppLocalizations.httpCaptureLimit));
      await tester.pumpAndSettle();
      await tester.tap(find.text('5000'));
      await tester.pumpAndSettle();

      expect(
        container.read(patchClashConfigProvider).mitm.captureEntries,
        5000,
      );

      await teardownView(tester);
    });

    testWidgets('without decryption the menu has no capture section', (
      tester,
    ) async {
      setUpContainer();
      await pumpHttp(tester, open: false);

      await openMenu(tester);

      expect(find.text(currentAppLocalizations.httpCapture), findsNothing);
      expect(
        find.text(currentAppLocalizations.closeActiveConnections),
        findsOneWidget,
      );
      expect(find.byGlyph(AppGlyphs.block), findsNothing);

      await teardownView(tester);
    });

    testWidgets('turning decryption off leaves the HTTP segment for '
        'connections', (tester) async {
      setUpContainer();
      capture();
      await pumpHttp(tester);
      expect(find.byType(HttpRequestList), findsOneWidget);

      decrypt(on: false);
      await tester.pumpAndSettle();

      expect(find.text('HTTP'), findsNothing);
      expect(find.byType(HttpRequestList), findsNothing);
      expect(noConnections(), findsOneWidget);

      await teardownView(tester);
    });

    testWidgets('a page opened on HTTP without decryption opens on '
        'connections', (tester) async {
      setUpContainer();
      container.read(viewSizeProvider.notifier).update((_) => _paneSize);
      tester.view.physicalSize = _paneSize;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TestApp(
            child: RequestsView(
              segment: RequestsSegment.http,
              connectionsReader: () async => const [],
              httpQuery: _query,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('HTTP'), findsNothing);
      expect(noConnections(), findsOneWidget);

      await teardownView(tester);
    });

    testWidgets('with no listed host the empty list says capture needs one', (
      tester,
    ) async {
      setUpContainer();
      container
          .read(patchClashConfigProvider.notifier)
          .update(
            (state) => state.copyWith(
              mitm: state.mitm.copyWith(
                enable: true,
                capture: true,
                hostname: const ['-a.example'],
              ),
            ),
          );
      await pumpHttp(
        tester,
        query: ({before, since, required limit}) async =>
            const MitmQueryPage(capturing: true, version: 1, exchanges: []),
      );

      expect(
        find.text(currentAppLocalizations.httpCaptureNoHosts),
        findsOneWidget,
      );

      await teardownView(tester);
    });
  }
}
