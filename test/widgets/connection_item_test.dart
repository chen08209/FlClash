import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/views/connection/item.dart';
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
    );
    await tester.pump();

    expect(find.text('DOMAIN-SUFFIX(example.com)'), findsOneWidget);
    expect(find.text('chrome(1000)'), findsOneWidget);
    expect(find.text('1.2.3.4:8080'), findsOneWidget);
    expect(find.text('5.6.7.8:443'), findsOneWidget);
    expect(find.text('example.com'), findsOneWidget);
    expect(find.text('DIRECT'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('TrackerInfoDetailView omits empty fields', (tester) async {
    await tester.pumpWidget(
      TestApp(
        homeBuilder: (child) => Scaffold(body: child),
        child: TrackerInfoDetailView(trackerInfo: _tracker()),
      ),
    );
    await tester.pump();

    expect(find.textContaining('('), findsNothing);
    expect(find.text('tcp'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('TrackerInfoItem renders chains and forwards keyword clicks', (
    tester,
  ) async {
    String? clicked;
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        homeBuilder: (child) => Scaffold(body: child),
        child: TrackerInfoItem(
          trackerInfo: _tracker(chains: const ['Proxy A', 'Proxy B']),
          detailTitle: 'detail',
          onClickKeyword: (keyword) => clicked = keyword,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Proxy A'), findsOneWidget);
    expect(find.text('Proxy B'), findsOneWidget);

    await tester.tap(find.text('Proxy A'));
    await tester.pump();

    expect(clicked, 'Proxy A');

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
