import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/features/features.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

TrackerInfo _tracker({
  String rule = 'DOMAIN-SUFFIX',
  String rulePayload = '',
  String process = '',
  int uid = 0,
  String sourceIP = '',
  String sourcePort = '',
  String destinationIP = '',
  String destinationPort = '',
  String host = '',
  List<String> chains = const [],
}) {
  return TrackerInfo(
    id: '1',
    start: DateTime(2026, 1, 1, 10, 30),
    metadata: Metadata(
      network: 'tcp',
      process: process,
      uid: uid,
      sourceIP: sourceIP,
      sourcePort: sourcePort,
      destinationIP: destinationIP,
      destinationPort: destinationPort,
      host: host,
    ),
    chains: chains,
    rule: rule,
    rulePayload: rulePayload,
  );
}

void main() {
  testWidgets('TrackerInfoDetailView renders formatted connection fields', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(
        homeBuilder: (child) => Scaffold(body: child),
        child: SheetProvider(
          type: SheetType.page,
          child: TrackerInfoDetailView(
            trackerInfo: _tracker(
              rule: 'DOMAIN-SUFFIX',
              rulePayload: 'example.com',
              process: 'chrome',
              uid: 1000,
              sourceIP: '1.2.3.4',
              sourcePort: '8080',
              destinationIP: '5.6.7.8',
              destinationPort: '443',
              host: 'example.com',
              chains: const ['DIRECT'],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('DOMAIN-SUFFIX(example.com)'), findsOneWidget);
    expect(find.text('chrome(1000)'), findsOneWidget);
    expect(find.text('1.2.3.4:8080'), findsOneWidget);
    expect(find.text('5.6.7.8:443'), findsOneWidget);
    expect(find.text('example.com'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('DIRECT'),
      100,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('DIRECT'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('TrackerInfoDetailView omits empty fields', (tester) async {
    await tester.pumpWidget(
      TestApp(
        homeBuilder: (child) => Scaffold(body: child),
        child: SheetProvider(
          type: SheetType.page,
          child: TrackerInfoDetailView(trackerInfo: _tracker()),
        ),
      ),
    );
    await tester.pump();

    expect(find.textContaining('('), findsNothing);
    expect(find.text('tcp'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('TrackerInfoItem shows all chains and forwards their clicks', (
    tester,
  ) async {
    final clicked = <String>[];
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        homeBuilder: (child) => Scaffold(body: child),
        child: TrackerInfoItem(
          trackerInfo: _tracker(chains: const ['Proxy A', 'Proxy B']),
          detailTitle: 'detail',
          onClickKeyword: clicked.add,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Proxy A'), findsOneWidget);
    expect(find.text('Proxy B'), findsOneWidget);

    await tester.tap(find.text('Proxy A'));
    await tester.pump();
    await tester.tap(find.text('Proxy B'));
    await tester.pump();

    expect(clicked, ['Proxy A', 'Proxy B']);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('TrackerInfoItem reads from the rule to the node', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        homeBuilder: (child) => Scaffold(body: child),
        child: TrackerInfoItem(
          trackerInfo: _tracker(
            rulePayload: 'example.com',
            process: 'chrome',
            uid: 1000,
            sourceIP: '1.2.3.4',
            sourcePort: '8080',
            destinationIP: '5.6.7.8',
            destinationPort: '443',
            host: 'example.com',
            chains: const ['Node', 'Group'],
          ),
          detailTitle: 'detail',
        ),
      ),
    );
    await tester.pump();

    final rule = tester.getCenter(find.text('DOMAIN-SUFFIX(example.com)'));
    final group = tester.getCenter(find.text('Group'));
    final node = tester.getCenter(find.text('Node'));
    expect(rule.dx, lessThan(group.dx));
    expect(group.dx, lessThan(node.dx));
    expect(find.text('example.com:443  5.6.7.8'), findsOneWidget);
    expect(find.text('chrome(1000)  ·  1.2.3.4:8080'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('TrackerInfoItem shows speed only for a live connection', (
    tester,
  ) async {
    Future<void> pumpItem({required bool isLive}) async {
      await tester.pumpWidget(
        TestApp(
          wrapInProviderScope: true,
          homeBuilder: (child) => Scaffold(body: child),
          child: TrackerInfoItem(
            key: ValueKey(isLive),
            trackerInfo: _tracker(
              host: 'example.com',
            ).copyWith(uploadSpeed: 2048, downloadSpeed: 4096),
            isLive: isLive,
            action: const SizedBox(key: ValueKey('action')),
            detailTitle: 'detail',
          ),
        ),
      );
      await tester.pump();
    }

    await pumpItem(isLive: false);
    expect(find.text(DateTime(2026, 1, 1, 10, 30).showFull), findsOneWidget);
    expect(find.textContaining('4KB/s'), findsNothing);

    await pumpItem(isLive: true);
    expect(find.text(DateTime(2026, 1, 1, 10, 30).showFull), findsNothing);
    expect(find.textContaining('4KB/s'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(RecordHeader),
        matching: find.byKey(const ValueKey('action')),
      ),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('TrackerInfoDetailView lists the chain from group to node', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(
        homeBuilder: (child) => Scaffold(body: child),
        child: SheetProvider(
          type: SheetType.page,
          child: TrackerInfoDetailView(
            trackerInfo: _tracker(chains: const ['Node', 'Group']),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.scrollUntilVisible(
      find.text('Node'),
      100,
      scrollable: find.byType(Scrollable),
    );

    expect(
      tester.getCenter(find.text('Group')).dx,
      lessThan(tester.getCenter(find.text('Node')).dx),
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
