import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/core/method.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/features/features.dart';
import 'package:fl_clash/views/connection/requests.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/hidden_segments.dart';
import '../helpers/record_lines.dart';
import '../helpers/status_menu.dart';
import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

class _MockCoreHandlerInterface extends Mock implements CoreHandlerInterface {}

const _paneSize = Size(1400, 1000);
const _narrowSize = Size(600, 1000);

DnsQuery _dnsQuery(
  String domain, {
  String type = 'A',
  DnsQueryInitiator? initiator,
  String upstream = '',
  bool cached = false,
  List<String> answers = const ['1.1.1.1'],
  String rcode = 'NOERROR',
  String error = '',
  int delay = 12,
}) {
  return DnsQuery(
    domain: domain,
    type: type,
    initiator: initiator,
    upstream: upstream,
    cached: cached,
    answers: answers,
    rcode: rcode,
    error: error,
    delay: delay,
    time: DateTime.utc(2026, 9, 18, 4, 30),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late _MockCoreHandlerInterface core;

  setUp(() {
    core = _MockCoreHandlerInterface();
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(TestProfiles.new),
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
      ],
    );
    globalState.container = container;
    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(1400, 1000));
  });

  tearDown(() => container.dispose());

  void seedDnsQueries(List<DnsQuery> dnsQueries) {
    final notifier = container.read(dnsQueriesProvider.notifier);
    notifier.value = FixedList<DnsQuery>(500);
    for (final dnsQuery in dnsQueries) {
      notifier.addQuery(dnsQuery);
    }
  }

  Future<void> pumpDnsQueries(
    WidgetTester tester, {
    Size size = _paneSize,
  }) async {
    container.read(viewSizeProvider.notifier).update((_) => size);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: RequestsView(segment: RequestsSegment.dns)),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  Future<void> teardownView(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  }

  Finder inMenu(Finder finder) =>
      find.descendant(of: find.byType(PopupMenu), matching: finder);

  Finder inDialog(Finder finder) =>
      find.descendant(of: find.byType(AlertDialog), matching: finder);

  Future<void> openAdd(WidgetTester tester) async {
    await tester.tap(
      find.descendant(
        of: find.byType(ConditionFilterRow<DnsQuery, DnsStatus>),
        matching: find.byGlyph(AppGlyphs.add),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> clearDnsCache(WidgetTester tester) async {
    await tester.tap(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.byGlyph(AppGlyphs.more),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(inMenu(find.text('Clear DNS cache')));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the empty state without any query', (tester) async {
    await pumpDnsQueries(tester);

    expect(find.text('No DNS queries yet'), findsOneWidget);
    expect(find.text('Select a query'), findsOneWidget);

    await teardownView(tester);
  });

  testWidgets('lists each query with its domain and result', (tester) async {
    seedDnsQueries([
      _dnsQuery(
        'alpha.test',
        initiator: DnsQueryInitiator.app,
        answers: ['93.184.216.34', '93.184.216.35'],
      ),
      _dnsQuery('cached.test', cached: true),
      _dnsQuery(
        'missing.test',
        type: 'AAAA',
        answers: const [],
        rcode: 'NXDOMAIN',
      ),
      _dnsQuery(
        'timeout.test',
        answers: const [],
        rcode: '',
        error: 'i/o timeout',
      ),
    ]);

    await pumpDnsQueries(tester, size: _narrowSize);

    expect(find.byType(DnsQueryRow), findsNWidgets(4));
    expect(find.text('alpha.test'), findsOneWidget);
    expect(
      recordLinesIn(tester),
      unorderedEquals([
        '93.184.216.34, 93.184.216.35 [App]',
        '1.1.1.1 [Cache]',
        '[!No such domain]',
        '[!Query timed out]',
      ]),
    );
    expect(find.text('NXDOMAIN'), findsNothing);
    expect(find.text('i/o timeout'), findsNothing);
    expect(find.text('12 ms'), findsNWidgets(4));

    await teardownView(tester);
  });

  testWidgets('on a phone a query opens in a sheet whose bar holds its menu, '
      'over a head with no buttons', (tester) async {
    seedDnsQueries([_dnsQuery('alpha.test')]);
    await pumpDnsQueries(tester, size: _narrowSize);

    await tester.tap(find.text('alpha.test'));
    await tester.pumpAndSettle();

    final header = find.byType(DetailHeader);
    expect(find.text('DNS details'), findsOneWidget);
    expect(
      find.descendant(of: header, matching: find.byType(TonalButtonGroup)),
      findsNothing,
    );
    final handle = find.byType(SheetDragHandle);
    final scale = tester.getRect(handle).height / SheetDragHandle.height;
    expect(
      (tester.getTopLeft(header).dy - tester.getTopLeft(handle).dy) / scale,
      closeTo(sheetAppBarHeight + appBarContentGap, 0.01),
    );

    await tester.tap(
      find.descendant(
        of: find.ancestor(of: header, matching: find.byType(Scaffold)).first,
        matching: find.byTooltip('More'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Copy domain'), findsOneWidget);
    expect(find.text('Only this domain'), findsNothing);

    await teardownView(tester);
  });

  testWidgets('a query arriving after mount reaches the list', (tester) async {
    seedDnsQueries([_dnsQuery('alpha.test')]);

    await pumpDnsQueries(tester);
    expect(find.text('gamma.test'), findsNothing);

    container
        .read(dnsQueriesProvider.notifier)
        .addQuery(_dnsQuery('gamma.test'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    await tester.pump();

    expect(find.text('gamma.test'), findsOneWidget);

    await teardownView(tester);
  });

  testWidgets('the Failed segment keeps only the failed queries', (
    tester,
  ) async {
    seedDnsQueries([
      _dnsQuery('alpha.test'),
      _dnsQuery('missing.test', rcode: 'NXDOMAIN', answers: const []),
      _dnsQuery('timeout.test', error: 'i/o timeout', answers: const []),
    ]);

    await pumpDnsQueries(tester);
    expect(find.text('alpha.test'), findsOneWidget);

    await pickStatus(tester, 'Failed 2');

    expect(find.text('alpha.test'), findsNothing);
    expect(find.text('missing.test'), findsOneWidget);
    expect(find.text('timeout.test'), findsOneWidget);

    await teardownView(tester);
  });

  testWidgets('a status with no queries says so rather than that nothing '
      'matched', (tester) async {
    seedDnsQueries([_dnsQuery('alpha.test')]);

    await pumpDnsQueries(tester);
    await pickStatus(tester, 'Failed 0');

    expect(find.text('No failed DNS queries'), findsOneWidget);
    expect(find.text('No matching results'), findsNothing);

    await teardownView(tester);
  });

  testWidgets('the Cached segment keeps only the queries the cache answered', (
    tester,
  ) async {
    seedDnsQueries([
      _dnsQuery('alpha.test', cached: true),
      _dnsQuery('beta.test'),
    ]);

    await pumpDnsQueries(tester);
    await pickStatus(tester, 'Cache 1');

    expect(find.text('alpha.test'), findsOneWidget);
    expect(find.text('beta.test'), findsNothing);

    await teardownView(tester);
  });

  testWidgets('a condition on the record type keeps only the queries of it, '
      'counted as typed, and offers the types the list holds', (tester) async {
    seedDnsQueries([
      _dnsQuery('alpha.test'),
      _dnsQuery('beta.test', type: 'AAAA', answers: ['::1']),
    ]);

    await pumpDnsQueries(tester);
    await openAdd(tester);
    expect(inDialog(find.text('Domain')), findsOneWidget);
    await tester.tap(inDialog(find.text('Record type')));
    await tester.pumpAndSettle();
    expect(inDialog(find.text('Record type in the list')), findsOneWidget);
    expect(inDialog(find.text('AAAA')), findsOneWidget);
    expect(find.text('Queries shown: 2'), findsOneWidget);

    await tester.tap(inDialog(find.text('AAAA')));
    await tester.pump();
    expect(find.text('Queries shown: 1'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Add'));
    await tester.pumpAndSettle();

    expect(find.text('alpha.test'), findsNothing);
    expect(find.text('beta.test'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(ConditionBlock<DnsQuery>),
        matching: find.text('Contains AAAA'),
      ),
      findsOneWidget,
    );

    await teardownView(tester);
  });

  testWidgets('a query\'s row menu copies it and narrows the list to its '
      'domain, set as a condition on it', (tester) async {
    seedDnsQueries([
      _dnsQuery('alpha.test'),
      _dnsQuery('beta.test', answers: const []),
    ]);

    await pumpDnsQueries(tester);
    await tester.longPress(find.text('beta.test'));
    await tester.pumpAndSettle();
    expect(inMenu(find.text('Copy domain')), findsOneWidget);
    expect(inMenu(find.text('Copy answers')), findsNothing);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    await tester.tap(
      find.text('alpha.test'),
      buttons: kSecondaryMouseButton,
      kind: PointerDeviceKind.mouse,
    );
    await tester.pumpAndSettle();
    expect(inMenu(find.text('Copy answers')), findsOneWidget);
    await tester.tap(inMenu(find.text('Only this domain')));
    await tester.pumpAndSettle();

    expect(find.text('alpha.test'), findsWidgets);
    expect(find.text('beta.test'), findsNothing);
    expect(
      find.descendant(
        of: find.byType(ConditionBlock<DnsQuery>),
        matching: find.text('Equals alpha.test'),
      ),
      findsOneWidget,
    );

    await teardownView(tester);
  });

  testWidgets('a query arriving later is offered in the condition dialog', (
    tester,
  ) async {
    seedDnsQueries([_dnsQuery('alpha.test')]);

    await pumpDnsQueries(tester);
    container
        .read(dnsQueriesProvider.notifier)
        .addQuery(_dnsQuery('beta.test', type: 'AAAA'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    await tester.pump();

    await openAdd(tester);
    await tester.tap(inDialog(find.text('Record type')));
    await tester.pumpAndSettle();
    expect(inDialog(find.text('AAAA')), findsOneWidget);

    await teardownView(tester);
  });

  testWidgets('tapping a query on a narrow page opens its details half way '
      'in a sheet', (tester) async {
    seedDnsQueries([
      _dnsQuery(
        'alpha.test',
        initiator: DnsQueryInitiator.rule,
        upstream: 'tls://1.1.1.1:853',
        cached: true,
        answers: ['edge.alpha.net', '93.184.216.34'],
      ),
    ]);

    await pumpDnsQueries(tester, size: _narrowSize);
    expect(find.byType(DnsQueryDetailView), findsNothing);

    await tester.tap(find.text('alpha.test'));
    await tester.pumpAndSettle();

    expect(find.text('DNS details'), findsOneWidget);
    expect(find.byType(DnsQueryDetailView), findsOneWidget);
    expect(
      tester.getTopLeft(find.byType(SheetDragHandle)).dy,
      closeTo(_narrowSize.height * (1 - snapSheetDetents.first), 1),
    );
    Finder detailText(String text) => find.descendant(
      of: find.byType(DnsQueryDetailView),
      matching: find.text(text),
    );
    expect(detailText('Record type'), findsOneWidget);
    expect(detailText('tls://1.1.1.1:853'), findsOneWidget);
    expect(detailText('Yes'), findsOneWidget);
    expect(detailText('edge.alpha.net'), findsOneWidget);
    expect(detailText('93.184.216.34'), findsOneWidget);

    await teardownView(tester);
  });

  testWidgets('a query that leaves the list takes its pane with it', (
    tester,
  ) async {
    final notifier = container.read(dnsQueriesProvider.notifier);
    notifier.value = FixedList<DnsQuery>(2);
    notifier
      ..addQuery(_dnsQuery('alpha.test'))
      ..addQuery(_dnsQuery('beta.test'));

    await pumpDnsQueries(tester);
    await tester.tap(
      find.descendant(
        of: find.byType(DnsQueryRow),
        matching: find.text('alpha.test'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(DnsQueryDetailView), findsOneWidget);

    notifier.addQuery(_dnsQuery('gamma.test'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.byType(DnsQueryDetailView), findsNothing);
    expect(find.text('Select a query'), findsOneWidget);

    await teardownView(tester);
  });

  testWidgets('a query the store let go while the list was paused takes its '
      'pane with it once the list follows again', (tester) async {
    final start = DateTime.utc(2026, 9, 18, 4);
    final notifier = container.read(dnsQueriesProvider.notifier);
    notifier.value = FixedList<DnsQuery>(60);
    for (var index = 0; index < 60; index++) {
      notifier.addQuery(
        _dnsQuery(
          'd$index.test',
        ).copyWith(time: start.add(Duration(seconds: index * 7))),
      );
    }
    await pumpDnsQueries(tester);
    final list = find.byType(RecordMinuteList<DnsQuery>);
    await tester.timedDrag(
      list,
      const Offset(0, -6000),
      const Duration(seconds: 2),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('d0.test'));
    await tester.pumpAndSettle();
    expect(find.byType(DnsQueryDetailView), findsOneWidget);

    notifier.addQuery(
      _dnsQuery('new.test').copyWith(time: start.add(const Duration(hours: 1))),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('d0.test'), findsWidgets);
    expect(find.byType(DnsQueryDetailView), findsOneWidget);

    await tester.timedDrag(
      list,
      const Offset(0, 6000),
      const Duration(seconds: 2),
    );
    await tester.pumpAndSettle();

    expect(find.text('new.test'), findsOneWidget);
    expect(find.byType(DnsQueryDetailView), findsNothing);
    expect(find.text('Select a query'), findsOneWidget);

    await teardownView(tester);
  });

  testWidgets('tapping a query on a wide page shows its details in the pane', (
    tester,
  ) async {
    seedDnsQueries([
      _dnsQuery('alpha.test', upstream: 'tls://1.1.1.1:853'),
      _dnsQuery('beta.test'),
    ]);

    await pumpDnsQueries(tester);
    final alphaRow = find.descendant(
      of: find.byType(DnsQueryRow),
      matching: find.text('alpha.test'),
    );
    expect(find.text('Select a query'), findsOneWidget);
    expect(find.byType(DnsQueryDetailView), findsNothing);

    await tester.tap(alphaRow);
    await tester.pumpAndSettle();

    expect(find.byType(DnsQueryDetailView), findsOneWidget);
    expect(find.text('Select a query'), findsNothing);
    expect(find.text('DNS details'), findsNothing);
    expect(
      find.descendant(
        of: find.byType(DnsQueryDetailView),
        matching: find.text('tls://1.1.1.1:853'),
      ),
      findsOneWidget,
    );

    await tester.tap(alphaRow);
    await tester.pumpAndSettle();
    expect(find.byType(DnsQueryDetailView), findsNothing);
    expect(find.text('Select a query'), findsOneWidget);

    await teardownView(tester);
  });

  group('a query\'s related connections', () {
    Future<void> seedRelated() async {
      seedDnsQueries([
        _dnsQuery('alpha.test').copyWith(id: 5),
        _dnsQuery('beta.test').copyWith(id: 6),
      ]);
      container.listen(requestsProvider, (_, _) {});
      final requests = container.read(requestsProvider.notifier);
      for (final (id, host, dnsQueries) in [
        ('c1', 'alpha.test', [5]),
        ('c2', 'other.test', <int>[]),
      ]) {
        requests.addRequest(
          TrackerInfo(
            id: id,
            upload: 0,
            download: 0,
            start: DateTime.utc(2026),
            metadata: Metadata(network: 'tcp', host: host),
            chains: const ['DIRECT'],
            rule: 'Match',
            rulePayload: '',
            dnsQueries: dnsQueries,
          ),
        );
      }
    }

    Future<void> settle(WidgetTester tester) async {
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    Future<void> select(WidgetTester tester, String domain) async {
      await tester.tap(
        find.descendant(
          of: find.byType(DnsQueryRow),
          matching: find.text(domain),
        ),
      );
      await settle(tester);
    }

    final related = find.descendant(
      of: find.byType(DnsQueryDetailView),
      matching: find.widgetWithText(DecorationListItem, 'alpha.test'),
    );

    testWidgets('are listed under the query, and one opens beside the list '
        'in the connections', (tester) async {
      await seedRelated();
      await pumpDnsQueries(tester);
      await select(tester, 'alpha.test');

      expect(find.text('Related connections 1'), findsOneWidget);
      expect(related, findsOneWidget);
      expect(
        recordLinesIn(tester, related).single,
        matches(RegExp(r'^\[DIRECT\] \[(Active|Closed) ')),
      );
      expect(
        find.descendant(
          of: related,
          matching: find.byGlyph(Glyphs.chevronForward),
        ),
        findsOneWidget,
      );

      await tester.tap(related);
      await settle(tester);

      expect(find.byType(DnsQueryDetailView), findsNothing);
      expect(
        find.descendant(
          of: find.byType(TrackerInfoHeader),
          matching: find.text('alpha.test'),
        ),
        findsOneWidget,
      );

      await teardownView(tester);
    });

    testWidgets('build only those in view, however many the query has', (
      tester,
    ) async {
      seedDnsQueries([_dnsQuery('alpha.test').copyWith(id: 5)]);
      container.listen(requestsProvider, (_, _) {});
      final requests = container.read(requestsProvider.notifier);
      for (var index = 0; index < 300; index++) {
        requests.addRequest(
          TrackerInfo(
            id: 'c$index',
            start: DateTime.utc(2026),
            metadata: const Metadata(network: 'tcp', host: 'alpha.test'),
            chains: const ['DIRECT'],
            rule: 'Match',
            rulePayload: '',
            dnsQueries: const [5],
          ),
        );
      }
      await pumpDnsQueries(tester);
      await select(tester, 'alpha.test');

      expect(find.text('Related connections 300'), findsOneWidget);
      expect(
        find
            .byType(RelatedConnectionRow, skipOffstage: false)
            .evaluate()
            .length,
        lessThan(40),
      );

      await teardownView(tester);
    });

    testWidgets('are left out where the Core tied none to the query', (
      tester,
    ) async {
      await seedRelated();
      await pumpDnsQueries(tester);
      await select(tester, 'beta.test');

      expect(find.byType(DnsQueryDetailView), findsOneWidget);
      expect(find.textContaining('Related connections'), findsNothing);
      expect(related, findsNothing);

      await teardownView(tester);
    });
  });

  testWidgets('a failed query shows its error in its own section', (
    tester,
  ) async {
    seedDnsQueries([
      _dnsQuery(
        'timeout.test',
        answers: const [],
        rcode: '',
        error: 'i/o timeout',
      ),
    ]);

    await pumpDnsQueries(tester);

    await tester.tap(find.text('timeout.test'));
    await tester.pumpAndSettle();

    final errorHeader = find.descendant(
      of: find.byType(DnsQueryDetailView),
      matching: find.widgetWithText(ListHeader, 'Error'),
    );
    expect(errorHeader, findsOneWidget);
    final errorText = find.descendant(
      of: find.byType(DnsQueryDetailView),
      matching: find.text('i/o timeout'),
    );
    final errorRow = find.ancestor(
      of: errorText,
      matching: find.byType(DetailRow),
    );
    expect(
      find.descendant(of: errorRow, matching: find.text('Query timed out')),
      findsOneWidget,
    );
    expect(
      tester
          .widget<GlyphIcon>(
            find.descendant(
              of: errorRow,
              matching: find.byGlyph(AppGlyphs.error),
            ),
          )
          .color,
      Theme.of(tester.element(errorText)).colorScheme.error,
    );
    expect(
      tester.getTopLeft(errorText).dy,
      greaterThan(tester.getBottomLeft(errorHeader).dy),
    );

    await teardownView(tester);
  });

  testWidgets('a failed query is titled by what failed, and says DNS failed '
      'for anything else', (tester) async {
    final cases = {
      _dnsQuery('nx.test', answers: const [], rcode: 'NXDOMAIN'): (
        'No such domain',
        'NXDOMAIN',
      ),
      _dnsQuery('servfail.test', answers: const [], rcode: 'SERVFAIL'): (
        'The upstream failed',
        'SERVFAIL',
      ),
      _dnsQuery('refused.test', answers: const [], rcode: 'REFUSED'): (
        'Refused by the upstream',
        'REFUSED',
      ),
      _dnsQuery(
        'ads.test',
        answers: const [],
        rcode: 'REFUSED',
        upstream: 'rcode://refused',
      ): (
        'Blocked by a rule',
        'REFUSED',
      ),
      _dnsQuery(
        'slow.test',
        answers: const [],
        rcode: '',
        error: 'context deadline exceeded',
      ): (
        'Query timed out',
        'context deadline exceeded',
      ),
      _dnsQuery(
        'tls.test',
        answers: const [],
        rcode: '',
        error: 'remote error: tls: handshake failure',
      ): (
        'DNS failed',
        'remote error: tls: handshake failure',
      ),
    };
    seedDnsQueries(cases.keys.toList());
    await pumpDnsQueries(tester);

    for (final MapEntry(key: query, value: (title, message)) in cases.entries) {
      await tester.tap(
        find.descendant(
          of: find.byType(DnsQueryRow),
          matching: find.text(query.domain),
        ),
      );
      await tester.pumpAndSettle();

      final errorRow = find.descendant(
        of: find.byType(DnsQueryDetailView),
        matching: find.ancestor(
          of: find.byGlyph(AppGlyphs.error),
          matching: find.byType(DetailRow),
        ),
      );
      expect(
        find.descendant(of: errorRow, matching: find.text(title)),
        findsOneWidget,
        reason: query.domain,
      );
      expect(
        find.descendant(of: errorRow, matching: find.text(message)),
        findsOneWidget,
        reason: query.domain,
      );
    }

    await teardownView(tester);
  });

  testWidgets('the overflow menu clears the DNS cache and says so', (
    tester,
  ) async {
    when(core.clearDnsCache).thenAnswer((_) async => true);
    await pumpDnsQueries(tester);

    await clearDnsCache(tester);

    verify(core.clearDnsCache).called(1);
    expect(find.text('DNS cache cleared'), findsOneWidget);

    await teardownView(tester);
  });

  testWidgets('a Core that cannot clear the DNS cache reports it', (
    tester,
  ) async {
    when(core.clearDnsCache).thenThrow(
      const CoreMethodException(
        code: 'transport_disconnected',
        message: 'Core is not running',
      ),
    );
    await pumpDnsQueries(tester);

    await clearDnsCache(tester);

    expect(find.text('Failed to clear DNS cache'), findsOneWidget);
    expect(find.text('DNS cache cleared'), findsNothing);

    await teardownView(tester);
  });

  testWidgets('a full list builds only the query added', (tester) async {
    seedDnsQueries([
      for (var index = 0; index < 500; index++) _dnsQuery('d$index.test'),
    ]);
    await pumpDnsQueries(tester, size: _narrowSize);
    await tester.pump(const Duration(seconds: 1));

    var built = 0;
    debugOnRebuildDirtyWidget = (element, _) {
      if (element.widget.runtimeType == DnsQueryRow) {
        built++;
      }
    };
    addTearDown(() => debugOnRebuildDirtyWidget = null);
    container.read(dnsQueriesProvider.notifier).addQuery(_dnsQuery('new.test'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    debugOnRebuildDirtyWidget = null;

    expect(built, 1);
    await teardownView(tester);
  });

  List<DnsQuery> spreadQueries(DateTime start) => [
    for (var index = 0; index < 500; index++)
      _dnsQuery(
        'd$index.test',
      ).copyWith(time: start.add(Duration(seconds: index * 7))),
  ];

  Future<void> switchTo(WidgetTester tester, String segment) async {
    await tester.tap(find.text(segment).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  void addQuery(DnsQuery dnsQuery) =>
      container.read(dnsQueriesProvider.notifier).addQuery(dnsQuery);

  testWidgets('a query selected beside the list moves into a sheet as the '
      'page narrows and back as it widens, and the connection chosen '
      'before stays out of it', (tester) async {
    seedDnsQueries([_dnsQuery('alpha.test'), _dnsQuery('beta.test')]);
    container
        .read(requestsProvider.notifier)
        .addRequest(
          TrackerInfo(
            id: 'c1',
            start: DateTime.utc(2026),
            metadata: const Metadata(network: 'tcp', host: 'conn.test'),
            chains: const ['DIRECT'],
            rule: 'Match',
            rulePayload: '',
          ),
        );
    Future<void> resize(Size size) async {
      container.read(viewSizeProvider.notifier).update((_) => size);
      tester.view.physicalSize = size;
      await tester.pumpAndSettle();
    }

    await pumpDnsQueries(tester);
    await switchTo(tester, 'Connections');
    await tester.tap(find.text('conn.test').first);
    await tester.pumpAndSettle();
    expect(find.byType(TrackerInfoHeader), findsOneWidget);
    await switchTo(tester, 'DNS');
    await tester.tap(
      find.descendant(
        of: find.byType(DnsQueryRow),
        matching: find.text('alpha.test'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(DnsQueryDetailView), findsOneWidget);

    await resize(const Size(800, 1000));
    expect(find.byType(DnsQueryDetailSheet), findsOneWidget);
    expect(find.byType(TrackerInfoDetailSheet), findsNothing);

    await resize(_paneSize);
    expect(find.byType(DnsQueryDetailSheet), findsNothing);
    expect(
      find.descendant(
        of: find.byType(DnsQueryDetailView),
        matching: find.text('alpha.test'),
      ),
      findsOneWidget,
    );
    await switchTo(tester, 'Connections');
    await tester.pumpAndSettle();
    expect(find.byType(TrackerInfoHeader), findsNothing);

    await teardownView(tester);
  });

  testWidgets('a list scrolled back from the newest comes back where it was '
      'left after another segment, still not following', (tester) async {
    final start = DateTime.utc(2026, 9, 18, 4);
    seedDnsQueries(spreadQueries(start));
    await pumpDnsQueries(tester, size: _narrowSize);
    await tester.pump(const Duration(seconds: 1));
    final list = find.byType(RecordMinuteList<DnsQuery>);
    ScrollPosition position() => tester
        .state<ScrollableState>(
          find.descendant(of: list, matching: find.byType(Scrollable)).first,
        )
        .position;
    Map<String, double> inView() {
      final bounds = tester.getRect(list);
      return {
        for (final element in find.byType(DnsQueryRow).evaluate())
          if (tester.getRect(find.byWidget(element.widget)) case final rect
              when rect.bottom > bounds.top && rect.top < bounds.bottom)
            (element.widget as DnsQueryRow).dnsQuery.domain: rect.top,
      };
    }

    await tester.timedDrag(
      list,
      const Offset(0, -1500),
      const Duration(seconds: 2),
    );
    await tester.pumpAndSettle();
    final left = inView();
    expect(left, isNot(contains('d499.test')));

    await switchTo(tester, 'Connections');
    addQuery(
      _dnsQuery('new.test').copyWith(time: start.add(const Duration(hours: 2))),
    );
    await tester.pump(const Duration(seconds: 1));
    await switchTo(tester, 'DNS');

    expect(inView(), left);
    expect(find.text('new.test'), findsNothing);
    expect(position().pixels, lessThan(position().maxScrollExtent));

    await tester.drag(list, const Offset(0, 3000));
    await tester.pumpAndSettle();
    expect(find.text('new.test'), findsOneWidget);
    await teardownView(tester);
  });

  testWidgets('a list at the newest comes back after another segment with '
      'what arrived meanwhile, and follows on', (tester) async {
    final start = DateTime.utc(2026, 9, 18, 4);
    seedDnsQueries(spreadQueries(start));
    await pumpDnsQueries(tester, size: _narrowSize);
    await tester.pump(const Duration(seconds: 1));
    final list = find.byType(RecordMinuteList<DnsQuery>);
    ScrollPosition position() => tester
        .state<ScrollableState>(
          find.descendant(of: list, matching: find.byType(Scrollable)).first,
        )
        .position;

    await switchTo(tester, 'Connections');
    addQuery(
      _dnsQuery('new.test').copyWith(time: start.add(const Duration(hours: 2))),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('DNS').first);
    await tester.pump();

    expect(find.text('new.test'), findsOneWidget);
    expect(position().pixels, position().maxScrollExtent);

    addQuery(
      _dnsQuery(
        'later.test',
      ).copyWith(time: start.add(const Duration(hours: 3))),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(find.text('later.test'), findsOneWidget);
    expect(position().pixels, position().maxScrollExtent);
    await teardownView(tester);
  });

  testWidgets('a list hidden behind another segment builds nothing as '
      'queries arrive', (tester) async {
    final start = DateTime.utc(2026, 9, 18, 4);
    seedDnsQueries(spreadQueries(start));
    await pumpDnsQueries(tester, size: _narrowSize);
    await tester.pump(const Duration(seconds: 1));
    await switchTo(tester, 'Connections');
    await tester.pump(const Duration(seconds: 1));

    final hiddenBuilds = countHiddenSegmentBuilds();
    for (var index = 0; index < 5; index++) {
      addQuery(
        _dnsQuery(
          'new$index.test',
        ).copyWith(time: start.add(Duration(hours: 2, seconds: index))),
      );
      await tester.pump(const Duration(milliseconds: 600));
    }
    await tester.pump(const Duration(seconds: 2));

    expect(hiddenBuilds(), 0);
    await switchTo(tester, 'DNS');
    expect(find.text('new4.test'), findsOneWidget);
    await teardownView(tester);
  });

  testWidgets(
    'on desktop a list at the newest keeps new queries out while the '
    'pointer rests on it, and takes them in as it leaves',
    variant: TargetPlatformVariant.only(TargetPlatform.macOS),
    (tester) async {
      final start = DateTime.utc(2026, 9, 18, 4);
      seedDnsQueries([
        for (var index = 0; index < 3; index++)
          _dnsQuery(
            'd$index.test',
          ).copyWith(time: start.add(Duration(seconds: index))),
      ]);
      await pumpDnsQueries(tester, size: _narrowSize);
      await tester.pump(const Duration(seconds: 1));
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: tester.getCenter(find.text('d1.test')));
      await tester.pump();

      addQuery(
        _dnsQuery(
          'new.test',
        ).copyWith(time: start.add(const Duration(hours: 1))),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      expect(find.text('new.test'), findsNothing);

      await mouse.moveTo(tester.getCenter(find.text('DNS').first));
      await tester.pump();
      expect(find.text('new.test'), findsOneWidget);
      await teardownView(tester);
    },
  );
}
