import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/features.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/detail_tabs.dart';
import '../helpers/host_scaffold.dart';
import '../helpers/test_app.dart';

final _accepted = DateTime(2026, 1, 1, 10, 30, 15, 100);

TrackerInfo _tracker({
  List<String> chains = const ['DIRECT'],
  DnsMode? dnsMode,
  int? ruleIndex,
  List<int> dnsQueries = const [],
  ConnectionTiming? timing,
  ConnectionFailure? failure,
  ConnectionEnd? end,
  DateTime? closedAt,
}) {
  return TrackerInfo(
    id: 1,
    start: _accepted,
    metadata: Metadata(
      network: 'tcp',
      host: 'example.com',
      destinationIP: '5.6.7.8',
      destinationPort: '443',
      dnsMode: dnsMode,
    ),
    chains: chains,
    rule: 'DOMAIN-SUFFIX',
    rulePayload: 'example.com',
    ruleIndex: ruleIndex,
    dnsQueries: dnsQueries,
    timing: timing,
    failure: failure,
    end: end,
    closedAt: closedAt,
  );
}

void main() {
  Future<void> pumpTimeline(
    WidgetTester tester,
    TrackerInfo trackerInfo, {
    List<Override> overrides = const [],
  }) async {
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: overrides.isEmpty,
        overrides: overrides,
        homeBuilder: (child) => HostScaffold(body: child),
        child: SingleChildScrollView(
          child: TrackerTimeline(trackerInfo: trackerInfo),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 5));
  }

  List<TrackerRailRow> rows(WidgetTester tester) =>
      tester.widgetList<TrackerRailRow>(find.byType(TrackerRailRow)).toList();

  List<String> kinds(WidgetTester tester) => [
    for (final row in rows(tester)) row.subtitle.split(' · ').first,
  ];

  testWidgets('a narrow timeline keeps each step on a two-line row, a long '
      'rule cut short on its line', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpTimeline(
      tester,
      _tracker().copyWith(
        rulePayload: 'static-assets.cdn.example.com.long-suffix.test',
      ),
    );

    final rule = find.text(
      'DOMAIN-SUFFIX,static-assets.cdn.example.com.long-suffix.test',
    );
    expect(tester.renderObject<RenderParagraph>(rule).didExceedMaxLines, true);
    for (final row in find.byType(TrackerRailRow).evaluate()) {
      expect(
        row.size!.height,
        listRowExtent(titleHeight: 22, subtitleHeight: 20),
      );
    }
    expect(
      [for (final row in rows(tester)) row.mark],
      [RailMark.step, RailMark.step, RailMark.end],
    );

    await unmount(tester);
  });

  testWidgets('an untimed connection lists rule, node, connection and status '
      'without a time column', (tester) async {
    await pumpTimeline(
      tester,
      _tracker(
        chains: const ['Tokyo 01', 'Auto'],
        closedAt: _accepted.add(const Duration(seconds: 2)),
      ),
    );

    expect(kinds(tester), ['Rule', 'Node', 'Connection', 'Status']);
    expect(find.text('DOMAIN-SUFFIX,example.com'), findsOneWidget);
    expect(find.text('Tokyo 01'), findsOneWidget);
    expect(find.text('TCP 5.6.7.8:443'), findsOneWidget);
    expect(find.text('Now'), findsNothing);
    expect(find.textContaining(':15'), findsNothing);

    await unmount(tester);
  });

  testWidgets('a node row names the group that picked it and the delay', (
    tester,
  ) async {
    await pumpTimeline(
      tester,
      _tracker(chains: const ['Tokyo 01', 'Auto']),
      overrides: [
        groupsProvider.overrideWithBuild(
          (_, _) => const [
            Group(
              type: GroupType.URLTest,
              name: 'Auto',
              testUrl: 'https://group.test',
              all: [Proxy(name: 'Tokyo 01', type: 'Trojan')],
            ),
          ],
        ),
        delayProvider(
          proxyName: 'Tokyo 01',
          testUrl: 'https://group.test',
        ).overrideWithValue(38),
      ],
    );

    expect(find.text('Node · URLTest · Delay 38 ms'), findsOneWidget);

    await unmount(tester);
  });

  test('a connection with one chain entry has no node row', () {
    final events = trackerTimelineEvents(
      lookupAppLocalizations(const Locale('en')),
      _tracker(),
      dnsQueries: const [],
      pickedBy: null,
      delay: null,
      ruleIndex: null,
      exchanges: const [],
    );

    expect(
      [for (final event in events) event.kind],
      ['Rule', 'Connection', 'Status'],
    );
    expect(events.any((event) => event.title == 'DIRECT'), isFalse);
  });

  testWidgets('a timed active connection shows the second of its first time, '
      'the next in that second as milliseconds, and Now on its status', (
    tester,
  ) async {
    await pumpTimeline(
      tester,
      _tracker(
        timing: ConnectionTiming(
          accepted: _accepted,
          routed: 20000,
          dialEnd: 45000,
        ),
      ),
    );

    expect(find.text('10:30:15'), findsOneWidget);
    expect(find.text('.145'), findsOneWidget);
    expect(find.text('Now'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('a time in a later second is shown in full again', (
    tester,
  ) async {
    await pumpTimeline(
      tester,
      _tracker(
        timing: ConnectionTiming(
          accepted: _accepted,
          routed: 20000,
          dialEnd: 1500000,
        ),
      ),
    );

    expect(find.text('10:30:15'), findsOneWidget);
    expect(find.text('10:30:16'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('a query linked by id shows as a DNS row', (tester) async {
    final linked = DnsQuery(
      id: 7,
      domain: 'example.com',
      type: 'A',
      cached: true,
      answers: const ['1.2.3.4'],
      delay: 12,
      time: _accepted,
    );
    final other = DnsQuery(
      id: 8,
      domain: 'other.test',
      type: 'A',
      time: _accepted,
    );
    await pumpTimeline(
      tester,
      _tracker(dnsQueries: const [7]),
      overrides: [
        dnsQueriesProvider.overrideWithValue(
          FixedList<DnsQuery>(10, list: [other, linked]),
        ),
      ],
    );

    expect(kinds(tester), ['DNS', 'Rule', 'Connection', 'Status']);
    expect(find.text('A → 1.2.3.4'), findsOneWidget);
    expect(find.textContaining('12 ms'), findsOneWidget);
    expect(find.textContaining('Cache'), findsOneWidget);
    expect(find.textContaining('other.test'), findsNothing);

    await unmount(tester);
  });

  testWidgets('a fake-ip connection without linked queries shows its '
      'mapping as the DNS row', (tester) async {
    await pumpTimeline(tester, _tracker(dnsMode: DnsMode.fakeIp));

    expect(kinds(tester), ['DNS', 'Rule', 'Connection', 'Status']);
    expect(find.text('DNS · fake-ip mapping'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('a connection without queries or a DNS mode has no DNS row', (
    tester,
  ) async {
    await pumpTimeline(tester, _tracker());

    expect(kinds(tester), isNot(contains('DNS')));

    await unmount(tester);
  });

  testWidgets('the rule row names where the rule stands in the rules in '
      'force, and no place once a reload puts another rule there', (
    tester,
  ) async {
    var rules = RuleTable.of(const [
      (type: 'DOMAIN', payload: 'a.test'),
      (type: 'DOMAIN-SUFFIX', payload: 'example.com'),
    ]);
    await pumpTimeline(
      tester,
      _tracker(ruleIndex: 1),
      overrides: [activeRulesProvider.overrideWith((_) async => rules)],
    );
    await tester.pump();

    expect(find.text('Rule · #2 → DIRECT'), findsOneWidget);

    rules = RuleTable.of(const [
      (type: 'DOMAIN-SUFFIX', payload: 'example.com'),
      (type: 'DOMAIN', payload: 'a.test'),
    ]);
    ProviderScope.containerOf(
      tester.element(find.byType(TrackerTimeline)),
    ).invalidate(activeRulesProvider);
    await tester.pump();
    await tester.pump();

    expect(find.text('Rule · → DIRECT'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('a rule place past the end of the rules in force, or with no '
      'rules listed, is not shown', (tester) async {
    await pumpTimeline(
      tester,
      _tracker(ruleIndex: 5),
      overrides: [
        activeRulesProvider.overrideWith(
          (_) async => RuleTable.of(const [
            (type: 'DOMAIN-SUFFIX', payload: 'example.com'),
          ]),
        ),
      ],
    );
    await tester.pump();
    expect(find.text('Rule · → DIRECT'), findsOneWidget);
    await unmount(tester);

    await pumpTimeline(
      tester,
      _tracker(ruleIndex: 0),
      overrides: [
        activeRulesProvider.overrideWith(
          (_) => Future<RuleTable>.error(StateError('stopped')),
        ),
      ],
    );
    await tester.pump();
    expect(find.text('Rule · → DIRECT'), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('a failed connection says its failure kind and message in its '
      'connection row', (tester) async {
    await pumpTimeline(
      tester,
      _tracker(
        closedAt: DateTime(2026, 1, 1, 10, 31),
        failure: const ConnectionFailure(
          kind: ConnectionFailureKind.timeout,
          message: 'dial tcp 5.6.7.8:443: i/o timeout',
        ),
      ),
    );

    expect(
      find.text('Connection · Timeout · dial tcp 5.6.7.8:443: i/o timeout'),
      findsOneWidget,
    );
    expect(
      [for (final row in rows(tester)) row.mark],
      [RailMark.step, RailMark.error, RailMark.error],
    );

    await unmount(tester);
  });

  testWidgets('a connection the remote closed says so in its status', (
    tester,
  ) async {
    final closedAt = DateTime(2026, 1, 1, 10, 31);
    await pumpTimeline(
      tester,
      _tracker(
        closedAt: closedAt,
        end: ConnectionEnd(
          reason: ConnectionEndReason.remote,
          endedAt: closedAt,
        ),
      ),
    );

    expect(find.textContaining(RegExp(r'^Closed \d')), findsOneWidget);
    expect(find.textContaining('Closed by the remote'), findsOneWidget);
    expect(find.text('Now'), findsNothing);
    expect(rows(tester).last.mark, RailMark.end);

    await unmount(tester);
  });

  testWidgets('a detail opens on the timeline, keeps its header over the '
      'info tab, and lists the path there', (tester) async {
    final tracker = _tracker();
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        homeBuilder: (child) => HostScaffold(body: child),
        child: SheetProvider(
          type: SheetType.page,
          child: TrackerInfoDetailView(
            trackerInfo: tracker,
            header: TrackerInfoHeader(trackerInfo: tracker),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(TrackerTimeline), findsOneWidget);
    expect(find.byType(TrackerInfoHeader), findsOneWidget);
    expect(find.text('Path'), findsNothing);

    await openDetailTab(tester, 'Info');

    expect(find.byType(TrackerTimeline), findsNothing);
    expect(find.byType(TrackerInfoHeader), findsOneWidget);
    expect(find.text('Path'), findsOneWidget);

    await unmount(tester);
  });
}
