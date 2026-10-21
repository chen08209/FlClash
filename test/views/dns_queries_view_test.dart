import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/core/method.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/views/dns_queries.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

class _MockCoreHandlerInterface extends Mock implements CoreHandlerInterface {}

const _tableSize = Size(1400, 1000);
const _listSize = Size(600, 1000);

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
    Size size = _tableSize,
    bool withStatusManager = false,
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
          withStatusManager: withStatusManager,
          child: const DnsQueriesView(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  Future<void> teardownView(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  }

  testWidgets('shows the empty state without any query', (tester) async {
    await pumpDnsQueries(tester);

    expect(find.byType(NullStatus), findsOneWidget);
    expect(find.text('No DNS queries yet'), findsOneWidget);

    await teardownView(tester);
  });

  testWidgets('lists each query with its answers and chips', (tester) async {
    seedDnsQueries([
      _dnsQuery(
        'alpha.test',
        initiator: DnsQueryInitiator.app,
        answers: ['93.184.216.34'],
      ),
      _dnsQuery(
        'cached.test',
        initiator: DnsQueryInitiator.direct,
        cached: true,
      ),
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

    await pumpDnsQueries(tester, size: _listSize);

    expect(find.text('alpha.test'), findsOneWidget);
    expect(find.text('93.184.216.34'), findsOneWidget);
    expect(find.text('App'), findsOneWidget);
    expect(find.text('Direct'), findsOneWidget);
    expect(find.text('Cache'), findsOneWidget);
    expect(find.text('NXDOMAIN'), findsOneWidget);
    expect(
      find.text(DateTime.utc(2026, 9, 18, 4, 30).showFull),
      findsNWidgets(4),
    );
    expect(find.text('12 ms'), findsNWidgets(4));
    expect(
      tester.getCenter(find.text('App')).dy,
      greaterThan(tester.getCenter(find.text('alpha.test')).dy),
    );
    final error = tester.widget<Text>(find.text('i/o timeout'));
    expect(
      error.style?.color,
      Theme.of(tester.element(find.text('i/o timeout'))).colorScheme.error,
    );

    await teardownView(tester);
  });

  testWidgets('a wide page lays the queries out under a column header', (
    tester,
  ) async {
    seedDnsQueries([
      _dnsQuery(
        'alpha.test',
        initiator: DnsQueryInitiator.app,
        upstream: 'tls://1.1.1.1:853',
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

    await pumpDnsQueries(tester);

    for (final label in [
      'Time',
      'Domain',
      'Type',
      'From',
      'Result',
      'Source',
      'Took',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.byType(DnsQueryItem), findsNothing);
    expect(find.text('93.184.216.34, 93.184.216.35'), findsOneWidget);
    expect(find.text('tls://1.1.1.1:853'), findsOneWidget);
    expect(find.widgetWithText(RecordLabel, 'App'), findsOneWidget);
    expect(find.widgetWithText(RecordLabel, 'Cache'), findsOneWidget);
    expect(find.widgetWithText(RecordLabel, 'NXDOMAIN'), findsOneWidget);
    expect(find.text('12 ms'), findsNWidgets(4));
    final error = tester.widget<Text>(find.text('i/o timeout'));
    expect(
      error.style?.color,
      Theme.of(tester.element(find.text('i/o timeout'))).colorScheme.error,
    );
    expect(
      tester
          .widget<RecordLabel>(find.widgetWithText(RecordLabel, 'NXDOMAIN'))
          .tone,
      RecordTone.error,
    );
    expect(tester.takeException(), null);

    await teardownView(tester);
  });

  testWidgets('tapping a column header sorts the queries by it', (
    tester,
  ) async {
    seedDnsQueries([
      _dnsQuery('fast.test', delay: 5),
      _dnsQuery('slow.test', delay: 300),
      _dnsQuery('mid.test', delay: 40),
    ]);

    await pumpDnsQueries(tester);

    double topOf(String domain) => tester.getTopLeft(find.text(domain)).dy;
    expect(topOf('mid.test'), lessThan(topOf('slow.test')));

    await tester.tap(find.text('Took'));
    await tester.pumpAndSettle();
    expect(topOf('slow.test'), lessThan(topOf('mid.test')));
    expect(topOf('mid.test'), lessThan(topOf('fast.test')));

    await tester.tap(find.text('Domain'));
    await tester.pumpAndSettle();
    expect(topOf('fast.test'), lessThan(topOf('mid.test')));
    expect(topOf('mid.test'), lessThan(topOf('slow.test')));

    await teardownView(tester);
  });

  testWidgets('a narrow page keeps the stacked rows', (tester) async {
    seedDnsQueries([_dnsQuery('alpha.test')]);

    await pumpDnsQueries(tester, size: _listSize);

    expect(find.byType(DnsQueryItem), findsOneWidget);
    expect(find.byType(RecordTableRow), findsNothing);
    expect(find.text('Domain'), findsNothing);

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

  testWidgets('tapping a chip keeps only the queries carrying it', (
    tester,
  ) async {
    seedDnsQueries([
      _dnsQuery('alpha.test'),
      _dnsQuery('beta.test', type: 'AAAA', answers: ['::1']),
    ]);

    await pumpDnsQueries(tester);
    expect(find.text('alpha.test'), findsOneWidget);

    await tester.tap(find.widgetWithText(RecordLabel, 'AAAA'));
    await tester.pumpAndSettle();

    expect(find.text('alpha.test'), findsNothing);
    expect(find.text('beta.test'), findsOneWidget);

    await teardownView(tester);
  });

  testWidgets('tapping a query opens its details', (tester) async {
    seedDnsQueries([
      _dnsQuery(
        'alpha.test',
        initiator: DnsQueryInitiator.rule,
        upstream: 'tls://1.1.1.1:853',
        cached: true,
        answers: ['edge.alpha.net', '93.184.216.34'],
      ),
    ]);

    await pumpDnsQueries(tester);
    expect(find.text('tls://1.1.1.1:853'), findsOneWidget);
    expect(find.text('12 ms'), findsOneWidget);

    await tester.tap(find.text('alpha.test'));
    await tester.pumpAndSettle();

    expect(find.text('DNS details'), findsOneWidget);
    expect(find.text('Record type'), findsOneWidget);
    Finder detailText(String text) => find.descendant(
      of: find.byType(DnsQueryDetailView),
      matching: find.text(text),
    );
    expect(find.text('Initiator'), findsOneWidget);
    expect(detailText('Source'), findsOneWidget);
    expect(detailText('tls://1.1.1.1:853'), findsOneWidget);
    expect(detailText('Cache'), findsOneWidget);
    expect(detailText('Yes'), findsOneWidget);
    expect(detailText('12 ms'), findsOneWidget);
    expect(find.text('Answers'), findsOneWidget);
    expect(find.text('edge.alpha.net'), findsOneWidget);
    expect(find.text('93.184.216.34'), findsOneWidget);

    await teardownView(tester);
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
    expect(
      tester.widget<Text>(errorText).style?.color,
      Theme.of(tester.element(errorText)).colorScheme.error,
    );
    expect(
      tester.getTopLeft(errorText).dy,
      greaterThan(tester.getBottomLeft(errorHeader).dy),
    );

    await teardownView(tester);
  });

  testWidgets('the broom clears the DNS cache and says so', (tester) async {
    when(core.clearDnsCache).thenAnswer((_) async => true);
    await pumpDnsQueries(tester, withStatusManager: true);

    await tester.tap(find.byGlyph(AppGlyphs.broom));
    await tester.pumpAndSettle();

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
    await pumpDnsQueries(tester, withStatusManager: true);

    await tester.tap(find.byGlyph(AppGlyphs.broom));
    await tester.pumpAndSettle();

    expect(find.text('Failed to clear DNS cache'), findsOneWidget);
    expect(find.text('DNS cache cleared'), findsNothing);

    await teardownView(tester);
  });
}
