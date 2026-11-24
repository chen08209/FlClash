import 'dart:convert';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/mitm_body.dart';
import 'package:fl_clash/features/features.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/mitm.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/record_lines.dart';
import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';
import '../helpers/host_scaffold.dart';

final _start = DateTime.utc(2026, 10, 28, 0, 0, 5);

final _decrypted = TrackerInfo(
  id: 'connection-1',
  start: _start,
  metadata: const Metadata(network: 'tcp', host: 'a.test', mitm: true),
  chains: const ['DIRECT'],
  rule: 'MATCH',
  rulePayload: '',
);

final _exchange = MitmExchange(
  id: 7,
  start: _start,
  duration: 35,
  ttfb: 20,
  method: 'GET',
  url: 'https://a.test/new?x=1',
  originalUrl: 'https://a.test/old?x=1',
  proto: 'HTTP/2.0',
  status: 200,
  reason: 'OK',
  responseSize: 2048,
  connection: 'connection-1',
  requestHeader: const {
    'Host': ['a.test'],
  },
  responseHeader: const {
    'X-Upstream': ['yes'],
  },
  actions: const [
    MitmAction(
      kind: 'header-rewrite',
      phase: 'request',
      detail: 'header-del X-Forwarded-For',
    ),
    MitmAction(kind: 'url-rewrite', detail: 'header'),
    MitmAction(kind: 'script', phase: 'response', detail: 'sign'),
  ],
);

MitmExchangeSummary _summary(MitmExchange exchange) => MitmExchangeSummary(
  id: exchange.id,
  start: exchange.start,
  pending: exchange.pending,
  duration: exchange.duration,
  method: exchange.method,
  url: exchange.url,
  status: exchange.status,
  responseSize: exchange.responseSize,
);

