import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/dns_queries.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

DnsQuery _dnsQuery(
  String domain, {
  String type = 'A',
  DnsQueryInitiator? initiator,
  String upstream = '',
  bool cached = false,
  List<String> answers = const ['1.1.1.1'],
  String rcode = 'NOERROR',
  String error = '',
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
    delay: 12,
    time: DateTime.utc(2026, 9, 18, 4, 30),
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

  void seedDnsQueries(List<DnsQuery> dnsQueries) {
    final notifier = container.read(dnsQueriesProvider.notifier);
    notifier.value = FixedList<DnsQuery>(500);
    for (final dnsQuery in dnsQueries) {
      notifier.addQuery(dnsQuery);
    }
  }

  Future<void> pumpDnsQueries(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: DnsQueriesView()),
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

    await pumpDnsQueries(tester);

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
    expect(find.text('Initiator'), findsOneWidget);
    expect(find.text('Source'), findsOneWidget);
    Finder detailText(String text) => find.descendant(
      of: find.byType(DnsQueryDetailView),
      matching: find.text(text),
    );
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
}