Future<ProviderContainer> _pumpDetail(
  WidgetTester tester, {
  required MitmExchangeList list,
  Exception? listError,
  Exception? bodyError,
  MitmExchange? exchange,
  bool capture = true,
  MitmBody responseBody = const MitmBody(),
  List<MitmModule> modules = const [],
  bool inSheet = false,
  bool inPane = false,
  bool retry = false,
  VoidCallback? onBodyRead,
}) async {
  final contentType = mitmHeaderValue(
    (exchange ?? _exchange).responseHeader,
    'Content-Type',
  );
  final container = ProviderContainer(
    retry: retry ? null : (_, _) => null,
    overrides: [
      mitmExchangesProvider(
        _decrypted.id,
      ).overrideWith((ref) async => listError == null ? list : throw listError),
      mitmExchangeProvider(7).overrideWith((ref) async => exchange),
      mitmBodyProvider(
        7,
        response: true,
        contentType: contentType,
      ).overrideWith((ref) async {
        onBodyRead?.call();
        return bodyError == null
            ? readMitmBody((responseBody, contentType, grpcOverLimitNote: null))
            : throw bodyError;
      }),
      mitmModulesProvider.overrideWith(() => _Modules(modules)),
    ],
  );
  addTearDown(container.dispose);
  container.listen(patchClashConfigProvider, (_, _) {});
  container.read(patchClashConfigProvider.notifier).value = PatchClashConfig(
    mitm: Mitm(enable: true, capture: capture),
  );
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: TestApp(
        homeBuilder: (child) => HostScaffold(body: child),
        child: inSheet
            ? Builder(
                builder: (context) => GestureDetector(
                  onTap: () =>
                      showTrackerInfoDetail(context, _decrypted, 'Detail'),
                  child: const Text('open'),
                ),
              )
            : inPane
            ? DetailPane(child: TrackerInfoDetailView(trackerInfo: _decrypted))
            : SheetProvider(
                type: SheetType.page,
                child: TrackerInfoDetailView(trackerInfo: _decrypted),
              ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

class _Modules extends MitmModules {
  _Modules(this.modules);

  final List<MitmModule> modules;

  @override
  Stream<List<MitmModule>> build() => Stream.value(modules);
}

Finder _inMenu(Finder finder) =>
    find.descendant(of: find.byType(PopupMenu), matching: finder);

Future<void> _openRequest(WidgetTester tester) async {
  await _openTab(tester, currentAppLocalizations.httpRequests);
  await tester.tap(find.text('/new?x=1'));
  await tester.pumpAndSettle();
}

Future<void> _openBarMenu(WidgetTester tester) async {
  await tester.tap(
    find.descendant(
      of: find.byType(MitmExchangeView),
      matching: find.byGlyph(AppGlyphs.more),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _tab(String label) => find.descendant(
  of: find.byType(SegmentedControl<int>).last,
  matching: find.textContaining(RegExp('^${RegExp.escape(label)}( \\d+)?\$')),
);

Future<void> _openTab(WidgetTester tester, String label) async {
  await tester.tap(_tab(label));
  await tester.pumpAndSettle();
}

Future<void> _scrollTo(WidgetTester tester, Finder finder) {
  return tester.scrollUntilVisible(
    finder,
    100,
    scrollable: find.byType(Scrollable).last,
  );
}

void main() {
  testWidgets('with capture off a decrypted connection offers its timeline '
      'and info alone', (tester) async {
    await _pumpDetail(tester, list: const MitmExchangeList(), capture: false);

    expect(_tab('Timeline'), findsOneWidget);
    expect(_tab('Info'), findsOneWidget);
    expect(_tab(currentAppLocalizations.httpRequests), findsNothing);
    await _openTab(tester, 'Info');
    expect(find.text(currentAppLocalizations.connectionPath), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a decrypted connection offers its requests in a tab only in '
      'a build that decrypts', (tester) async {
    await _pumpDetail(tester, list: const MitmExchangeList());

    expect(
      _tab(currentAppLocalizations.httpRequests),
      [if (rsFeature) findsOneWidget].firstOrNull ?? findsNothing,
    );
    await _openTab(tester, 'Info');
    expect(find.text(currentAppLocalizations.connectionPath), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a decrypted connection is marked in its row only in a build '
      'that decrypts', (tester) async {
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        homeBuilder: (child) => HostScaffold(body: child),
        child: TrackerInfoItem(trackerInfo: _decrypted, detailTitle: 'detail'),
      ),
    );
    await tester.pump();

    expect(
      find.text('MITM'),
      [if (rsFeature) findsOneWidget].firstOrNull ?? findsNothing,
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });

  if (rsFeature) {
    testWidgets('a request opens as a page of its connection\'s sheet', (
      tester,
    ) async {
      await _pumpDetail(
        tester,
        list: MitmExchangeList(
          capturing: true,
          exchanges: [_summary(_exchange)],
        ),
        exchange: _exchange,
        inSheet: true,
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      final pages = Navigator.of(
        tester.element(find.byType(TrackerInfoDetailView)),
      );
      expect(pages.widget, isA<SheetPagesNavigator>());

      await _openRequest(tester);

      final request = find.byType(MitmExchangeView);
      expect(ModalRoute.of(tester.element(request)), isA<PagedSheetRoute>());
      expect(Navigator.of(tester.element(request)), same(pages));
      final method = tester.widget<Text>(
        find.descendant(
          of: find.descendant(of: request, matching: find.byType(LabelWell)),
          matching: find.byType(Text),
        ),
      );
      expect(method.style?.fontFamily, FontFamily.jetBrainsMono.value);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('a read that fails says so rather than showing no requests', (
      tester,
    ) async {
      final container = await _pumpDetail(
        tester,
        list: const MitmExchangeList(),
        listError: Exception('core gone'),
      );

      await _openTab(tester, currentAppLocalizations.httpRequests);

      expect(
        find.text(currentAppLocalizations.httpRequestsReadFailed),
        findsOneWidget,
      );
      expect(find.textContaining('core gone'), findsOneWidget);
      expect(find.text(currentAppLocalizations.copy), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('a read that is retried shows no error yet', (tester) async {
      final container = await _pumpDetail(
        tester,
        list: const MitmExchangeList(),
        listError: Exception('core gone'),
        retry: true,
      );

      await tester.tap(_tab(currentAppLocalizations.httpRequests));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.textContaining('core gone'), findsNothing);
      expect(
        find.text(currentAppLocalizations.httpRequestsReadFailed),
        findsNothing,
      );

      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('a body that fails says so beside its headers', (tester) async {
      final container = await _pumpDetail(
        tester,
        list: MitmExchangeList(
          capturing: true,
          exchanges: [_summary(_exchange)],
        ),
        exchange: _exchange,
        bodyError: Exception('body gone'),
      );

      await _openRequest(tester);
      await _openTab(tester, currentAppLocalizations.response);

      expect(find.text('X-Upstream'), findsOneWidget);
      expect(
        find.text(currentAppLocalizations.responseBodyReadFailed),
        findsOneWidget,
      );
      expect(find.textContaining('body gone'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('the timeline sums up the requests in one step that opens '
        'their tab', (tester) async {
      await _pumpDetail(
        tester,
        list: MitmExchangeList(
          capturing: true,
          exchanges: [
            _summary(_exchange),
            MitmExchangeSummary(
              id: 8,
              start: _start.add(const Duration(seconds: 1)),
              method: 'POST',
              url: 'https://a.test/graphql',
              status: 502,
            ),
          ],
        ),
        exchange: _exchange,
      );

      expect(find.text('2 HTTP requests'), findsOneWidget);
      expect(findRecordLine('HTTP [Latest POST /graphql 502]'), findsOneWidget);
      expect(find.byType(MitmExchangesView), findsNothing);

      await tester.tap(find.text('2 HTTP requests'));
      await tester.pumpAndSettle();
      expect(find.byType(MitmExchangesView), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('a decrypted connection lists its requests in a tab of their '
        'own, and a request opens on tabs too', (tester) async {
      await _pumpDetail(
        tester,
        list: MitmExchangeList(
          capturing: true,
          since: _start.subtract(const Duration(minutes: 1)),
          exchanges: [
            _summary(_exchange).copyWith(
              actionKinds: ['header-rewrite', 'url-rewrite', 'script'],
            ),
            MitmExchangeSummary(
              id: 8,
              start: _start,
              pending: true,
              method: 'POST',
              url: 'https://a.test/upload',
            ),
          ],
        ),
        exchange: _exchange,
      );
      final appLocalizations = currentAppLocalizations;

      expect(find.text('/new?x=1'), findsNothing);
      expect(_tab('${appLocalizations.httpRequests} 2'), findsOneWidget);

      await _openTab(tester, appLocalizations.httpRequests);

      expect(find.text('/new?x=1'), findsOneWidget);
      expect(
        tester
            .getSize(
              find.ancestor(
                of: find.text('/new?x=1'),
                matching: find.byType(DecorationListItem),
              ),
            )
            .height,
        listRowExtent(titleHeight: 20, subtitleHeight: 18 + recordLabelLineGap),
      );
      expect(
        findRecordLine(
          'GET [+200] [${2048.traffic.show}] [35 ms] '
          '[${appLocalizations.headerRewrite} +2]',
        ),
        findsOneWidget,
      );
      expect(find.text('/upload'), findsOneWidget);
      expect(
        findRecordLine('POST [${appLocalizations.inProgress}]'),
        findsOneWidget,
      );
      expect(find.text(appLocalizations.httpRequestsMissing), findsNothing);

      await tester.tap(find.text('/new?x=1'));
      await tester.pumpAndSettle();

      expect(recordLinesIn(tester, find.byType(DetailHeader)), [
        '[+200 OK] [35 ms] [${2048.traffic.show}]',
      ]);
      expect(find.text('https://a.test/old?x=1'), findsOneWidget);
      expect(find.text('HTTP/2.0'), findsOneWidget);
      expect(find.text('X-Upstream'), findsNothing);
      await _scrollTo(tester, find.text(appLocalizations.urlRewrite));
      expect(find.text(appLocalizations.total), findsOneWidget);
      expect(
        find.text('${appLocalizations.httpWaiting} 20 ms'),
        findsOneWidget,
      );
      expect(
        find.text('${appLocalizations.httpReceiving} 15 ms'),
        findsOneWidget,
      );
      expect(find.text('header'), findsOneWidget);
      expect(find.text('sign'), findsOneWidget);
      final signLabels = findRecordLine('[${appLocalizations.response}]');
      expect(signLabels, findsOneWidget);
      expect(
        tester.getRect(signLabels).top,
        greaterThanOrEqualTo(tester.getRect(find.text('sign')).bottom),
      );
      final deleted = find.text('${appLocalizations.delete} X-Forwarded-For');
      expect(tester.widget<Text>(deleted).maxLines, 3);
      expect(findRecordLine('[${appLocalizations.request}]'), findsOneWidget);

      await _openTab(tester, appLocalizations.request);
      expect(find.text('Host'), findsOneWidget);
      expect(find.text('X-Upstream'), findsNothing);

      await _openTab(tester, appLocalizations.response);
      expect(find.text('X-Upstream'), findsOneWidget);
      expect(find.text('yes'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('beside the list a request opens over its connection, under '
        'a button back to its requests', (tester) async {
      await _pumpDetail(
        tester,
        list: MitmExchangeList(
          capturing: true,
          since: _start.subtract(const Duration(minutes: 1)),
          exchanges: [_summary(_exchange)],
        ),
        exchange: _exchange,
        inPane: true,
      );
      await _openRequest(tester);

      final view = find.byType(MitmExchangeView);
      expect(view, findsOneWidget);
      expect(find.byType(DetailSheet), findsNothing);
      expect(
        find.descendant(of: view, matching: find.byGlyph(AppGlyphs.more)),
        findsOneWidget,
      );
      final back = find.widgetWithText(TonalButton, _decrypted.title);
      await tester.tap(back);
      await tester.pumpAndSettle();

      expect(view, findsNothing);
      expect(find.text('/new?x=1'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('a connection made before capture says its list may be short', (
      tester,
    ) async {
      await _pumpDetail(
        tester,
        list: MitmExchangeList(
          capturing: true,
          since: _start.add(const Duration(minutes: 1)),
        ),
      );
      await _openTab(tester, currentAppLocalizations.httpRequests);

      expect(
        find.text(currentAppLocalizations.httpRequestsMissing),
        findsOneWidget,
      );

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('a decrypted connection with no requests yet says they '
        'will show there, and offers nothing to do', (tester) async {
      await _pumpDetail(
        tester,
        list: MitmExchangeList(
          capturing: true,
          since: _start.subtract(const Duration(minutes: 1)),
        ),
      );
      await _openTab(tester, currentAppLocalizations.httpRequests);

      expect(find.text(currentAppLocalizations.noHttpRequests), findsOneWidget);
      expect(
        find.text(currentAppLocalizations.noHttpRequestsHint),
        findsOneWidget,
      );
      expect(find.byType(TonalButton), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('a connection says when the Core is not capturing', (
      tester,
    ) async {
      await _pumpDetail(tester, list: const MitmExchangeList());
      await _openTab(tester, currentAppLocalizations.httpRequests);

      expect(find.text(currentAppLocalizations.httpCaptureOff), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('a request the Core no longer keeps says so', (tester) async {
      await _pumpDetail(
        tester,
        list: MitmExchangeList(
          capturing: true,
          since: _start,
          exchanges: [_summary(_exchange)],
        ),
      );
      await _openTab(tester, currentAppLocalizations.httpRequests);

      await tester.tap(find.text('/new?x=1'));
      await tester.pumpAndSettle();

      expect(
        find.text(currentAppLocalizations.httpRequestCleared),
        findsOneWidget,
      );

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('a request still waiting on its answer says so under '
        'Response', (tester) async {
      final waiting = _exchange.copyWith(
        pending: true,
        status: 0,
        responseSize: 0,
        responseHeader: const {},
      );
      await _pumpDetail(
        tester,
        list: MitmExchangeList(
          capturing: true,
          since: _start,
          exchanges: [_summary(waiting)],
        ),
        exchange: waiting,
      );
      await _openTab(tester, currentAppLocalizations.httpRequests);
      await tester.tap(find.text('/new?x=1'));
      await tester.pumpAndSettle();
      await _openTab(tester, currentAppLocalizations.response);

      final detail = find.byType(MitmExchangeView);
      expect(
        find.descendant(of: detail, matching: find.byType(NullStatus)),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(NullStatus),
          matching: find.text(currentAppLocalizations.inProgress),
        ),
        findsOneWidget,
      );

      await tester.pumpWidget(const SizedBox.shrink());
    });

    Future<Finder> openResponse(
      WidgetTester tester, {
      required String contentType,
      required MitmBody body,
    }) async {
      final exchange = _exchange.copyWith(
        responseHeader: {
          'Content-Type': [contentType],
        },
      );
      await _pumpDetail(
        tester,
        list: MitmExchangeList(
          capturing: true,
          since: _start,
          exchanges: [_summary(exchange)],
        ),
        exchange: exchange,
        responseBody: body,
      );
      await _openTab(tester, currentAppLocalizations.httpRequests);
      await tester.tap(find.text('/new?x=1'));
      await tester.pumpAndSettle();
      await _openTab(tester, currentAppLocalizations.response);
      return find.byType(MitmExchangeView);
    }

    testWidgets('a body read once stays while its request is open', (
      tester,
    ) async {
      var reads = 0;
      final exchange = _exchange.copyWith(
        responseHeader: {
          'Content-Type': ['text/plain'],
        },
      );
      await _pumpDetail(
        tester,
        list: MitmExchangeList(
          capturing: true,
          since: _start,
          exchanges: [_summary(exchange)],
        ),
        exchange: exchange,
        responseBody: MitmBody(data: base64Encode(utf8.encode('hi'))),
        onBodyRead: () => reads++,
      );
      await _openRequest(tester);
      await _openTab(tester, currentAppLocalizations.response);
      expect(find.text('hi'), findsOneWidget);
      await _openTab(tester, currentAppLocalizations.overview);
      await _openTab(tester, currentAppLocalizations.response);

      expect(find.text('hi'), findsOneWidget);
      expect(reads, 1);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('a finished request shows its body, and says when only its '
        'start was kept', (tester) async {
      final detail = await openResponse(
        tester,
        contentType: 'application/json; charset=utf-8',
        body: MitmBody(
          data: base64Encode(utf8.encode('{"ok":1}')),
          truncated: true,
        ),
      );

      expect(
        find.descendant(of: detail, matching: find.text('{\n  "ok": 1\n}')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: detail,
          matching: find.text('${2048.traffic.show} · JSON'),
        ),
        findsOneWidget,
      );
      expect(
        find.text(currentAppLocalizations.httpBodyTruncated),
        findsOneWidget,
      );

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets(
      'a body that is not text opens its bytes on a page of its own',
      (tester) async {
        final detail = await openResponse(
          tester,
          contentType: 'application/octet-stream',
          body: MitmBody(data: base64Encode([0, 1, 2, 3]), truncated: true),
        );

        final binary = find.descendant(
          of: detail,
          matching: find.text(currentAppLocalizations.binaryData),
        );
        final visible = tester.getRect(find.byType(SheetDragHandle).first);
        await tester.dragFrom(
          visible.bottomCenter + const Offset(0, 120),
          const Offset(0, -300),
        );
        await tester.pumpAndSettle();
        await tester.tap(binary);
        await tester.pumpAndSettle();

        expect(find.textContaining('000000  00 01 02 03'), findsOneWidget);
        expect(
          find.text(currentAppLocalizations.httpBodyTruncated),
          findsAtLeastNWidgets(1),
        );

        await tester.pumpWidget(const SizedBox.shrink());
      },
    );

    testWidgets('an image body decodes no taller than its box shows it', (
      tester,
    ) async {
      final detail = await openResponse(
        tester,
        contentType: 'image/png',
        body: MitmBody(data: base64Encode([0x89, 0x50, 0x4e, 0x47])),
      );
      final image = find.descendant(of: detail, matching: find.byType(Image));
      final resize = tester.widget<Image>(image).image as ResizeImage;
      final ratio = MediaQuery.devicePixelRatioOf(tester.element(image));

      expect(resize.height, (240 * ratio).round());
      expect(resize.allowUpscaling, isFalse);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('a body under no headers starts where the headers would', (
      tester,
    ) async {
      final exchange = _exchange.copyWith(responseHeader: {});
      await _pumpDetail(
        tester,
        list: MitmExchangeList(
          capturing: true,
          since: _start,
          exchanges: [_summary(exchange)],
        ),
        exchange: exchange,
        responseBody: MitmBody(data: base64Encode(utf8.encode('hi'))),
      );
      await _openRequest(tester);
      await _openTab(tester, currentAppLocalizations.response);

      final header = find.ancestor(
        of: find.text(currentAppLocalizations.responseBody),
        matching: find.byType(ListHeader),
      );
      expect(tester.widget<ListHeader>(header).atTop, isTrue);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('a text body also offers its bytes', (tester) async {
      final detail = await openResponse(
        tester,
        contentType: 'text/plain',
        body: MitmBody(data: base64Encode(utf8.encode('hi'))),
      );

      expect(
        find.descendant(
          of: detail,
          matching: find.text(currentAppLocalizations.hex),
        ),
        findsOneWidget,
      );

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('a row in the list long-presses to the same menu', (
      tester,
    ) async {
      final exchange = _exchange.copyWith(responseSize: 7);
      await _pumpDetail(
        tester,
        list: MitmExchangeList(
          capturing: true,
          since: _start,
          exchanges: [_summary(exchange)],
        ),
        exchange: exchange,
      );
      await _openTab(tester, currentAppLocalizations.httpRequests);
      await tester.longPress(find.text('/new?x=1'));
      await tester.pumpAndSettle();

      for (final label in [
        currentAppLocalizations.copyLink,
        currentAppLocalizations.copyAsCurl,
        currentAppLocalizations.copyRequest,
        currentAppLocalizations.copyResponse,
        currentAppLocalizations.copyResponseBody,
        currentAppLocalizations.exportHar,
      ]) {
        expect(find.text(label), findsOneWidget);
      }

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('a request copies as cURL once told what it carries', (
      tester,
    ) async {
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
      await _pumpDetail(
        tester,
        list: MitmExchangeList(
          capturing: true,
          since: _start,
          exchanges: [_summary(_exchange)],
        ),
        exchange: _exchange,
      );
      await _openRequest(tester);
      final l10n = currentAppLocalizations;

      Future<void> copy() async {
        await _openBarMenu(tester);
        await tester.tap(_inMenu(find.text(l10n.copyAsCurl)));
        await tester.pumpAndSettle();
      }

      await copy();
      expect(find.text(l10n.httpExportPrivateTitle), findsOneWidget);
      await tester.runAsync(() async {
        await tester.tap(find.text(l10n.copyAsCurl).last);
        for (var i = 0; i < 50 && copied.isEmpty; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 20));
          await tester.pump();
        }
      });
      await tester.pumpAndSettle();
      expect(copied, [startsWith("curl 'https://a.test/new?x=1'")]);

      await tester.runAsync(() async {
        await copy();
        for (var i = 0; i < 50 && copied.length < 2; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 20));
          await tester.pump();
        }
      });
      await tester.pumpAndSettle();
      expect(find.text(l10n.httpExportPrivateTitle), findsNothing);
      expect(copied, hasLength(2));

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('a rule goes to a new module or one the user wrote, and only '
        'an answered request maps locally', (tester) async {
      final now = DateTime.utc(2026);
      final waiting = _exchange.copyWith(pending: true, status: 0);
      for (final exchange in [_exchange, waiting]) {
        await _pumpDetail(
          tester,
          list: MitmExchangeList(
            capturing: true,
            since: _start,
            exchanges: [_summary(exchange)],
          ),
          exchange: exchange,
          modules: [
            MitmModule(id: 1, name: 'Mine', lastUpdateTime: now),
            MitmModule(
              id: 2,
              name: 'Subscribed',
              url: 'https://a.test/m',
              lastUpdateTime: now,
            ),
          ],
        );
        await _openRequest(tester);
        await _openBarMenu(tester);
        final l10n = currentAppLocalizations;
        expect(
          _inMenu(find.text(l10n.mitmAddMapLocalRule)),
          exchange.pending ? findsNothing : findsOneWidget,
        );
        await tester.tap(_inMenu(find.text(l10n.mitmAddRejectRule)));
        await tester.pumpAndSettle();
        expect(_inMenu(find.text(l10n.mitmNewModule)), findsOneWidget);
        expect(_inMenu(find.text('Mine')), findsOneWidget);
        expect(_inMenu(find.text('Subscribed')), findsNothing);

        await tester.pumpWidget(const SizedBox.shrink());
      }
    });

    testWidgets('a refresh that brings the same requests rebuilds nothing', (
      tester,
    ) async {
      final list = MitmExchangeList(
        capturing: true,
        since: _start,
        exchanges: [_summary(_exchange)],
      );
      final container = await _pumpDetail(tester, list: list);
      await _openTab(tester, currentAppLocalizations.httpRequests);

      var rebuilds = 0;
      debugOnRebuildDirtyWidget = (element, _) {
        if (element.widget is MitmExchangesView) rebuilds++;
      };
      try {
        container.invalidate(mitmExchangesProvider(_decrypted.id));
        await tester.pumpAndSettle();
      } finally {
        debugOnRebuildDirtyWidget = null;
      }
      expect(rebuilds, 0);
      expect(find.text('/new?x=1'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
